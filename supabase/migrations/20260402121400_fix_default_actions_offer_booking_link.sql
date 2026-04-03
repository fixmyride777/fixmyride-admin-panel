-- Reapply 2-default trigger (no "Offer booking link") for databases that ran an older 214.
-- Safe to run multiple times.

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
