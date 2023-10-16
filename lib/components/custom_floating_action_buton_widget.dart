import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_bloc_teste/blocs/location_permissions_boc/location_permissions_bloc.dart';
import 'package:map_bloc_teste/blocs/location_service_status_bloc/location_service_status_bloc.dart';
import 'package:map_bloc_teste/blocs/route_bloc/route_bloc.dart';
import 'package:map_bloc_teste/blocs/user_position_bloc/user_position_bloc.dart';
import 'package:map_bloc_teste/entities/latlng_entity.dart';
import 'package:map_bloc_teste/utils/geolocator_utils.dart' as geolocator_utils;
import '../utils/google_maps_utils.dart' as google_maps_utils;

class CustomFloatingActionButton extends StatelessWidget {
  final Completer<GoogleMapController> mapsController;

  const CustomFloatingActionButton({
    Key? key,
    required this.mapsController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final locationPermissionsStatusState = context.watch<LocationPermissionsBloc>().state;
      final locationServiceStatusState = context.watch<LocationServiceStatusBloc>().state;
      final routeState = context.watch<RouteBloc>().state;

      if (locationPermissionsStatusState.status == LocationPermissionsStatus.denied ||
          locationPermissionsStatusState.status == LocationPermissionsStatus.deniedForever) {
        return FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.white,
          tooltip: 'Permissão à localização negada',
          onPressed: () async => await geolocator_utils
              .showDialogToAskForLocationPermission(context),
          child: const Icon(Icons.location_disabled_outlined,
              size: 32, color: Colors.red),
        );
      }

      if (locationServiceStatusState.status == LocationServiceStatus.disabled) {
        return FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.white,
          tooltip: 'Localização desativada',
          onPressed: () async => await geolocator_utils
              .showDialogToAskForEnableLocationService(context),
          child: const Icon(Icons.location_disabled_outlined,
              size: 32, color: Colors.red),
        );
      }

      if(routeState is OnRouteState){
        return FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.white,
          tooltip: 'Posição atual',
          onPressed: () async => await google_maps_utils.goToUserLocationAfterMakeRoute(
            mapsController,
            context.read<UserPositionBloc>().lastUserPosition!,
            LatLngEntity(latitude: routeState.destination.latitude, longitude: routeState.destination.longitude),
          ),
          child: const Icon(
            Icons.my_location_outlined,
            size: 32,
            color: Colors.black,
          ),
        );
      }

      return FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
        tooltip: 'Posição atual',
        onPressed: () async => await google_maps_utils.goToUserLocation(
            mapsController, context.read<UserPositionBloc>().lastUserPosition!),
        child: const Icon(
          Icons.my_location_outlined,
          size: 32,
          color: Colors.black,
        ),
      );

    });
  }
}
