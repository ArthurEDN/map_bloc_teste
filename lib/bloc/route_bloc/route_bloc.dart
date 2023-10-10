import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_bloc_teste/bloc/userPosition_bloc/user_position_bloc.dart';
import 'package:map_bloc_teste/controllers/polylines_controller.dart';
import 'package:map_bloc_teste/entity/latlng_entity.dart';
import 'package:map_bloc_teste/entity/location_entity.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final UserPositionBloc _userPositionBloc;
  final PolylineController _polylineController;
  late final StreamSubscription<UserPositionState>
      _userPositionBlocSubscription;

  RouteBloc(
    this._userPositionBloc,
    this._polylineController,
  ) : super(const RouteInitialState()) {
    on<MakeRouteEvent>((event, emit) async {
      emit(RouteRequestedState(destination: event.destination));
      await emit.forEach(_userPositionBloc.stream,
          onData: (UserPositionState userPositionState) {
        if (userPositionState is UserPositionUpdatedState) {
          _polylineController.createRoutePolyline(
              LatLng(userPositionState.userPosition.latitude,
                  userPositionState.userPosition.longitude),
              LatLng(event.destination.latitude, event.destination.longitude));
          return OnRouteState(
              userPosition: userPositionState.userPosition,
              destination: event.destination);
        }
        if (userPositionState is UserPositionFailureState) {
          _polylineController.stopMakingRoute();
          return RouteFailureState(errorMessage: userPositionState.message);
        }
        return const RouteLoadingState();
      }, onError: (error, stackTrace) {
        _polylineController.stopMakingRoute();
        return RouteFailureState(errorMessage: error.toString());
      });
    });

    on<EndRouteEvent>((event, emit) {
      _polylineController.stopMakingRoute();
      emit(const RouteEndedState());
    });
  }
}
