import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/utils/geolocator_utils.dart' as geolocator_utils;

part 'location_permissions_event.dart';
part 'location_permissions_state.dart';

enum LocationPermissionsStatus {
  denied,
  deniedForever,
  whileInUse,
  always,
  unableToDetermine;
}

class LocationPermissionsBloc extends Bloc<LocationPermissionsEvent, LocalPermissionStatusState> {
  LocationPermissionsStatus _locationPermission = LocationPermissionsStatus.unableToDetermine;
  final Map<LocationPermission, LocationPermissionsStatus> _geolocatorLocationPermissionsStatusMapping = {
    LocationPermission.denied              : LocationPermissionsStatus.denied           ,
    LocationPermission.deniedForever       : LocationPermissionsStatus.deniedForever    ,
    LocationPermission.always              : LocationPermissionsStatus.always           ,
    LocationPermission.whileInUse          : LocationPermissionsStatus.whileInUse       ,
    LocationPermission.unableToDetermine   : LocationPermissionsStatus.unableToDetermine,
  };

  LocationPermissionsBloc() : super(const LocalPermissionStatusState.unableToDetermine()) {
    on<LocationPermissionsFirstCheckEvent>((event, emit) async {
      _locationPermission = _geolocatorLocationPermissionsStatusMapping[await _locationPermissionsValue]!;
      if (_locationPermission == LocationPermissionsStatus.denied) {
        _locationPermission = _geolocatorLocationPermissionsStatusMapping[await _requestPermissionsValue]!;
      }
      return emit(_onLocationPermissionsStatusChanged(_locationPermission));
    });
    on<LocationPermissionsCheckedEvent>(_checkLocationPermissions);
  }

  Future<void> _checkLocationPermissions(
      LocationPermissionsCheckedEvent event,
      Emitter<LocalPermissionStatusState> emit,
  ) async {
    // _locationPermission = await _locationPermissionsValue;
    // if (_locationPermission == LocationPermission.denied) {
    //   _locationPermission = await _requestPermissionsValue ;
    //   return emit(_onLocationPermissionsStatusChanged(_locationPermission!));
    // }
    _locationPermission = _geolocatorLocationPermissionsStatusMapping[await _locationPermissionsValue]!;
    return emit(_onLocationPermissionsStatusChanged(_locationPermission));
  }

  LocalPermissionStatusState _onLocationPermissionsStatusChanged(LocationPermissionsStatus locationPermission){
    switch (locationPermission) {
      case LocationPermissionsStatus.denied:
        return const LocalPermissionStatusState.denied();
      case LocationPermissionsStatus.deniedForever:
        return const LocalPermissionStatusState.deniedForever();
      case LocationPermissionsStatus.whileInUse:
        return const LocalPermissionStatusState.whileInUse();
      case LocationPermissionsStatus.always:
        return const LocalPermissionStatusState.always();
      case LocationPermissionsStatus.unableToDetermine:
        return const LocalPermissionStatusState.unableToDetermine();
    }
  }

  LocationPermissionsStatus get locationPermission => _locationPermission;

  Future<LocationPermission> get _locationPermissionsValue async =>
      await geolocator_utils.checkLocationPermissions();

  Future<LocationPermission> get _requestPermissionsValue async =>
      await geolocator_utils.getGeolocatorInstance().requestPermission();

}
