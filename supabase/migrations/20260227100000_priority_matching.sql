-- Update find_match function to implement priority matching
-- Logic:
-- 1. Still requires is_searching = true and not current user
-- 2. Instead of filtering by interests, we ORDER BY interest overlap
-- 3. This means if an interest match exists, it's picked first.
-- 4. If not, it falls back to any available user.

CREATE OR REPLACE FUNCTION public.find_match(user_id uuid)
RETURNS TABLE (
  room_id text,
  matched_user_id uuid
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
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

  -- Find a potential match with priority
  SELECT id INTO v_match_record
  FROM public.profiles
  WHERE is_searching = true
    AND id != user_id
  ORDER BY 
    -- Priority 1: Overlapping interests (arrays overlap)
    CASE WHEN (interests && v_interests) THEN 0 ELSE 1 END ASC,
    -- Priority 2: Randomize to avoid always picking the same waiter
    random()
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
