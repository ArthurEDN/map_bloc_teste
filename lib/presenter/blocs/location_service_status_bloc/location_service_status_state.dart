part of 'location_service_status_bloc.dart';


class LocationServiceStatusState extends Equatable{

  final LocationServiceStatus status;

  const LocationServiceStatusState._({
    this.status = LocationServiceStatus.unknown,
  });

  const LocationServiceStatusState.unknown() : this._();

  const LocationServiceStatusState.enabled()
      : this._(status: LocationServiceStatus.enabled);

  const LocationServiceStatusState.disabled()
      : this._(status: LocationServiceStatus.disabled);

  @override
  List<Object?> get props => [status];
}

