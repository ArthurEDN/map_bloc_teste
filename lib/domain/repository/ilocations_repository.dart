import 'package:map_bloc_teste/domain/entities/location_entity.dart';
import 'package:fpdart/fpdart.dart';
import 'package:map_bloc_teste/domain/errors/failure.dart';

abstract class ILocationsRepository {
  Future<Either<Failure, List<LocationEntity>>> getAllLocations();
  Future<Either<Failure, List<LocationEntity>>> getLocationsByType(String locationType);
  Future<Either<Failure, List<LocationEntity>>> getLocationByName(String locationName);
  Future<Either<Failure, List<LocationEntity>>> getLaboratoryByCode(String laboratoryCode);
}