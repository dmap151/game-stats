class SupabaseConfig {
  SupabaseConfig._();

  /// The base Supabase Project URL (without /rest/v1/).
  static const String url = 'https://pvlbryzalxloadsgcjqt.supabase.co';

  /// The public/anon API key.
  static const String anonKey = 'sb_publishable_cBW7HgxjKcL_8T3EZzAnVQ_P_0YDsew';

  /// Google OAuth Web Client ID (from Google Cloud Console).
  static const String googleWebClientId =
      '859588182190-mfd4et05ooo7ip486uus639ldqpb2ma3.apps.googleusercontent.com';

  /// Deep link redirect URL for mobile auth callbacks.
  static const String authCallbackUrl = 'io.supabase.gamestats://login-callback';
}
