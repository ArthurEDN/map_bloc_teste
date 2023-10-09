part of 'user_position_bloc.dart';

sealed class UserPositionState extends Equatable{
  const UserPositionState();
}

final class UserPositionInitialState extends UserPositionState {
  const UserPositionInitialState();

  @override
  List<Object?> get props => [];
}

final class UserPositionLoadingState extends UserPositionState{
  const UserPositionLoadingState();
  @override
  List<Object?> get props => [];
}

final class UserPositionUpdatedState extends UserPositionState{
    const UserPositionUpdatedState({required this.userPosition});

    final LatLngEntity userPosition;

    @override
    List<Object?> get props => [userPosition];
}

final class UserPositionFailureState extends UserPositionState{
  const UserPositionFailureState({required this.userPositionException, required this.message});

  final Exception userPositionException;
  final String message;

  @override
  List<Object?> get props => [message];
}


