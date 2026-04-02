-- Ensure new subcategory rules get exactly 3 default actions (no "Check the parts").
-- Also strip "Check the parts" from existing service_rules.actions arrays.

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
      'Explain the price to customer',
      'Offer booking link'
    )
  )
  ON CONFLICT (category_code, subcategory_code)
  DO UPDATE SET
    category_code = EXCLUDED.category_code,
    title = EXCLUDED.title,
    is_active = EXCLUDED.is_active,
    description = COALESCE(public.service_rules.description, EXCLUDED.description),
    actions = COALESCE(public.service_rules.actions, EXCLUDED.actions);

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
      FROM jsonb_array_elements_text(sr2.actions) AS e(value)
      WHERE trim(value) ILIKE 'Check the parts'
    )
) sub
WHERE sr.id = sub.id;
