import 'package:map_bloc_teste/domain/entities/location_entity.dart';
import 'package:map_bloc_teste/domain/repository/ilocations_repository.dart';
import 'package:map_bloc_teste/domain/errors/failure.dart';
import 'package:fpdart/fpdart.dart';



class GetLocationsByTypeUseCase {
  final ILocationsRepository iLocationsRepository;
  GetLocationsByTypeUseCase({required this.iLocationsRepository});

  Future<Either<Failure, List<LocationEntity>>> call(String locationType) async {
    return await iLocationsRepository.getLocationsByType(locationType);
  }
}