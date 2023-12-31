import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_bloc_teste/domain/entities/latlng_entity.dart';
import 'package:map_bloc_teste/domain/errors/mapa_failures.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/utils/geolocator_utils.dart' as geolocator_utils;

part 'user_position_event.dart';
part 'user_position_state.dart';

class UserPositionBloc extends Bloc<UserPositionEvent, UserPositionState> {
  LatLngEntity? _lastUserPosition;

  late StreamSubscription<LatLngEntity>? _userPositionSubscription;

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
          if (error is LocationServiceDisabledException) {
            return UserPositionFailureState(
              userPositionException: LocationServiceDisabledCustomException(),
              errorMessage: 'O serviço de localização no dispositivo está desativado.',
            );
          }
          if (error is PermissionDeniedException) {
            return UserPositionFailureState(
              userPositionException: PermissionsDeniedCustomException(),
              errorMessage: 'O acesso à localização do dispositivo foi negada.',
            );
          }
          return UserPositionFailureState(
            userPositionException: LocationRetrieveCustomException(),
            errorMessage: 'Ocorreu um erro no serviço de localização.',
          );
        },
      );
    });
  }

  LatLngEntity? get lastUserPosition => _lastUserPosition;

  @override
  Future<void> close() async {
    _userPositionSubscription?.cancel();
    return super.close();
  }
}
