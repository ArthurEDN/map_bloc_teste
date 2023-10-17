import 'dart:io';
import 'package:map_bloc_teste/domain/entities/location_entity.dart';
import 'package:map_bloc_teste/domain/errors/failure.dart';
import 'package:map_bloc_teste/domain/errors/mapa_failures.dart';
import 'package:map_bloc_teste/infra/datasource/local/imap_datasource_local.dart';
import 'package:map_bloc_teste/infra/mapper/location_mapper.dart';
import 'package:map_bloc_teste/infra/model/location_model.dart';
import 'package:map_bloc_teste/infra/model/objectbox/location_model.dart';
import 'package:map_bloc_teste/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';

class MapDataSourceLocalImpl extends IMapDataSourceLocal {

  Store? _store;
  Box? _box;


  @override
  Future getBox() async {
    try {
      await getStore();
      return _box ??= _store!.box<LocationObjectBoxModel>();
    } on DatabaseError {
      rethrow;
    } on Failure {
      throw LocalizacaoDatabaseGetError(message: 'Algo deu errado durante a recuperação dos dados');
    }
  }

  @override
  Future getStore() async {
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      return _store ??= openStore(directory: "${dir.path}/localizacoes");
    } on Failure {
      throw DatabaseError(message: 'Erro ao recuperar store');
    }
  }

  @override
  Future closeStore() async {
    try {
      await getStore();
      _store!.close();
    } on DatabaseError {
      rethrow;
    } on Failure {
      throw DatabaseError(message: 'Erro ao fechar store');
    } finally {
      _box = null;
      _store = null;
    }
  }

  @override
  Future<void> insertAllLocations(List<LocationEntity> locations) async {
    try {
      await getBox();
      List<LocationObjectBoxModel> locationsObj = [];
      for (var location in locations) {
        locationsObj.add(LocationMapper.locationModelToObjectBox(location));
      }
      _box!.putMany(locationsObj);
    } on DatabaseError {
      rethrow;
    } on LocalizacaoMapperError {
      rethrow;
    } on Failure {
      throw LocalizacaoDatabaseInsertError(message: 'Algo deu errado durante a inserção no banco de dados');
    }
  }

  @override
  Future<List<LocationModel>> getAllLocations() async {
    try {
      await getBox();
      List<LocationObjectBoxModel> locationsObj = _box!.getAll() as List<LocationObjectBoxModel>;
      List<LocationModel> locations = [];
      for (var location in locationsObj) {
        locations.add(LocationMapper.locationModelFromObjectBox(location));
      }
      return locations;
    } on DatabaseError {
      rethrow;
    } on LocalizacaoMapperError {
      rethrow;
    } on Failure {
      throw LocalizacaoDatabaseGetError(message: 'Algo deu errado durante a recuperação dos dados');
    }
  }

  @override
  Future<List<LocationModel>> getLocationByName(String locationName) async{
    try {
      await getBox();
      final builder = _box!.query(
         LocationObjectBoxModel_.titulo.contains(locationName, caseSensitive: false)
      );
      final query = builder.build();
      List<LocationObjectBoxModel> locationsObj = query.find() as List<LocationObjectBoxModel>;
      query.close();
      List<LocationModel> locations = [];
      for (var location in locationsObj) {
        locations.add(
            LocationMapper.locationModelFromObjectBox(location));
      }
      return locations;
    } on DatabaseError {
      rethrow;
    } on LocalizacaoMapperError {
      rethrow;
    } on Failure {
      throw LocalizacaoDatabaseGetError(message: 'Erro ao retornar as localizações');
    }
  }

  @override
  Future<List<LocationModel>> getLocationsByType(String locationType) async{
    try {
      await getBox();
      final builder = _box!.query(
          LocationObjectBoxModel_.tipoLocal.contains(locationType, caseSensitive: false)
      );
      final query = builder.build();
      List<LocationObjectBoxModel> locationsObj = query.find() as List<LocationObjectBoxModel>;
      query.close();
      List<LocationModel> locations = [];
      for (var location in locationsObj) {
        locations.add(
            LocationMapper.locationModelFromObjectBox(location));
      }
      return locations;
    } on DatabaseError {
      rethrow;
    } on LocalizacaoMapperError {
      rethrow;
    } on Failure {
      throw LocalizacaoDatabaseGetError(message: 'Erro ao retornar as localizações');
    }
  }

  @override
  Future<List<LocationModel>> getLaboratoryByCode(String laboratoryCode) async{
    try {
      await getBox();
      final builder = _box!.query(
          LocationObjectBoxModel_.tipoLocal.equals("BLOCO") &
          LocationObjectBoxModel_.titulo.endsWith(laboratoryCode, caseSensitive: false)
      );
      final query = builder.build();
      List<LocationObjectBoxModel> locationsObj = query.find() as List<LocationObjectBoxModel>;
      query.close();
      List<LocationModel> locations = [];
      for (var location in locationsObj) {
        locations.add(
            LocationMapper.locationModelFromObjectBox(location));
      }
      return locations;
    } on DatabaseError {
      rethrow;
    } on LocalizacaoMapperError{
      rethrow;
    } on Failure {
      throw LocalizacaoDatabaseGetError(message: 'Erro ao retornar as localizações');
    }
  }

  @override
  Future<void> update(LocationEntity location) async{
    try {
      await getBox();
      _box!.put(LocationMapper.locationModelToObjectBox(location));
    } on DatabaseError {
      rethrow;
    } on LocalizacaoMapperError {
      rethrow;
    } on Failure {
      throw LocalizacaoDatabaseInsertError(
          message: 'Erro ao salvar a localização');
    }
  }

  @override
  Future<void> deleteAllLocations() async{
    try {
      await getBox();
      _box!.removeAll();
    } on DatabaseError {
      rethrow;
    } on Failure {
      throw LocalizacaoDatabaseDeleteError(message: 'Algo deu errado durante a exclusão dos dados');
    }
  }
}
