-- Subcategory list and forms use `price` (free-form text, often a numeric amount in AED).
ALTER TABLE public.service_subcategories
  ADD COLUMN IF NOT EXISTS price text;

COMMENT ON COLUMN public.service_subcategories.price IS 'Optional price or pricing note (text); admin UI formats plain numbers as AED.';
