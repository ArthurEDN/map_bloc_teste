part of 'app_life_cycle_bloc.dart';

class AppLifeCycleStatusState extends Equatable{
  final AppLifecycleState lifeCycleStateStatus;

  const AppLifeCycleStatusState._({
    this.lifeCycleStateStatus = AppLifecycleState.detached,
  });

  const AppLifeCycleStatusState.detached() : this._();

  const AppLifeCycleStatusState.resumed() : this._(
    lifeCycleStateStatus: AppLifecycleState.resumed
  );

  const AppLifeCycleStatusState.inactive() : this._(
      lifeCycleStateStatus: AppLifecycleState.inactive
  );

  const AppLifeCycleStatusState.hidden() : this._(
      lifeCycleStateStatus: AppLifecycleState.hidden
  );

  const AppLifeCycleStatusState.paused() : this._(
      lifeCycleStateStatus: AppLifecycleState.paused
  );

  @override
  List<Object> get props => [lifeCycleStateStatus];
}

