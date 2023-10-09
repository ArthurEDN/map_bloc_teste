part of 'route_bloc.dart';


sealed class RouteEvent {
  const RouteEvent();
}

final class MakeRouteEvent extends RouteEvent{
  const MakeRouteEvent({required this.destination});
  
  final LocationEntity destination;
  
}
