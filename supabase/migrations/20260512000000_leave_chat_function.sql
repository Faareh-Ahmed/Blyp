-- Create a function to handle user leaving a chat room
-- Sets both users' is_searching to false so they must both explicitly
-- search again to be rematched.

CREATE OR REPLACE FUNCTION public.leave_chat(leaving_user_id uuid, partner_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
  -- Set both users' is_searching to false
  UPDATE public.profiles
  SET is_searching = false
  WHERE id IN (leaving_user_id, partner_id);
END;
$$;
