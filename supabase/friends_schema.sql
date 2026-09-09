-- ==============================================================================
-- Game Stats: Freunde-System & Account-Verknüpfung (Supabase SQL)
-- Ausführen im Supabase Dashboard -> SQL Editor
-- ==============================================================================

-- 1. Profiles Tabelle für öffentliche Nutzerdaten & Freunde-Codes
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL DEFAULT 'Spieler',
    friend_code TEXT UNIQUE NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index für schnelle Freundesuche per Code
CREATE INDEX IF NOT EXISTS idx_profiles_friend_code ON public.profiles(friend_code);

-- 2. Hilfsfunktion zur Generierung eines Freunde-Codes (z. B. PLAY-4921)
CREATE OR REPLACE FUNCTION public.generate_unique_friend_code(user_name TEXT)
RETURNS TEXT AS $$
DECLARE
    clean_prefix TEXT;
    new_code TEXT;
    exists_already BOOLEAN;
BEGIN
    clean_prefix := UPPER(REGEXP_REPLACE(COALESCE(user_name, 'GAME'), '[^a-zA-Z]', '', 'g'));
    IF LENGTH(clean_prefix) < 3 THEN
        clean_prefix := 'PLAYER';
    ELSE
        clean_prefix := SUBSTRING(clean_prefix, 1, 4);
    END IF;

    LOOP
        new_code := '#' || clean_prefix || '-' || LPAD(FLOOR(RANDOM() * 9000 + 1000)::TEXT, 4, '0');
        SELECT EXISTS(SELECT 1 FROM public.profiles WHERE friend_code = new_code) INTO exists_already;
        EXIT WHEN NOT exists_already;
    END LOOP;

    RETURN new_code;
END;
$$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = public;

-- 3. Trigger: Profil automatisch bei Registrierung eines Nutzers anlegen
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    user_name TEXT;
    assigned_code TEXT;
BEGIN
    user_name := COALESCE(
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'name',
        SPLIT_PART(NEW.email, '@', 1),
        'Spieler'
    );
    IF user_name IS NULL OR TRIM(user_name) = '' THEN
        user_name := 'Spieler';
    END IF;

    assigned_code := public.generate_unique_friend_code(user_name);

    INSERT INTO public.profiles (id, display_name, friend_code, avatar_url)
    VALUES (
        NEW.id,
        user_name,
        assigned_code,
        NEW.raw_user_meta_data->>'avatar_url'
    )
    ON CONFLICT (id) DO NOTHING;

    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    -- Ein Fehler bei der Profil-Generierung darf NIEMALS den User-Sign-Up blockieren!
    RAISE WARNING 'handle_new_user trigger error: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Für bereits bestehende Nutzer Profile nacherstellen falls nicht vorhanden
DO $$
DECLARE
    u RECORD;
BEGIN
    FOR u IN SELECT id, email, raw_user_meta_data FROM auth.users LOOP
        IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = u.id) THEN
            INSERT INTO public.profiles (id, display_name, friend_code, avatar_url)
            VALUES (
                u.id,
                COALESCE(u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'name', SPLIT_PART(u.email, '@', 1), 'Spieler'),
                generate_unique_friend_code(SPLIT_PART(u.email, '@', 1)),
                u.raw_user_meta_data->>'avatar_url'
            );
        END IF;
    END LOOP;
END $$;

-- 4. Friendships Tabelle
CREATE TABLE IF NOT EXISTS public.friendships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    friend_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT unique_friendship UNIQUE (user_id, friend_id),
    CONSTRAINT not_self_friend CHECK (user_id <> friend_id)
);

CREATE INDEX IF NOT EXISTS idx_friendships_user_id ON public.friendships(user_id);
CREATE INDEX IF NOT EXISTS idx_friendships_friend_id ON public.friendships(friend_id);
CREATE INDEX IF NOT EXISTS idx_friendships_friend_status ON public.friendships(friend_id, status);
CREATE INDEX IF NOT EXISTS idx_friendships_user_status ON public.friendships(user_id, status);

-- 5. linked_user_id Spalte in match_player_scores hinzufügen
ALTER TABLE public.match_player_scores 
ADD COLUMN IF NOT EXISTS linked_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS invitation_status TEXT NOT NULL DEFAULT 'accepted';

CREATE INDEX IF NOT EXISTS idx_match_player_scores_linked_user ON public.match_player_scores(linked_user_id);
CREATE INDEX IF NOT EXISTS idx_match_player_scores_invitation ON public.match_player_scores(linked_user_id, invitation_status);

-- 6. Row Level Security (RLS) für Profiles & Friendships
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;

-- Profiles: Jeder angemeldete Nutzer darf Profile lesen (zum Suchen von Freunden)
GRANT ALL ON public.profiles TO authenticated, service_role;
GRANT SELECT ON public.profiles TO anon;

DROP POLICY IF EXISTS "Public profiles are viewable by authenticated users" ON public.profiles;
CREATE POLICY "Public profiles are viewable by authenticated users"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Friendships: Nutzer sehen und verwalten Freundschaften, an denen sie beteiligt sind
DROP POLICY IF EXISTS "Users can view their friendships" ON public.friendships;
CREATE POLICY "Users can view their friendships"
    ON public.friendships FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id OR auth.uid() = friend_id);

