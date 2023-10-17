
import 'package:map_bloc_teste/domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  LocationModel({
    required identificador,
    required titulo,
    required descricao,
    required latitude,
    required longitude,
    required tipoLocal
  }) : super(
      identificador: identificador,
      titulo: titulo,
      descricao: descricao,
      latitude:latitude,
      longitude:longitude,
      tipoLocal:tipoLocal
  );
}
