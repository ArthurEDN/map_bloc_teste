part of 'location_permissions_bloc.dart';

sealed class LocationPermissionsEvent {
  const LocationPermissionsEvent();
}

final class LocationPermissionsFirstCheckEvent extends LocationPermissionsEvent{
  const LocationPermissionsFirstCheckEvent();
}

final class LocationPermissionsCheckedEvent extends LocationPermissionsEvent{
  const LocationPermissionsCheckedEvent();
}
