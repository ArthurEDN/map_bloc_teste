import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_bloc_teste/blocs/user_position_bloc/user_position_bloc.dart';
import 'package:map_bloc_teste/controllers/polylines_controller.dart';
import 'package:map_bloc_teste/entities/latlng_entity.dart';
import 'package:map_bloc_teste/entities/location_entity.dart';
import 'package:map_bloc_teste/utils/google_maps_utils.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final UserPositionBloc _userPositionBloc;
  final PolylineController _polylineController;
  final Completer<GoogleMapController> _mapsController;
  final ValueNotifier<bool> _theRouteWasMake;
  late StreamSubscription<UserPositionState>? _userPositionBlocSubscription;

  RouteBloc(
    this._userPositionBloc,
    this._polylineController,
    this._mapsController,
    this._theRouteWasMake,
  ) : super(const RouteInitialState()) {
    on<MakeRouteEvent>((event, emit) async{
      emit(RouteRequestedState(destination: event.destination));
      emit(const RouteLoadingState());
      _userPositionBlocSubscription = _userPositionBloc.listenWithCurrent(
        _userPositionBloc,
        (userPositionState) {
          if(userPositionState is UserPositionInitialState){
            add(const _RouteFailureEvent(errorMessage: "Permissões não concedidas ou serviço de localização desabilitado."));
          }
          if(userPositionState is UserPositionLoadingState){
            add(const _WaitingRouteEvent());
          }
          if(userPositionState is UserPositionUpdatedState){
            add(_CreateRouteEvent(userPosition: userPositionState.userPosition, destination: event.destination));
          }
          if(userPositionState is UserPositionFailureState) {
            add(_RouteFailureEvent(errorMessage: userPositionState.errorMessage));
          }
        },
        onError: (error, stackTrace){
          add(const EndRouteEvent());
        }
      );
      _theRouteWasMake.value = true;
      await _cameraAnimationAfterMakeRoute(event.destination);
    });
    on<_CreateRouteEvent>((event, emit){
      _polylineController.createRoutePolyline(
          LatLng(event.userPosition.latitude, event.userPosition.longitude),
          LatLng(event.destination.latitude, event.destination.longitude),
      );
      return emit(OnRouteState(userPosition: event.userPosition, destination: event.destination));
    });
    on<_WaitingRouteEvent>((event, emit){
      return emit(const RouteLoadingState());
    });
    on<_RouteFailureEvent>((event, emit){
      _polylineController.stopMakingRoute();
      return emit(RouteFailureState(errorMessage: event.errorMessage));
    });
    on<EndRouteEvent>((event, emit){
      _stopRoute();
      return emit(const RouteEndedState());
    });
  }

  Future<void> _stopRoute() async{
    _polylineController.stopMakingRoute();
    _theRouteWasMake.value = false;
    _userPositionBlocSubscription?.cancel();
  }

  Future<void> _cameraAnimationAfterMakeRoute(LocationEntity destination) async{
    LatLngEntity userPosition = _userPositionBloc.lastUserPosition!;
    await goToUserLocationAfterMakeRoute(
      _mapsController,
      userPosition,
      LatLngEntity(latitude: destination.latitude, longitude: destination.longitude),
    );
  }

  @override
  Future<void> close() async {
    _userPositionBlocSubscription?.cancel();
    return super.close();
  }
}

extension ListenWithCurrentBlocState<ExtEvent, ExtState> on Bloc<ExtEvent, ExtState> {
  StreamSubscription<ExtState> listenWithCurrent<B extends Bloc<ExtEvent, ExtState>>(
      B bloc,
      void Function(ExtState state) onData, {
        Function? onError,
        void Function()? onDone,
        bool? cancelOnError,
      }) {
    onData(bloc.state);

    return bloc.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