DROP POLICY IF EXISTS "Users can add friends" ON public.friendships;
CREATE POLICY "Users can add friends"
    ON public.friendships FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update friendships" ON public.friendships;
CREATE POLICY "Users can update friendships"
    ON public.friendships FOR UPDATE
    TO authenticated
    USING (auth.uid() = friend_id OR auth.uid() = user_id)
    WITH CHECK (auth.uid() = friend_id OR auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete friendships" ON public.friendships;
CREATE POLICY "Users can delete friendships"
    ON public.friendships FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id OR auth.uid() = friend_id);

-- 7. Hilfsfunktionen mit SECURITY DEFINER zur Vermeidung von RLS-Rekursion
CREATE OR REPLACE FUNCTION public.user_is_match_participant(p_match_id UUID, p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.match_player_scores
        WHERE match_id = p_match_id
        AND linked_user_id = p_user_id
        AND invitation_status <> 'declined'
    );
$$;

CREATE OR REPLACE FUNCTION public.get_match_owner(p_match_id UUID)
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
    SELECT user_id FROM public.matches WHERE id = p_match_id;
$$;

-- 8. RLS Policies für Matches (Rekursionsfrei)
DROP POLICY IF EXISTS "Users can manage their own matches" ON public.matches;
DROP POLICY IF EXISTS "Users can read own or participated matches" ON public.matches;
DROP POLICY IF EXISTS "Users can read matches" ON public.matches;
DROP POLICY IF EXISTS "Users can insert matches" ON public.matches;
DROP POLICY IF EXISTS "Users can update matches" ON public.matches;
DROP POLICY IF EXISTS "Users can delete matches" ON public.matches;

CREATE POLICY "Users can read matches"
    ON public.matches FOR SELECT
    TO authenticated
    USING (
        auth.uid() = user_id 
        OR public.user_is_match_participant(id, auth.uid())
    );

CREATE POLICY "Users can insert matches"
    ON public.matches FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update matches"
    ON public.matches FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete matches"
    ON public.matches FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- 9. RLS Policies für Match Player Scores (Rekursionsfrei)
DROP POLICY IF EXISTS "Users can manage scores of their matches" ON public.match_player_scores;
DROP POLICY IF EXISTS "Users can read match scores" ON public.match_player_scores;
DROP POLICY IF EXISTS "Users can insert match scores" ON public.match_player_scores;
DROP POLICY IF EXISTS "Users can update match scores" ON public.match_player_scores;
DROP POLICY IF EXISTS "Users can delete match scores" ON public.match_player_scores;

CREATE POLICY "Users can read match scores"
    ON public.match_player_scores FOR SELECT
    TO authenticated
    USING (
        linked_user_id = auth.uid()
        OR public.get_match_owner(match_id) = auth.uid()
    );

CREATE POLICY "Users can insert match scores"
    ON public.match_player_scores FOR INSERT
    TO authenticated
    WITH CHECK (public.get_match_owner(match_id) = auth.uid());

CREATE POLICY "Users can update match scores"
    ON public.match_player_scores FOR UPDATE
    TO authenticated
    USING (
        public.get_match_owner(match_id) = auth.uid()
        OR linked_user_id = auth.uid()
    )
    WITH CHECK (
        public.get_match_owner(match_id) = auth.uid()
        OR linked_user_id = auth.uid()
    );

CREATE OR REPLACE FUNCTION public.respond_to_match_invitation(p_score_id UUID, p_status TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_updated INT;
BEGIN
    IF p_status NOT IN ('accepted', 'declined') THEN
        RAISE EXCEPTION 'Invalid status: %', p_status;
    END IF;

    UPDATE public.match_player_scores
    SET invitation_status = p_status
    WHERE id = p_score_id
      AND linked_user_id = auth.uid();
      
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    RETURN v_updated > 0;
END;
$$;

CREATE POLICY "Users can delete match scores"
    ON public.match_player_scores FOR DELETE
    TO authenticated
    USING (public.get_match_owner(match_id) = auth.uid());

-- 10. Partiefotos Storage & Spalten
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS image_urls JSONB DEFAULT '[]'::jsonb;

INSERT INTO storage.buckets (id, name, public)
VALUES ('match-images', 'match-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "Public or Authenticated Read Match Images" ON storage.objects;
DROP POLICY IF EXISTS "Users Can Upload Match Images" ON storage.objects;
DROP POLICY IF EXISTS "Users Can Update Their Own Match Images" ON storage.objects;
DROP POLICY IF EXISTS "Users Can Delete Their Own Match Images" ON storage.objects;

CREATE POLICY "Public or Authenticated Read Match Images"
ON storage.objects FOR SELECT
TO authenticated, anon
USING (bucket_id = 'match-images');

CREATE POLICY "Users Can Upload Match Images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'match-images'
    AND (auth.uid()::text = (storage.foldername(name))[1])
);

CREATE POLICY "Users Can Update Their Own Match Images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'match-images'
    AND (auth.uid()::text = (storage.foldername(name))[1])
);

CREATE POLICY "Users Can Delete Their Own Match Images"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'match-images'
    AND (auth.uid()::text = (storage.foldername(name))[1])
);

