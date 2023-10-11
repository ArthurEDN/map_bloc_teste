part of 'route_bloc.dart';

sealed class RouteEvent {
  const RouteEvent();
}

final class MakeRouteEvent extends RouteEvent {
  const MakeRouteEvent({required this.destination});

  final LocationEntity destination;
}

final class _CreateRouteEvent extends RouteEvent{
  final LatLngEntity userPosition;
  final LocationEntity destination;

  const _CreateRouteEvent({required this.userPosition, required this.destination});
}

final class _RouteFailureEvent extends RouteEvent{
  final String errorMessage;
  const _RouteFailureEvent({required this.errorMessage});
}

final class EndRouteEvent extends RouteEvent {
  const EndRouteEvent();
}
