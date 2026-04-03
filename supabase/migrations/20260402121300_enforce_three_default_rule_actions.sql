-- New subcategory rules: exactly 2 default actions (no "Check the parts", no "Offer booking link").
-- Strips those strings from existing service_rules.actions where present.

CREATE OR REPLACE FUNCTION public.handle_new_service_subcategory()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_category_code text;
BEGIN
  SELECT c.code
    INTO v_category_code
  FROM public.service_categories c
  WHERE c.id = NEW.category_id;

  INSERT INTO public.service_rules (
    category_code,
    subcategory_code,
    title,
    description,
    is_active,
    actions
  )
  VALUES (
    v_category_code,
    NEW.code,
    CONCAT('Default Rule for ', COALESCE(NEW.name, NEW.code)),
    NULL,
    true,
    jsonb_build_array(
      'Require vehicle make, model, and year',
      'Explain the price to customer'
    )
  )
  ON CONFLICT (category_code, subcategory_code)
  DO UPDATE SET
    category_code = EXCLUDED.category_code,
    title = EXCLUDED.title,
    is_active = EXCLUDED.is_active,
    description = COALESCE(public.service_rules.description, EXCLUDED.description),
    actions = (
      SELECT
        CASE
          WHEN ea IS NULL THEN EXCLUDED.actions
          WHEN ea = '[]'::jsonb THEN EXCLUDED.actions
          ELSE ea
        END
      FROM (SELECT public.service_rules.actions AS ea) s
    );

  RETURN NEW;
END;
$$;

-- Remove legacy "Check the parts" entries from stored action lists.
UPDATE public.service_rules sr
SET actions = sub.cleaned
FROM (
  SELECT
    sr2.id,
    COALESCE(
      (
        SELECT jsonb_agg(to_jsonb(value) ORDER BY ord)
        FROM jsonb_array_elements_text(sr2.actions) WITH ORDINALITY AS elems(value, ord)
        WHERE trim(value) NOT ILIKE 'Check the parts'
      ),
      '[]'::jsonb
    ) AS cleaned
  FROM public.service_rules sr2
  WHERE jsonb_typeof(sr2.actions) = 'array'
    AND EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(sr2.actions) AS z(t)
      WHERE trim(t) ILIKE 'Check the parts'
    )
) sub
WHERE sr.id = sub.id;

-- Remove "Offer booking link" from stored action lists (no longer a default).
UPDATE public.service_rules sr
SET actions = sub.cleaned
FROM (
  SELECT
    sr2.id,
    COALESCE(
      (
        SELECT jsonb_agg(to_jsonb(value) ORDER BY ord)
        FROM jsonb_array_elements_text(sr2.actions) WITH ORDINALITY AS elems(value, ord)
        WHERE trim(value) NOT ILIKE 'Offer booking link'
      ),
      '[]'::jsonb
    ) AS cleaned
  FROM public.service_rules sr2
  WHERE jsonb_typeof(sr2.actions) = 'array'
    AND EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(sr2.actions) AS z(t)
      WHERE trim(t) ILIKE 'Offer booking link'
    )
) sub
WHERE sr.id = sub.id;
