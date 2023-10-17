class ApiResponseModel {
  final String? message;
  final bool? success;
  final String? cause;
  final List<Object> data;

  ApiResponseModel(this.message, this.success, this.cause, this.data);
}