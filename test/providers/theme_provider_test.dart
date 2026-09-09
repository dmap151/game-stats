import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ThemeModeNotifier starts with ThemeMode.system by default', () {
    final notifier = ThemeModeNotifier();
    expect(notifier.state, ThemeMode.system);
  });

  test('ThemeModeNotifier loads saved theme mode from SharedPreferences on start', () async {
    SharedPreferences.setMockInitialValues({'selected_theme_mode': 'dark'});
    final notifier = ThemeModeNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(notifier.state, ThemeMode.dark);
  });

  test('ThemeModeNotifier setThemeMode updates state and saves to SharedPreferences', () async {
    final notifier = ThemeModeNotifier();
    await notifier.setThemeMode(ThemeMode.light);
    expect(notifier.state, ThemeMode.light);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_theme_mode'), 'light');

    await notifier.setThemeMode(ThemeMode.dark);
    expect(notifier.state, ThemeMode.dark);
    expect(prefs.getString('selected_theme_mode'), 'dark');

    await notifier.setThemeMode(ThemeMode.system);
    expect(notifier.state, ThemeMode.system);
    expect(prefs.getString('selected_theme_mode'), 'system');
  });
}
