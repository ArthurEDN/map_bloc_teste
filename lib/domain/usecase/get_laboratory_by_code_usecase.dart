import 'package:map_bloc_teste/domain/entities/location_entity.dart';
import 'package:map_bloc_teste/domain/repository/ilocations_repository.dart';
import 'package:map_bloc_teste/domain/errors/failure.dart';
import 'package:fpdart/fpdart.dart';


class GetLaboratoryByCodeUseCase {
  final ILocationsRepository iLocationsRepository;

  GetLaboratoryByCodeUseCase({required this.iLocationsRepository});

  Future<Either<Failure, List<LocationEntity>>> call(String laboratoryCode) async {
    return await iLocationsRepository.getLaboratoryByCode(laboratoryCode);
  }
}