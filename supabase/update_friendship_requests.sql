-- ==============================================================================
-- Update für Freundschaftsanfragen: "pending" Status & RLS UPDATE Policy
-- Ausführen im Supabase Dashboard -> SQL Editor
-- ==============================================================================

-- 1. Default-Wert für status auf 'pending' ändern
ALTER TABLE public.friendships 
ALTER COLUMN status SET DEFAULT 'pending';

-- 2. Performance-Indizes für das Filtern nach Status
CREATE INDEX IF NOT EXISTS idx_friendships_friend_status ON public.friendships(friend_id, status);
CREATE INDEX IF NOT EXISTS idx_friendships_user_status ON public.friendships(user_id, status);

-- 3. RLS UPDATE Policy hinzufügen:
-- Empfänger (friend_id) darf den Status der Anfrage aktualisieren (z.B. von 'pending' auf 'accepted')
-- Sender (user_id) darf ebenfalls aktualisieren, falls benötigt
DROP POLICY IF EXISTS "Users can update friendships" ON public.friendships;
CREATE POLICY "Users can update friendships"
    ON public.friendships FOR UPDATE
    TO authenticated
    USING (auth.uid() = friend_id OR auth.uid() = user_id)
    WITH CHECK (auth.uid() = friend_id OR auth.uid() = user_id);
