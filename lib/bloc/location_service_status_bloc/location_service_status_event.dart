part of 'location_service_status_bloc.dart';


sealed class LocationServiceStatusEvent {
  const LocationServiceStatusEvent();
}

final class _LocationServiceStatusChanged extends LocationServiceStatusEvent {
  const _LocationServiceStatusChanged(this.locationServiceStatus);

  final LocationServiceStatus locationServiceStatus;
}

final class LocationServiceIsEnabled extends LocationServiceStatusEvent{
  const LocationServiceIsEnabled();
}

