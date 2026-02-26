-- Fix function not finding pgcrypto extension functions by adding extensions to search_path
ALTER FUNCTION public.find_match(user_id uuid) SET search_path = public, extensions;
