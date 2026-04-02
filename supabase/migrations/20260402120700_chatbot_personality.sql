-- Chatbot personality prompts (admin-managed).
-- If `chatbot_personality` already exists with different columns, align the admin UI
-- (`ChatbotPersonalityView.tsx`) or add missing columns in Supabase.

CREATE TABLE IF NOT EXISTS public.chatbot_personality (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  name text,
  instructions text NOT NULL DEFAULT '',
  is_active boolean NOT NULL DEFAULT true
);

CREATE INDEX IF NOT EXISTS chatbot_personality_active_idx ON public.chatbot_personality (is_active);

ALTER TABLE public.chatbot_personality ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS chatbot_personality_read ON public.chatbot_personality;
CREATE POLICY chatbot_personality_read
ON public.chatbot_personality
FOR SELECT
TO authenticated
USING (public.is_admin_user());

DROP POLICY IF EXISTS chatbot_personality_write ON public.chatbot_personality;
CREATE POLICY chatbot_personality_write
ON public.chatbot_personality
FOR ALL
TO authenticated
USING (public.is_admin_user())
WITH CHECK (public.is_admin_user());
