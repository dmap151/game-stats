-- ==============================================================================
-- Game Stats: Supabase Database Schema with Row Level Security (RLS)
-- Ausführen im Supabase Dashboard -> SQL Editor
-- ==============================================================================

-- 1. Games Tabelle
CREATE TABLE IF NOT EXISTS public.games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid(),
    local_id BIGINT,
    name TEXT NOT NULL,
    min_players INT DEFAULT 1,
    max_players INT,
    image_url TEXT,
    notes TEXT,
    bgg_id INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Players Tabelle
CREATE TABLE IF NOT EXISTS public.players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid(),
    local_id BIGINT,
    name TEXT NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Matches Tabelle
CREATE TABLE IF NOT EXISTS public.matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid(),
    local_id BIGINT,
    game_id UUID REFERENCES public.games(id) ON DELETE SET NULL,
    game_name TEXT NOT NULL,
    date TIMESTAMPTZ NOT NULL DEFAULT now(),
    duration_minutes INT NOT NULL DEFAULT 0,
    location_name TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Match Player Scores (Ergebnisse pro Spieler)
CREATE TABLE IF NOT EXISTS public.match_player_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
    player_id UUID REFERENCES public.players(id) ON DELETE SET NULL,
    player_name TEXT NOT NULL,
    score DOUBLE PRECISION NOT NULL DEFAULT 0,
    is_winner BOOLEAN NOT NULL DEFAULT false,
    rank INT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==============================================================================
-- Indizes für schnelle Abfragen
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_games_user_id ON public.games(user_id);
CREATE INDEX IF NOT EXISTS idx_players_user_id ON public.players(user_id);
CREATE INDEX IF NOT EXISTS idx_matches_user_id ON public.matches(user_id);
CREATE INDEX IF NOT EXISTS idx_match_player_scores_match_id ON public.match_player_scores(match_id);

-- ==============================================================================
-- Row Level Security (RLS) aktivieren & Policies anlegen
-- ==============================================================================
ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.match_player_scores ENABLE ROW LEVEL SECURITY;

-- Games: Jeder Nutzer darf nur seine eigenen Spiele lesen, einfügen, bearbeiten und löschen
DROP POLICY IF EXISTS "Users can manage their own games" ON public.games;
CREATE POLICY "Users can manage their own games"
    ON public.games FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Players: Nur eigene Spieler
DROP POLICY IF EXISTS "Users can manage their own players" ON public.players;
CREATE POLICY "Users can manage their own players"
    ON public.players FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Matches & Match Player Scores Helper Functions (Vermeidung von RLS-Rekursion)
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

-- Matches: Eigene Partien & Partien als verknüpfter Teilnehmer
DROP POLICY IF EXISTS "Users can manage their own matches" ON public.matches;
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

-- Match Player Scores: Zugriff über Besitzer oder verknüpften Teilnehmer
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
    USING (public.get_match_owner(match_id) = auth.uid())
    WITH CHECK (public.get_match_owner(match_id) = auth.uid());

CREATE POLICY "Users can delete match scores"
    ON public.match_player_scores FOR DELETE
    TO authenticated
    USING (public.get_match_owner(match_id) = auth.uid());
