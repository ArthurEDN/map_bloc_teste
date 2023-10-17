import 'package:map_bloc_teste/domain/entities/location_entity.dart';
import 'package:map_bloc_teste/domain/repository/ilocations_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:map_bloc_teste/domain/errors/failure.dart';


class GetAllLocationsUseCase {
  final ILocationsRepository iLocationsRepository;
  GetAllLocationsUseCase({required this.iLocationsRepository});

  Future<Either<Failure, List<LocationEntity>>> call() async {
    return await iLocationsRepository.getAllLocations();
  }
}