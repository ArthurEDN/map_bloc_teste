import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_bloc_teste/bloc/userPosition_bloc/user_position_bloc.dart';
import 'package:map_bloc_teste/controllers/markers_controller.dart';
import 'package:map_bloc_teste/controllers/polylines_controller.dart';
import 'package:map_bloc_teste/entity/latlng_entity.dart';
import 'package:map_bloc_teste/entity/location_entity.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final UserPositionBloc _userPositionBloc;
  final PolylineController _polylineController;
  final MarkersController _markersController;
  late StreamSubscription<UserPositionState>? _userPositionBlocSubscription;

  RouteBloc(
    this._userPositionBloc,
    this._polylineController,
    this._markersController
  ) : super(const RouteInitialState()) {
    on<MakeRouteEvent>((event, emit) async{
      emit(RouteRequestedState(userPosition: _userPositionBloc.lastUserPosition!, destination: event.destination,));
      _markersController.changeVisibilityOfOthersMakers(event.destination.titulo);
      _userPositionBlocSubscription = _userPositionBloc.stream.listen(
        (UserPositionState userPositionState) {
          if(userPositionState is UserPositionUpdatedState){
            add(_CreateRouteEvent(userPosition: userPositionState.userPosition, destination: event.destination));
          }
          if(userPositionState is UserPositionFailureState) {
            add(_RouteFailureEvent(errorMessage: userPositionState.message));
          }
        },
        onError: (error, stackTrace) async{
          add(const EndRouteEvent());
        }
      );
    });
    on<_CreateRouteEvent>((event, emit){
      _polylineController.createRoutePolyline(
          LatLng(event.userPosition.latitude, event.userPosition.longitude),
          LatLng(event.destination.latitude, event.destination.longitude),
      );
      return emit(OnRouteState(userPosition: event.userPosition, destination: event.destination));
    });
    on<_RouteFailureEvent>((event, emit){
      _polylineController.stopMakingRoute();
      return emit(RouteFailureState(errorMessage: event.errorMessage));
    });
    on<EndRouteEvent>((event, emit) async{
      await _stopRoute();
      return emit(const RouteEndedState());
    });
  }

  Future<void> _stopRoute() async{
    _polylineController.stopMakingRoute();
    _markersController.setMarkersVisible();
    await _userPositionBlocSubscription?.cancel();
  }

  @override
  Future<void> close() async {
    await _userPositionBlocSubscription?.cancel();
    return super.close();
  }

}
