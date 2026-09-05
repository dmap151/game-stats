import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('LocaleNotifier starts with null (system locale) by default', () {
    final notifier = LocaleNotifier();
    expect(notifier.state, isNull);
  });

  test('LocaleNotifier loads saved locale from SharedPreferences on start', () async {
    SharedPreferences.setMockInitialValues({'selected_locale_code': 'en'});
    final notifier = LocaleNotifier();
    // Wait for microtasks / async _loadSavedLocale to finish
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(notifier.state, const Locale('en'));
  });

  test('LocaleNotifier setLocale updates state and saves to SharedPreferences', () async {
    final notifier = LocaleNotifier();
    await notifier.setLocale(const Locale('de'));
    expect(notifier.state, const Locale('de'));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_locale_code'), 'de');

    // Setting null clears the preference and sets state to null
    await notifier.setLocale(null);
    expect(notifier.state, isNull);
    expect(prefs.containsKey('selected_locale_code'), isFalse);
  });
}
