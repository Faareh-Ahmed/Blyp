-- Fix security warning by explicitly setting search_path
ALTER FUNCTION public.find_match(user_id uuid) SET search_path = public;
