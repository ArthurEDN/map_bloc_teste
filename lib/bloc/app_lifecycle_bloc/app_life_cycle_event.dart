part of 'app_life_cycle_bloc.dart';

sealed class AppLifeCycleEvent {
  const AppLifeCycleEvent();
}

final class AppLifeCycleStarted extends AppLifeCycleEvent{
  const AppLifeCycleStarted();
}

final class _LifeCycleChanged extends AppLifeCycleEvent{
  final AppLifecycleState appLifecycleStateStatus;

  const _LifeCycleChanged(this.appLifecycleStateStatus);
}
