-- Fix: when deleting service_rules, dependent rule_actions/rule_conditions
-- should be removed automatically. The current FKs block deletes.
--
-- The error references:
-- - rule_actions_rule_id_fkey
-- So we recreate FK constraints with ON DELETE CASCADE.

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'rule_actions_rule_id_fkey'
  ) THEN
    ALTER TABLE public.rule_actions
      DROP CONSTRAINT rule_actions_rule_id_fkey;

    ALTER TABLE public.rule_actions
      ADD CONSTRAINT rule_actions_rule_id_fkey
      FOREIGN KEY (rule_id) REFERENCES public.service_rules(id)
      ON DELETE CASCADE;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'rule_conditions_rule_id_fkey'
  ) THEN
    ALTER TABLE public.rule_conditions
      DROP CONSTRAINT rule_conditions_rule_id_fkey;

    ALTER TABLE public.rule_conditions
      ADD CONSTRAINT rule_conditions_rule_id_fkey
      FOREIGN KEY (rule_id) REFERENCES public.service_rules(id)
      ON DELETE CASCADE;
  END IF;
END $$;

