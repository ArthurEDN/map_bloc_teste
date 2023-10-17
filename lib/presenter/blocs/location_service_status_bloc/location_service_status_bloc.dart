import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/utils/geolocator_utils.dart' as geolocator_utils;


part 'location_service_status_event.dart';
part 'location_service_status_state.dart';

enum LocationServiceStatus { unknown, disabled, enabled }

class LocationServiceStatusBloc extends Bloc<LocationServiceStatusEvent, LocationServiceStatusState> {

  LocationServiceStatus _locationServiceStatus = LocationServiceStatus.unknown;
  final Map<ServiceStatus, LocationServiceStatus> _geolocatorLocationServiceStatusMapping = {
    ServiceStatus.enabled  : LocationServiceStatus.enabled,
    ServiceStatus.disabled : LocationServiceStatus.disabled,
  };
  late final StreamSubscription<LocationServiceStatus> _locationStatusStreamSubscription;


  LocationServiceStatusBloc() : super(const LocationServiceStatusState.unknown()){
    on<LocationServiceIsEnabled>(_isServiceEnabled);
    on<_LocationServiceStatusChanged>(_onLocationServiceStatusChanged);
    _locationStatusStreamSubscription = geolocator_utils.getGeolocatorServiceStatusStream()
        .map((ServiceStatus status) => _geolocatorLocationServiceStatusMapping[status] ?? LocationServiceStatus.unknown)
        .listen((status) => add(_LocationServiceStatusChanged(status)),
    );
  }

  Future<void> _isServiceEnabled(
      LocationServiceIsEnabled event,
      Emitter<LocationServiceStatusState> emit,
  ) async {
    if(await _locationServiceIsEnabledValue){
      _locationServiceStatus = LocationServiceStatus.enabled;
      return emit(const LocationServiceStatusState.enabled());
    } else {
      _locationServiceStatus = LocationServiceStatus.disabled;
      return emit(const LocationServiceStatusState.disabled());
    }
  }

  FutureOr<void> _onLocationServiceStatusChanged(
      _LocationServiceStatusChanged event,
      Emitter<LocationServiceStatusState> emit,
  ) async {
    _locationServiceStatus = event.locationServiceStatus;
    switch (event.locationServiceStatus) {
      case LocationServiceStatus.enabled:
        return emit(const LocationServiceStatusState.enabled());
      case LocationServiceStatus.disabled:
        return emit(const LocationServiceStatusState.disabled());
      case LocationServiceStatus.unknown:
        return emit(const LocationServiceStatusState.unknown());
    }
  }

  LocationServiceStatus get locationServiceStatusValue => _locationServiceStatus;

  Future<bool> get _locationServiceIsEnabledValue async =>
      await geolocator_utils.isLocationServiceEnabled();

  @override
  Future<void> close() async{
    await _locationStatusStreamSubscription.cancel();
    return super.close();
  }

}
