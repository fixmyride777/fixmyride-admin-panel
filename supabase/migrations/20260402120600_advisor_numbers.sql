-- Advisor phone numbers (admin panel CRUD).
-- If `advisor_numbers` already existed with a different shape, align column names
-- with the admin UI (`name`, `phone_number`, `is_active`) or adjust the React view.

CREATE TABLE IF NOT EXISTS public.advisor_numbers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  name text,
  phone_number text NOT NULL,
  is_active boolean NOT NULL DEFAULT true
);

CREATE INDEX IF NOT EXISTS advisor_numbers_created_at_idx ON public.advisor_numbers (created_at DESC);

ALTER TABLE public.advisor_numbers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS advisor_numbers_read ON public.advisor_numbers;
CREATE POLICY advisor_numbers_read
ON public.advisor_numbers
FOR SELECT
TO authenticated
USING (public.is_admin_user());

DROP POLICY IF EXISTS advisor_numbers_write ON public.advisor_numbers;
CREATE POLICY advisor_numbers_write
ON public.advisor_numbers
FOR ALL
TO authenticated
USING (public.is_admin_user())
WITH CHECK (public.is_admin_user());
