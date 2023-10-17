
import 'package:map_bloc_teste/external/datasource/remote/app_datasource_remote_impl.dart';
import 'package:map_bloc_teste/domain/entities/location_entity.dart';

abstract class IMapDataSourceRemote extends AppDataSourceRemoteImpl{
  Future<List<LocationEntity>> getAllLocations();
}