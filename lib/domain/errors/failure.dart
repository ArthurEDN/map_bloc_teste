abstract class Failure implements Exception {
  String get message;
}

class RemoteConnectionError extends Failure {
  @override
  final String message;
  List<dynamic> data = [];

  RemoteConnectionError({required this.message, required this.data});
}

class UnknownError extends Failure {
  @override
  final String message;
  UnknownError({required this.message});
}

class MapperError extends Failure {
  @override
  final String message;
  MapperError({required this.message});
}

class NoInternetConnection extends RemoteConnectionError {

  NoInternetConnection({required String message, required List data}) : super(message: message, data: data);
}

class RequestError extends RemoteConnectionError {
  RequestError({required String message, required List data}) : super(message: message, data: data);
}

class NoDataFound extends Failure {
  @override
  final String message;

  NoDataFound({required this.message});
}

class DatabaseError extends Failure {
  @override
  final String message;

  DatabaseError({required this.message});
}

class FlowException extends Failure {
  @override
  final String message;
  List<dynamic> data = [];

  FlowException({required this.message, required this.data});
}


