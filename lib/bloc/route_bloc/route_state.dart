part of 'route_bloc.dart';

sealed class RouteState extends Equatable {
  const RouteState();
}

final class RouteInitialState extends RouteState {
  const RouteInitialState();

  @override
  List<Object?> get props => [];
}

final class RouteLoadingState extends RouteState {
  const RouteLoadingState();

  @override
  List<Object?> get props => [];
}

final class RouteRequestedState extends RouteState {
  final LocationEntity destination;

  const RouteRequestedState({required this.destination});

  @override
  List<Object?> get props => [destination];
}

final class OnRouteState extends RouteState {
  final LatLngEntity userPosition;
  final LocationEntity destination;

  const OnRouteState({required this.userPosition, required this.destination});

  @override
  List<Object?> get props => [userPosition, destination];
}

final class RouteEndedState extends RouteState {
  const RouteEndedState();

  @override
  List<Object?> get props => [];
}

final class RouteFailureState extends RouteState {
  final String errorMessage;

  const RouteFailureState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
