part of 'route_bloc.dart';

sealed class RouteState {
  const RouteState();
}

final class RouteInitialState extends RouteState {
  const RouteInitialState();
}

final class RouteRequestedState extends RouteState {
  final LocationEntity destination;
  const RouteRequestedState({required this.destination});

}

final class OnRouteState extends RouteState {
  final LatLngEntity userPosition;
  final LocationEntity destination;
  const OnRouteState({required this.userPosition, required this.destination});

}

final class RouteEndedState extends RouteState {
  const RouteEndedState();
}

final class RouteFailureState extends RouteState {
  final String errorMessage;
  const RouteFailureState({required this.errorMessage});

}
