import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../network/network_info.dart';

class ConnectivityState extends Equatable {
  const ConnectivityState({this.isOnline = true});

  final bool isOnline;

  ConnectivityState copyWith({bool? isOnline}) =>
      ConnectivityState(isOnline: isOnline ?? this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit(this._networkInfo) : super(const ConnectivityState()) {
    _init();
  }

  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _sub;

  Future<void> _init() async {
    final online = await _networkInfo.isConnected;
    emit(state.copyWith(isOnline: online));
    _sub = _networkInfo.onConnectivityChanged.listen((online) {
      emit(state.copyWith(isOnline: online));
    });
  }

  Future<void> retry() async {
    final online = await _networkInfo.isConnected;
    emit(state.copyWith(isOnline: online));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
