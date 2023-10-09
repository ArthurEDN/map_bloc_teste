import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:map_bloc_teste/entity/location_entity.dart';
import 'package:meta/meta.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc() : super(RouteInitial()) {
    on<MakeRouteEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
