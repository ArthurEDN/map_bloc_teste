import 'package:map_bloc_teste/domain/entities/location_entity.dart';

abstract class IMapDataSourceLocal{
  Future<dynamic> getStore();
  Future<dynamic> getBox();
  Future closeStore();
  Future<void> insertAllLocations(List<LocationEntity> locations);
  Future<List<LocationEntity>> getAllLocations();
  Future<List<LocationEntity>> getLocationsByType(String locationType);
  Future<List<LocationEntity>> getLocationByName(String locationName);
  Future<List<LocationEntity>> getLaboratoryByCode(String laboratoryCode);
  Future<void> update(LocationEntity location);
  Future<void> deleteAllLocations();
}