-- If you already applied 20260402121100 before it checked rule_conditions, run this to
-- drop triggers that still reference the removed rule_conditions table.
-- Safe to run on any project: re-scans and only drops matching triggers.

DO $$
DECLARE
  rec record;
  func_blob text;
BEGIN
  FOR rec IN
    SELECT t.tgname AS tname, c.relname AS ttable
    FROM pg_trigger t
    INNER JOIN pg_class c ON t.tgrelid = c.oid
    INNER JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = 'public'
      AND c.relname IN ('service_rules', 'service_subcategories')
      AND NOT t.tgisinternal
  LOOP
    BEGIN
      SELECT pg_get_functiondef(p.oid) INTO func_blob
      FROM pg_trigger t
      INNER JOIN pg_proc p ON t.tgfoid = p.oid
      INNER JOIN pg_class c ON t.tgrelid = c.oid
      INNER JOIN pg_namespace n ON c.relnamespace = n.oid
      WHERE n.nspname = 'public'
        AND c.relname = rec.ttable
        AND t.tgname = rec.tname
        AND NOT t.tgisinternal;

      IF func_blob IS NOT NULL AND lower(func_blob) LIKE '%rule_conditions%' THEN
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON public.%I', rec.tname, rec.ttable);
        RAISE NOTICE 'Dropped trigger % on public.% (referenced rule_conditions)', rec.tname, rec.ttable;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;
END $$;
