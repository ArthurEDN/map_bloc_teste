import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_bloc_teste/entity/location_entity.dart';

import 'locations_event.dart';
import 'locations_state.dart';


class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  
  List<LocationEntity> locations = [
    LocationEntity(identificador: 1, titulo: "ALIMENTAÇÃO", descricao: "", latitude: -3.769156, longitude: -38.479566, tipoLocal: "SERVICO"),
  ];

  LocationsBloc() : super(const LocationsInitialState()) {
    on<GetLocationsEvent>((event, emit){
      return emit(LocationsSuccessState(locations: locations));
    });
  }

}