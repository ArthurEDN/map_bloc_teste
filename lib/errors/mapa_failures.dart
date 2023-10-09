
class LocationRetrieveCustomException implements Exception {
  final String? message;

  LocationRetrieveCustomException({this.message});

  @override
  String toString() {
    if (message == null || message == '') {
      return 'Ocorreu um erro no serviço de localização.';
    }
    return message!;
  }
}

class LocationServiceDisabledCustomException implements Exception {
  final String? message;

  LocationServiceDisabledCustomException({this.message});

  @override
  String toString() {
    if (message == null || message == '') {
      return 'O serviço de localização no dispositivo está desabilitado.';
    }
    return message!;
  }
}

class PermissionsDeniedCustomException implements Exception {
  final String? message;

  PermissionsDeniedCustomException({this.message});

  @override
  String toString(){
    if (message == null || message == '') {
      return 'O acesso à localização do dispositivo foi negada pelo usuário.';
    }
    return message!;
  }
}
