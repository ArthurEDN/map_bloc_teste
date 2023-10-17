
import 'package:map_bloc_teste/domain/entities/location_entity.dart';
import 'package:map_bloc_teste/domain/repository/ilocations_repository.dart';
import 'package:map_bloc_teste/domain/errors/failure.dart';
import 'package:fpdart/fpdart.dart';



class GetLocationByNameUseCase {
  final ILocationsRepository iLocationsRepository;

  GetLocationByNameUseCase({required this.iLocationsRepository});

  Future<Either<Failure, List<LocationEntity>>> call(String locationName) async {
    return await iLocationsRepository.getLocationByName(locationName);
  }
}