-- Fix: "new row violates row-level security policy" on chatbot_personality
-- Use explicit INSERT/UPDATE/DELETE policies (more reliable than FOR ALL with PostgREST)
-- and ensure the authenticated role can write the table.

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.chatbot_personality TO authenticated;

ALTER TABLE public.chatbot_personality ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS chatbot_personality_read ON public.chatbot_personality;
DROP POLICY IF EXISTS chatbot_personality_write ON public.chatbot_personality;
DROP POLICY IF EXISTS chatbot_personality_select ON public.chatbot_personality;
DROP POLICY IF EXISTS chatbot_personality_insert ON public.chatbot_personality;
DROP POLICY IF EXISTS chatbot_personality_update ON public.chatbot_personality;
DROP POLICY IF EXISTS chatbot_personality_delete ON public.chatbot_personality;

CREATE POLICY chatbot_personality_select
ON public.chatbot_personality
FOR SELECT
TO authenticated
USING (public.is_admin_user());

CREATE POLICY chatbot_personality_insert
ON public.chatbot_personality
FOR INSERT
TO authenticated
WITH CHECK (public.is_admin_user());

CREATE POLICY chatbot_personality_update
ON public.chatbot_personality
FOR UPDATE
TO authenticated
USING (public.is_admin_user())
WITH CHECK (public.is_admin_user());

CREATE POLICY chatbot_personality_delete
ON public.chatbot_personality
FOR DELETE
TO authenticated
USING (public.is_admin_user());
