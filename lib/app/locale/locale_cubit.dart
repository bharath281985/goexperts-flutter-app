import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_storage.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._storage)
    : super(Locale(_storage.getString(LocalStorage.kLocale) ?? 'en'));

  final LocalStorage _storage;

  Future<void> setLanguage(String code) async {
    final value = code.trim().toLowerCase();
    if (value.isEmpty) return;
    await _storage.setString(LocalStorage.kLocale, value);
    emit(Locale(value));
  }
}
