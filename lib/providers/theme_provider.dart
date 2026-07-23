import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

/// Holds the active [ThemeMode] and persists changes via
/// `SharedPreferencesService` so the choice survives app restarts.
/// Watching this provider anywhere rebuilds `MaterialApp.router`'s
/// `themeMode`, so a change here updates the whole app immediately.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = ref.watch(sharedPreferencesServiceProvider).themeMode;
    return _fromStored(stored);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesServiceProvider).setThemeMode(mode.name);
  }

  Future<void> toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    return setThemeMode(next);
  }

  ThemeMode _fromStored(String? value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
