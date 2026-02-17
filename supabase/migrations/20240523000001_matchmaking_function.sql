CREATE OR REPLACE FUNCTION public.find_match(user_id uuid)
RETURNS TABLE (
  room_id text,
  matched_user_id uuid
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_interests text[];
  v_match_record RECORD;
  v_room_id text;
BEGIN
  -- Get current user's interests
  SELECT interests INTO v_interests FROM public.profiles WHERE id = user_id;

  -- Ensure the user is searching
  UPDATE public.profiles SET is_searching = true WHERE id = user_id;

  -- Find a potential match
  -- Logic: 
  -- 1. Must be searching (is_searching = true)
  -- 2. Must not be the current user
  -- 3. Should share at least one interest (using array intersection operator &&)
  -- Limit to 1
  SELECT id INTO v_match_record
  FROM public.profiles
  WHERE is_searching = true
    AND id != user_id
    AND (interests && v_interests) -- Overlap operator for arrays
  LIMIT 1
  FOR UPDATE SKIP LOCKED; -- Lock the row to prevent race conditions

  IF FOUND THEN
    -- Generate a unique room ID
    v_room_id := encode(gen_random_bytes(16), 'hex');

    -- Create a match record
    INSERT INTO public.matches (user_1, user_2, room_id)
    VALUES (user_id, v_match_record.id, v_room_id);

    -- Set both users to not searching
    UPDATE public.profiles
    SET is_searching = false
    WHERE id IN (user_id, v_match_record.id);

    RETURN QUERY SELECT v_room_id, v_match_record.id;
  ELSE
    -- No match found immediately, user remains in searching state
    RETURN;
  END IF;
END;
$$;
