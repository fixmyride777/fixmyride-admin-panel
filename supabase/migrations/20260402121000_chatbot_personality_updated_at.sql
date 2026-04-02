-- Fixes: record "new" has no field "updated_at"
-- A BEFORE UPDATE trigger (e.g. public.set_updated_at()) expects this column.

ALTER TABLE public.chatbot_personality
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

-- Keep updated_at current on edits (same helper as service_rules, if present).
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE p.proname = 'set_updated_at' AND n.nspname = 'public'
  ) THEN
    DROP TRIGGER IF EXISTS chatbot_personality_set_updated_at ON public.chatbot_personality;
    CREATE TRIGGER chatbot_personality_set_updated_at
    BEFORE UPDATE ON public.chatbot_personality
    FOR EACH ROW
    EXECUTE PROCEDURE public.set_updated_at();
  END IF;
END $$;
