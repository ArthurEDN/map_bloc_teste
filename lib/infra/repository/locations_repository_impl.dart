import 'package:fpdart/src/either.dart';
import 'package:map_bloc_teste/domain/entities/location_entity.dart';
import 'package:map_bloc_teste/domain/errors/mapa_failures.dart';
import 'package:map_bloc_teste/domain/repository/ilocations_repository.dart';
import 'package:map_bloc_teste/external/datasource/map_datasource.dart';
import 'package:map_bloc_teste/domain/errors/failure.dart';


class LocationsRepositoryImpl extends ILocationsRepository{
  final MapDataSource _mapDataSourceImpl;

  LocationsRepositoryImpl(this._mapDataSourceImpl);

  @override
  Future<Either<Failure, List<LocationEntity>>> getAllLocations() async{
    try {
      List<LocationEntity> resultList = await _mapDataSourceImpl.getAllLocations();

      if (resultList.isEmpty) {
        return Left(LocalizacaoNoDataFound(message: 'Nenhuma localização encontrada'));
      }

      return Right(resultList);
    } on Failure catch(e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<LocationEntity>>> getLocationsByType(String locationType) async{
    try{
      List<LocationEntity> resultList = await _mapDataSourceImpl.getLocationsByType(locationType);

      if (resultList.isEmpty) {
        return Left(LocalizacaoNoDataFound(message: 'Nenhuma localização encontrada'));
      }
      return Right(resultList);
    }on Failure catch (e){
      return Left(e);
    }

  }

  @override
  Future<Either<Failure, List<LocationEntity>>> getLocationByName(String locationName) async{
    try{
      List<LocationEntity> resultList = await _mapDataSourceImpl.getLocationByName(locationName);

      if (resultList.isEmpty) {
        return Left(LocalizacaoNoDataFound(message: 'Nenhuma localização encontrada'));
      }
      return Right(resultList);
    }on Failure catch (e){
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<LocationEntity>>> getLaboratoryByCode(String laboratoryCode) async{
    try{
      List<LocationEntity> resultList = await _mapDataSourceImpl.getLaboratoryByCode(laboratoryCode);

      if (resultList.isEmpty) {
        return Left(LocalizacaoNoDataFound(message: 'Nenhuma localização encontrada'));
      }
      return Right(resultList);
    }on Failure catch (e){
      return Left(e);
    }
  }


}