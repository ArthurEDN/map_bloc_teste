import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_bloc_teste/entity/latlng_entity.dart';
import 'package:map_bloc_teste/errors/mapa_failures.dart';
import 'package:map_bloc_teste/utils/geolocator_utils.dart' as geolocator_utils;

part 'user_position_event.dart';
part 'user_position_state.dart';

class UserPositionBloc extends Bloc<UserPositionEvent, UserPositionState> {
  late LatLngEntity? _lastUserPosition;

  UserPositionBloc() : super(const UserPositionInitialState()) {
    on<UserPositionSubscriptionStarted>((event, emit) async {
      emit(const UserPositionLoadingState());
      await emit.forEach(
        geolocator_utils.getGeolocatorUserPositionStream()
            .map((Position userPosition) => LatLngEntity(latitude: userPosition.latitude, longitude: userPosition.longitude)),
        onData: (LatLngEntity userPosition) {
          _lastUserPosition = userPosition;
          return UserPositionUpdatedState(userPosition: _lastUserPosition!);
        },
        onError: (error, stackTrace) {
          debugPrint(error.toString());
          debugPrint(stackTrace.toString());
          if (error is LocationServiceDisabledException) {
            return UserPositionFailureState(
              userPositionException: LocationServiceDisabledCustomException(),
              message: 'O serviço de localização no dispositivo está desativado.',
            );
          }
          if (error is PermissionDeniedException) {
            return UserPositionFailureState(
              userPositionException: PermissionsDeniedCustomException(),
              message: 'O acesso à localização do dispositivo foi negada.',
            );
          }
          return UserPositionFailureState(
            userPositionException: LocationRetrieveCustomException(),
            message: 'Ocorreu um erro no serviço de localização.',
          );
        },
      );
    });
    // on<UserPositionRequested>((event, emit){
    //   emit(const UserPositionLoadingState());
    //   if(_lastUserPosition == null){
    //     return emit(UserPositionFailureState(
    //           userPositionException: LocationRetrieveCustomException(),
    //           message: 'Ocorreu um erro ao atualizar a posição do usuário',
    //       ),
    //     );
    //   }
    //   return emit(UserPositionRequestedState(userPosition: _lastUserPosition!),);
    // });
  }

  LatLngEntity? get lastUserPosition => _lastUserPosition;

  @override
  Future<void> close() async {
    return super.close();
  }
}
