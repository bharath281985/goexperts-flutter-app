import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/local_storage.dart';

/// Controls light/dark/system theme, persisted to local storage.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(_read(_storage));

  final LocalStorage _storage;

  static ThemeMode _read(LocalStorage storage) {
    final value = storage.getString(LocalStorage.kThemeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => ThemeMode.light,
    );
  }

  void setMode(ThemeMode mode) {
    _storage.setString(LocalStorage.kThemeMode, mode.name);
    emit(mode);
  }

  void toggle() => setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}
