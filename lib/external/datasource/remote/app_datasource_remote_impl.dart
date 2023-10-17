
import 'package:dio/dio.dart';

import '../../../infra/datasource/remote/iapp_datasource_remote.dart';

class AppDataSourceRemoteImpl extends IAppDataSourceRemote {
  String? token;

  Dio get dio => _getDio();

  Dio _getDio() {
    var options = BaseOptions(
        baseUrl: BASE_URL_PROD, connectTimeout: 5000, receiveTimeout: 3000,);
    var dio = Dio(options);
    return dio;
  }

}