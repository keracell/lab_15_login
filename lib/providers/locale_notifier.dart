import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')); // default locale

  void setLocale(String localeCode) {
    state = Locale(localeCode);
  }

  void toggleLocale() {
    state =
        state.languageCode == 'en' ? const Locale('az') : const Locale('en');
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
