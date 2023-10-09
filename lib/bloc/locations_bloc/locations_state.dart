import 'package:map_bloc_teste/entity/latlng_entity.dart';

import '../../entity/location_entity.dart';

sealed class LocationsState {
  const LocationsState();
}

final class LocationsInitialState extends LocationsState {
  const LocationsInitialState();
}

final class LocationsSuccessState extends LocationsState {
  final List<LocationEntity> locations;

  const LocationsSuccessState({required this.locations});
}

final class LocationsFailureState extends LocationsState {
  final String errorMessage;
  final List<LocationEntity> locations;

  const LocationsFailureState({required this.errorMessage, required this.locations});
}
