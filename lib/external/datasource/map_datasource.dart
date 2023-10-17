

import 'package:map_bloc_teste/domain/entities/location_entity.dart';
import 'package:map_bloc_teste/domain/errors/failure.dart';
import 'package:map_bloc_teste/infra/datasource/local/imap_datasource_local.dart';
import 'package:map_bloc_teste/infra/datasource/remote/imap_datasource_remote.dart';

class MapDataSource {
  final IMapDataSourceRemote _iMapDataSourceRemote;
  final IMapDataSourceLocal _iMapDataSourceLocal;

  MapDataSource(this._iMapDataSourceRemote, this._iMapDataSourceLocal);

  Future<List<LocationEntity>> getAllLocations() async {
    try {
      final List<LocationEntity> locations = await _iMapDataSourceRemote.getAllLocations();
      await _iMapDataSourceLocal.deleteAllLocations();
      await _iMapDataSourceLocal.insertAllLocations(locations);
      return await _iMapDataSourceLocal.getAllLocations();
    } on RemoteConnectionError catch (e) {
      e.data = await _iMapDataSourceLocal.getAllLocations();
      rethrow;
    } on Failure {
      rethrow;
    } finally {
      _iMapDataSourceLocal.closeStore();
    }
  }


  Future<List<LocationEntity>> getLocationsByType(String locationType) async {
    try {
      final List<LocationEntity> locations = await _iMapDataSourceLocal.getLocationsByType(locationType);;
      return locations;
    } on RemoteConnectionError catch (e) {
      e.data = await _iMapDataSourceLocal.getLocationsByType(locationType);
      rethrow;
    } on Failure {
      rethrow;
    } finally {
      _iMapDataSourceLocal.closeStore();
    }
  }

  Future<List<LocationEntity>> getLocationByName(String locationName) async {
    try {
      final List<LocationEntity> locations = await _iMapDataSourceLocal.getLocationByName(locationName);
      return locations;
    } on RemoteConnectionError catch (e) {
      e.data = await _iMapDataSourceLocal.getLocationByName(locationName);
      rethrow;
    } on Failure {
      rethrow;
    } finally {
      _iMapDataSourceLocal.closeStore();
    }
  }

  Future<List<LocationEntity>> getLaboratoryByCode(String laboratoryCode) async {
    try {
      final List<LocationEntity> locations = await _iMapDataSourceLocal.getLaboratoryByCode(laboratoryCode);
      return locations;
    } on RemoteConnectionError catch (e) {
      e.data = await _iMapDataSourceLocal.getLaboratoryByCode(laboratoryCode);
      rethrow;
    } on Failure {
      rethrow;
    } finally {
      _iMapDataSourceLocal.closeStore();
    }
  }

}