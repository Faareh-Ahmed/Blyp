-- Enable realtime for matches table so users can subscribe to new matches
alter publication supabase_realtime add table public.matches;
