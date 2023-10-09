import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'app_life_cycle_event.dart';
part 'app_life_cycle_state.dart';

class AppLifeCycleBloc extends Bloc<AppLifeCycleEvent, AppLifeCycleStatusState> with WidgetsBindingObserver {
  AppLifeCycleBloc() : super(const AppLifeCycleStatusState.resumed()) {
    on<AppLifeCycleStarted>((event, emit) {
      WidgetsBinding.instance.addObserver(this);
    });
    on<_LifeCycleChanged>(_onAppLifeCycleStateChanged);
  }

  FutureOr<void> _onAppLifeCycleStateChanged(
      _LifeCycleChanged event,
      Emitter<AppLifeCycleStatusState> emit,
  ) async {
    switch (event.appLifecycleStateStatus) {
      case AppLifecycleState.detached:
        return emit(const AppLifeCycleStatusState.detached());
      case AppLifecycleState.resumed:
        return emit(const AppLifeCycleStatusState.resumed());
      case AppLifecycleState.inactive:
        return emit(const AppLifeCycleStatusState.inactive());
      case AppLifecycleState.hidden:
        return emit(const AppLifeCycleStatusState.hidden());
      case AppLifecycleState.paused:
        return emit(const AppLifeCycleStatusState.paused());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("AppLifecycleState $state");
    add(_LifeCycleChanged(state));
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
