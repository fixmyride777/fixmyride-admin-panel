-- Fix: foreign key on service_rules prevents deleting service_subcategories.
-- The existing trigger deletes service_rules only in an AFTER DELETE trigger,
-- which is too late for the FK constraint check on some configurations.
-- Recreate the trigger as BEFORE DELETE so dependent service_rules rows are
-- removed before Postgres evaluates the FK constraint.

DROP TRIGGER IF EXISTS on_service_subcategory_deleted ON public.service_subcategories;

CREATE TRIGGER on_service_subcategory_deleted
  BEFORE DELETE ON public.service_subcategories
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_delete_service_subcategory();

