
import 'package:map_bloc_teste/domain/entities/ApiResponseModel.dart';
import 'package:map_bloc_teste/domain/entities/location_entity.dart';
import 'package:map_bloc_teste/domain/errors/mapa_failures.dart';
import 'package:map_bloc_teste/domain/errors/failure.dart';
import 'package:map_bloc_teste/infra/model/location_model.dart';
import 'package:map_bloc_teste/infra/model/objectbox/location_model.dart';

class LocationMapper {
  static ApiResponseModel apiResponseFromJson(Map<String, dynamic> json) {
      try{
      List<LocationModel> listData = [];

      if (json['data'] != null) {
        json['data'].forEach((e) {
          listData.add(locationModelFromJson(e));
        });
      }

      ApiResponseModel model = ApiResponseModel(json['message'], json['success'], json['cause'], listData);
      return model;
    } on Failure {
        throw LocalizacaoMapperError(message: 'Erro ao converter de Json');
    }
  }


  static LocationModel locationModelFromJson (Map<String, dynamic> json) {
    try{
      LocationModel locationModel = LocationModel(
      identificador: json['identificador'],
      titulo:        json['titulo'],
      descricao:     json['descricao'],
      latitude:      json['latitude'],
      longitude:     json['longitude'],
      tipoLocal:     json['tipoLocal'],
    );
    return locationModel;
    } on Failure {
      throw LocalizacaoMapperError(message: 'Erro ao converter de Json');
    }
  }

  static Map<String, dynamic> locationModelToJson(LocationEntity location) {
    try{
      final Map<String, dynamic> json = <String, dynamic>{};
      json['identificador'] = location.identificador;
      json['titulo']        = location.titulo;
      json['descricao']     = location.descricao;
      json['latitude']      = location.latitude;
      json['longitude']     = location.longitude;
      json['tipoLocal']     = location.tipoLocal;
      return json;
    } on Failure{
      throw LocalizacaoMapperError(message: 'Erro ao converter para Json');
    }
  }

  static LocationModel locationModelFromMap(dynamic map) {
    try{
      return LocationModel(
          identificador: map['identificador'],
          titulo:        map['titulo'],
          descricao:     map['descricao'],
          latitude:      map['latitude'],
          longitude:     map['longitude'],
          tipoLocal:     map['tipoLocal']
      );
    } on Failure{
      throw LocalizacaoMapperError(message: 'Erro ao converter de Map');
    }
  }

  static Map<String, Object?> locationModelToMap(LocationEntity location) {
    try{
      return {
        'identificador': location.identificador,
        'titulo':        location.titulo,
        'descricao':     location.descricao,
        'latitude':      location.latitude,
        'longitude':     location.longitude,
        'tipoLocal':     location.tipoLocal,
      };
    } on Failure{
      throw LocalizacaoMapperError(message: 'Erro ao converter para map');
    }
  }

  static LocationModel locationModelFromObjectBox(LocationObjectBoxModel location){
    try{
      return LocationModel(
        identificador:   location.identificador as int,
        titulo:          location.titulo as String,
        descricao:       location.descricao as String,
        latitude:        location.latitude as double,
        longitude:       location.longitude as double,
        tipoLocal:       location.tipoLocal as String,
      );

    } on Failure{
      throw LocalizacaoMapperError(message: 'Error ao converter de objectbox');
    }
  }

  static LocationObjectBoxModel locationModelToObjectBox(LocationEntity locationModel){
    try{
    LocationObjectBoxModel locationObjBox  = LocationObjectBoxModel();
    locationObjBox.identificador  = locationModel.identificador;
    locationObjBox.titulo         = locationModel.titulo;
    locationObjBox.descricao      = locationModel.descricao;
    locationObjBox.latitude       = locationModel.latitude;
    locationObjBox.longitude      = locationModel.longitude;
    locationObjBox.tipoLocal      = locationModel.tipoLocal;
    return locationObjBox;
    } on Failure{
      throw LocalizacaoMapperError(message: 'Error ao converter para objectbox');
    }
  }

}