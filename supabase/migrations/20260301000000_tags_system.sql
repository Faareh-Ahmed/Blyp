CREATE TABLE public.tags (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text UNIQUE NOT NULL,
    usage_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE INDEX tags_usage_count_idx ON public.tags(usage_count DESC);

-- Enable RLS
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Tags are viewable by everyone" ON public.tags FOR SELECT USING (true);
CREATE POLICY "Users can insert tags" ON public.tags FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update tags" ON public.tags FOR UPDATE USING (true); -- allowed for upserts

-- Trigger to keep tag usage count synchronized with profiles.interests
CREATE OR REPLACE FUNCTION update_tags_usage()
RETURNS TRIGGER AS $$
DECLARE
    added_tags text[];
    removed_tags text[];
BEGIN
    IF TG_OP = 'INSERT' THEN
        added_tags := COALESCE(NEW.interests, '{}'::text[]);
        removed_tags := '{}'::text[];
    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.interests IS NULL AND OLD.interests IS NULL THEN
            RETURN NEW;
        END IF;
        
        added_tags := ARRAY(
            SELECT unnest(COALESCE(NEW.interests, '{}'::text[]))
            EXCEPT
            SELECT unnest(COALESCE(OLD.interests, '{}'::text[]))
        );
        
        removed_tags := ARRAY(
            SELECT unnest(COALESCE(OLD.interests, '{}'::text[]))
            EXCEPT
            SELECT unnest(COALESCE(NEW.interests, '{}'::text[]))
        );
    ELSIF TG_OP = 'DELETE' THEN
        added_tags := '{}'::text[];
        removed_tags := COALESCE(OLD.interests, '{}'::text[]);
    END IF;

    -- Decrement usage count
    IF array_length(removed_tags, 1) > 0 THEN
        UPDATE public.tags
        SET usage_count = GREATEST(usage_count - 1, 0)
        WHERE name = ANY(removed_tags);
    END IF;

    -- Increment or Insert usage count
    IF array_length(added_tags, 1) > 0 THEN
        INSERT INTO public.tags (name, usage_count)
        SELECT tag, 1
        FROM unnest(added_tags) AS t(tag)
        ON CONFLICT (name) DO UPDATE
        SET usage_count = public.tags.usage_count + 1;
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_profile_interests_change
AFTER INSERT OR UPDATE OF interests OR DELETE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION update_tags_usage();
