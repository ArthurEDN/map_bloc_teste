import 'package:flutter_modular/flutter_modular.dart';
import 'package:map_bloc_teste/domain/usecase/get_all_locations_usecase.dart';
import 'package:map_bloc_teste/domain/usecase/get_location_by_name_usecase.dart';
import 'package:map_bloc_teste/domain/usecase/get_locations_by_type_usecase.dart';
import 'package:map_bloc_teste/external/datasource/local/map_datasource_local_impl.dart';
import 'package:map_bloc_teste/external/datasource/map_datasource.dart';
import 'package:map_bloc_teste/external/datasource/remote/map_datasource_remote_impl.dart';
import 'package:map_bloc_teste/infra/repository/locations_repository_impl.dart';
import 'package:map_bloc_teste/presenter/blocs/location_bloc/locations_bloc.dart';

import '../pages/mapa/mapa_page.dart';

class MapaModule extends Module {

  // Provide a list of dependencies to inject into your project
  @override
  final List<Bind> binds = [
    Bind.singleton((i) => MapDataSourceRemoteImpl(), export: true),
    Bind.singleton((i) => MapDataSourceLocalImpl(), export: true),
    Bind.singleton((i) => MapDataSource(i(), i()), export: true),
    Bind.singleton((i) => LocationsRepositoryImpl(i()), export: true),
    Bind.singleton((i) => GetAllLocationsUseCase(iLocationsRepository:i()), export: true),
    Bind.singleton((i) => GetLocationByNameUseCase(iLocationsRepository: i()), export: true),
    Bind.singleton((i) => GetLocationsByTypeUseCase(iLocationsRepository: i()), export: true),
    Bind.singleton<LocationsBloc>((i) => LocationsBloc(), onDispose: (bloc) => bloc.close(), export: true),
  ];

  // Provide all the routes for your module
  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (context, args) => const MapPage()),
  ];
}