-- ==============================================================================
-- Game Stats: Supabase Storage Setup für Partiefotos
-- Ausführen im Supabase Dashboard -> SQL Editor
-- ==============================================================================

-- 1. Tabellenspalten für Bild-URLs in public.matches ergänzen
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS image_urls JSONB DEFAULT '[]'::jsonb;

-- 2. Storage Bucket "match-images" anlegen (öffentlich lesbar)
INSERT INTO storage.buckets (id, name, public)
VALUES ('match-images', 'match-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 3. Storage RLS Policies für match-images
DROP POLICY IF EXISTS "Public or Authenticated Read Match Images" ON storage.objects;
DROP POLICY IF EXISTS "Users Can Upload Match Images" ON storage.objects;
DROP POLICY IF EXISTS "Users Can Update Their Own Match Images" ON storage.objects;
DROP POLICY IF EXISTS "Users Can Delete Their Own Match Images" ON storage.objects;

-- Leserecht: Alle authentifizierten Nutzer (und anonym für geteilte URLs)
CREATE POLICY "Public or Authenticated Read Match Images"
ON storage.objects FOR SELECT
TO authenticated, anon
USING (bucket_id = 'match-images');

-- Schreibrecht: Nutzer dürfen nur in ihren eigenen Ordner (<user_id>/...) hochladen
CREATE POLICY "Users Can Upload Match Images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'match-images'
    AND (auth.uid()::text = (storage.foldername(name))[1])
);

-- Aktualisieren: Nur eigene Bilder
CREATE POLICY "Users Can Update Their Own Match Images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'match-images'
    AND (auth.uid()::text = (storage.foldername(name))[1])
);

-- Löschen: Nur eigene Bilder
CREATE POLICY "Users Can Delete Their Own Match Images"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'match-images'
    AND (auth.uid()::text = (storage.foldername(name))[1])
);
