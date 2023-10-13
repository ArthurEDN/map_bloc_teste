part of 'user_position_bloc.dart';


sealed class UserPositionEvent {
  const UserPositionEvent();
}

final class UserPositionSubscriptionStarted extends UserPositionEvent{
  const UserPositionSubscriptionStarted();
}

final class _UserPositionOnDataEvent extends UserPositionEvent{
  const _UserPositionOnDataEvent();
}

final class _UserPositionOnErrorEvent extends UserPositionEvent{
  final Exception userPositionException;
  final String message;

  const _UserPositionOnErrorEvent({required this.userPositionException, required this.message});
}



