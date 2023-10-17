import 'package:map_bloc_teste/domain/errors/failure.dart';

class LocalizacaoNoDataFound extends NoDataFound {
  LocalizacaoNoDataFound({required String message}) : super(message: message);
}

class MapaNoInternetConnection extends NoInternetConnection {
  MapaNoInternetConnection({required String message, required List data}) : super(message: message, data: data);
}

class LocalizacaoRequestError extends RequestError {
  LocalizacaoRequestError({required String message, required List data}) : super(message: message, data: data);
}

class LocalizacaoDatabaseInsertError extends DatabaseError {
  LocalizacaoDatabaseInsertError({required String message}) : super(message: message);
}

class LocalizacaoDatabaseGetError extends DatabaseError {
  LocalizacaoDatabaseGetError({required String message}) : super(message: message);
}

class LocalizacaoDatabaseUpdateError extends DatabaseError {
  LocalizacaoDatabaseUpdateError({required String message}) : super(message: message);
}

class LocalizacaoDatabaseDeleteError extends DatabaseError {
  LocalizacaoDatabaseDeleteError({required String message}) : super(message: message);
}

class LocalizacaoMapperError extends MapperError {
  LocalizacaoMapperError({required String message}) : super(message: message);
}

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
