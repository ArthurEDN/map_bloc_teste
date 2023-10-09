part of 'user_position_bloc.dart';


sealed class UserPositionEvent {
  const UserPositionEvent();
}

final class UserPositionSubscriptionStarted extends UserPositionEvent{
  const UserPositionSubscriptionStarted();
}

final class UserPositionRequested extends UserPositionEvent{}

