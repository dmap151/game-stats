import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/l10n_extension.dart';
import 'theme/app_theme.dart';
import 'data/database_service.dart';
import 'providers/providers.dart';
import 'services/supabase_service.dart';

import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/game_library_screen.dart';
import 'ui/screens/match_entry_screen.dart';
import 'ui/screens/players_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ui/screens/account_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase client first to detect any restored session
  String? currentUserId;
  try {
    await SupabaseService.initialize();
    currentUserId = Supabase.instance.client.auth.currentUser?.id;
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
  }

  // 2. Initialize DatabaseService with the active user's database (or guest)
  final dbService = DatabaseService();
  await dbService.init(userId: currentUserId);
  await dbService.deduplicateMatchRecords();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(dbService),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Board Game Stats',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    GameLibraryScreen(),
    PlayersScreen(),
    AccountScreen(),
  ];

  void _openMatchEntry() {
    HapticFeedback.lightImpact();
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const MatchEntryScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    // Listen for account changes (login, logout, account switch)
    ref.listen<User?>(currentUserProvider, (previous, next) async {
      if (previous?.id != next?.id) {
        final db = ref.read(databaseProvider);
        await db.switchUser(next?.id);
        ref.invalidate(matchRecordsProvider);
        ref.invalidate(playersProvider);
        ref.invalidate(gamesProvider);
        ref.invalidate(myPlayerProvider);
        ref.invalidate(myProfileProvider);
        ref.invalidate(friendsListProvider);

        // When a user logs in, automatically sync their data from the cloud
        if (next != null) {
          await ref.read(syncProvider.notifier).performSync();
        }
      }
    });

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomBar(context, theme, l10n),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: bottomPadding > 0 ? bottomPadding : 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: l10n.navDashboard,
            theme: theme,
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: l10n.navLibrary,
            theme: theme,
          ),
          _buildCenterAction(theme, l10n),
          _buildNavItem(
            index: 2,
            icon: Icons.people_outline_rounded,
            activeIcon: Icons.people_rounded,
            label: l10n.navPlayers,
            theme: theme,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: l10n.navAccount,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required ThemeData theme,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: Tooltip(
        message: label,
        child: InkResponse(
          onTap: () {
            if (_currentIndex != index) {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = index);
            }
          },
          radius: 28,
          highlightColor: activeColor.withValues(alpha: 0.1),
          splashColor: activeColor.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    size: 22,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterAction(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: l10n.enterMatchTooltip,
        child: GestureDetector(
          onTap: _openMatchEntry,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
