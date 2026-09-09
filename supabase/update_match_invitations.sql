-- ==============================================================================
-- Match-Einladungen für verlinkte Freunde: invitation_status & RLS Updates
-- Ausführen im Supabase Dashboard -> SQL Editor
-- ==============================================================================

-- 1. Spalte invitation_status zu match_player_scores hinzufügen
-- Standardmäßig 'accepted' (für Ersteller und bestehende Einträge)
ALTER TABLE public.match_player_scores 
ADD COLUMN IF NOT EXISTS invitation_status TEXT NOT NULL DEFAULT 'accepted';

-- 2. Performance-Index für Abfragen nach Einladungen
CREATE INDEX IF NOT EXISTS idx_match_player_scores_invitation 
ON public.match_player_scores(linked_user_id, invitation_status);

-- 3. Hilfsfunktion zur Vermeidung von RLS-Rekursion aktualisieren:
-- Abgelehnte Partien ('declined') werden dem Teilnehmer nicht mehr angezeigt
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

-- 4. RLS UPDATE Policy für match_player_scores aktualisieren:
-- Der Match-Owner ODER der verlinkte Teilnehmer (linked_user_id) darf seinen Score / Einladungsstatus aktualisieren!
DROP POLICY IF EXISTS "Users can update match scores" ON public.match_player_scores;
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

-- 5. Stored Procedure mit SECURITY DEFINER für 100% zuverlässige Annahme / Ablehnung
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
