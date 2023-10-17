

import 'package:dio/dio.dart';
import 'package:map_bloc_teste/domain/errors/mapa_failures.dart';
import 'package:map_bloc_teste/infra/datasource/remote/imap_datasource_remote.dart';
import 'package:map_bloc_teste/infra/mapper/location_mapper.dart';
import 'package:map_bloc_teste/infra/model/location_model.dart';
import 'package:map_bloc_teste/infra/service/connectivity_service_impl.dart';

class MapDataSourceRemoteImpl extends IMapDataSourceRemote {

  MapDataSourceRemoteImpl() : super();

  @override
  Future<List<LocationModel>> getAllLocations() async {

    try {
      final response = await dio.get('uom/academico/mapa');
      return LocationMapper.apiResponseFromJson(response.data).data as List<LocationModel>;
    } on LocalizacaoMapperError {
      rethrow;
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout || e.type == DioErrorType.receiveTimeout) {
        throw LocalizacaoRequestError(message: 'A requisição ultrapassou o tempo limite.Tente novamente.', data: []);
      } else if(!await ConnectivityServiceImpl(dio: dio).isOnline()){
        throw MapaNoInternetConnection(message: 'Sem conexão com a internet. As informações podem estar desatualizadas.', data: []);
      } else if(e.type == DioErrorType.other) {
        throw LocalizacaoRequestError(message: 'Ocorreu um erro na requisição. Tente novamente mais tarde.', data: []);
      } else {
        throw LocalizacaoRequestError(message: 'Ocorreu um erro inesperado', data: []);
      }
    }
  }
}