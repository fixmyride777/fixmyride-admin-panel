-- Fix: FK is on service_rules.subcategory_id, but handle_delete_service_subcategory()
-- was deleting by OLD.code (subcategory_code). Update function to also delete by
-- OLD.id when subcategory_id column exists.

CREATE OR REPLACE FUNCTION public.handle_delete_service_subcategory()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- If service_rules has an id-based FK, delete rows using OLD.id.
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'service_rules'
      AND column_name = 'subcategory_id'
  ) THEN
    EXECUTE 'DELETE FROM public.service_rules WHERE subcategory_id = $1'
    USING OLD.id;
  END IF;

  -- Fallback cleanup for schemas keyed by code.
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'service_rules'
      AND column_name = 'subcategory_code'
  ) THEN
    EXECUTE 'DELETE FROM public.service_rules WHERE subcategory_code = $1'
    USING OLD.code;
  END IF;

  RETURN OLD;
END;
$$;

