-- After dropping public.rule_actions and/or public.rule_conditions, triggers that still
-- reference those tables will fail when a subcategory is added (insert into service_rules).
--
-- Drops triggers on service_rules / service_subcategories whose function body mentions
-- rule_actions or rule_conditions. Keeps other triggers (e.g. set_updated_at).

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

      IF func_blob IS NOT NULL
         AND (
           lower(func_blob) LIKE '%rule_actions%'
           OR lower(func_blob) LIKE '%rule_conditions%'
         )
      THEN
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON public.%I', rec.tname, rec.ttable);
        RAISE NOTICE 'Dropped trigger % on public.% (referenced removed rule_actions/rule_conditions)', rec.tname, rec.ttable;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;
END $$;

-- If the error persists, list triggers and drop the one that syncs actions:
-- SELECT tgname FROM pg_trigger t
--   JOIN pg_class c ON t.tgrelid = c.oid
--   JOIN pg_namespace n ON c.relnamespace = n.oid
--   WHERE n.nspname = 'public' AND c.relname = 'service_rules' AND NOT t.tgisinternal;
