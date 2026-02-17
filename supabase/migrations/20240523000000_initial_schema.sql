-- Create profiles table
CREATE TABLE public.profiles (
  id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  username text,
  interests text[],
  is_searching boolean DEFAULT false,
  PRIMARY KEY (id)
);

-- Enable Row Level Security (RLS) for privacy
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for profiles
-- Allow users to view their own profile and others (for matching purposes later, we might refine this)
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);


-- Create matches table
CREATE TABLE public.matches (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_1 uuid REFERENCES public.profiles(id) NOT NULL,
  user_2 uuid REFERENCES public.profiles(id) NOT NULL,
  room_id text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;

-- Create policies for matches
-- Users can only see matches they are part of
CREATE POLICY "Users can view their own matches" ON public.matches FOR SELECT USING (auth.uid() = user_1 OR auth.uid() = user_2);
-- Function will insert matches, so users might not need direct insert access if using stored procedure.
-- But for now, we can allow authenticated users to insert if they are one of the participants (though strictly, the system should do this).
-- Let's keep it restricted for now and rely on the function (SECURITY DEFINER).
