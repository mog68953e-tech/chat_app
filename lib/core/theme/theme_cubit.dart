import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

/// ThemeCubit persists Dark/Light mode preference to Hive
class ThemeCubit extends Cubit<bool> {
  final Box _settingsBox;

  ThemeCubit(this._settingsBox)
      : super(_settingsBox.get(AppConstants.themeKey, defaultValue: true));

  bool get isDarkMode => state;

  void toggleTheme() {
    final newMode = !state;
    _settingsBox.put(AppConstants.themeKey, newMode);
    emit(newMode);
  }

  void setDarkMode(bool isDark) {
    _settingsBox.put(AppConstants.themeKey, isDark);
    emit(isDark);
  }
}
