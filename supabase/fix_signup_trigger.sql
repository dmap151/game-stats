-- ==============================================================================
-- Fix für Registrierungsfehler: "Database error saving new user (Status 500)"
-- Ausführen im Supabase Dashboard -> SQL Editor
-- ==============================================================================

-- 1. Tabelle public.profiles absichern & Permissions erteilen
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL DEFAULT 'Spieler',
    friend_code TEXT UNIQUE NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT ALL ON public.profiles TO authenticated, service_role;
GRANT SELECT ON public.profiles TO anon;

-- 2. Hilfsfunktion zur Generierung eines Freunde-Codes (mit festem search_path & SECURITY DEFINER)
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

-- 3. Trigger-Funktion: Absolut ausfallsicher mit EXCEPTION-Block & festem search_path
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

-- 4. Trigger neu anlegen
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. RLS Policies für public.profiles vervollständigen
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

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
