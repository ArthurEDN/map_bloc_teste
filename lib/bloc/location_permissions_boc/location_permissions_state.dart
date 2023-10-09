part of 'location_permissions_bloc.dart';

class LocalPermissionStatusState extends Equatable{
  final String message;
  final LocationPermissionsStatus status;

  const LocalPermissionStatusState._({
    this.message = 'Não foi possível determinar o estado das permissões',
    this.status = LocationPermissionsStatus.unableToDetermine,
  });

  const LocalPermissionStatusState.unableToDetermine() : this._();

  const LocalPermissionStatusState.denied()
      : this._(status: LocationPermissionsStatus.denied, message: 'Você precisa autorizar o acesso à localização do dispositivo.');

  const LocalPermissionStatusState.deniedForever()
      : this._(status: LocationPermissionsStatus.deniedForever, message: 'Você precisa autorizar o acesso à localização do dispositivo.');

  const LocalPermissionStatusState.whileInUse()
      : this._(status: LocationPermissionsStatus.whileInUse);

  const LocalPermissionStatusState.always()
      : this._(status: LocationPermissionsStatus.always);

  @override
  List<Object?> get props => [status];
}
