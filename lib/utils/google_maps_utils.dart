import 'dart:async';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_bloc_teste/entities/latlng_entity.dart';
import 'package:map_bloc_teste/utils/geolocator_utils.dart' as geolocator_utils;

Future<void> goToUserLocation(
  Completer<GoogleMapController> mapsController,
  LatLngEntity userLocation,
) async {
  final GoogleMapController controller = await mapsController.future;
  try {
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(userLocation.latitude, userLocation.longitude),
      tilt: 32,
      zoom: 18,
    )));
  } catch (e) {
    rethrow;
  }
}

Future<void> goToUserLocationAfterMakeRoute(
  Completer<GoogleMapController> mapsController,
  LatLngEntity userPosition,
  LatLngEntity destinationLatLng,
 ) async {
  final GoogleMapController controller = await mapsController.future;
  try {
    await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(userPosition.latitude, userPosition.longitude),
      tilt: 32,
      zoom: 18,
      bearing: geolocator_utils.getGeolocatorInstance().bearingBetween(
        userPosition.latitude,
        userPosition.longitude,
        destinationLatLng.latitude,
        destinationLatLng.longitude,
      ),
    )));
  } catch (e) {
    controller.animateCamera(CameraUpdate.newCameraPosition(const CameraPosition(
        target: LatLng(-3.768964, -38.478966), zoom: 18, tilt: 32)));
    rethrow;
  }
}

Future<void> showMarkerInfoWindow(
    Completer<GoogleMapController> mapsController, String markerId) async {
  final GoogleMapController controller = await mapsController.future;
  try {
    await controller.showMarkerInfoWindow(MarkerId(markerId));
  } on PlatformException {
    throw PlatformException(
        code: "400",
        message: "Ocorreu um erro inesperado",
        stacktrace: StackTrace.current.toString());
  }
}

Future<void> hideMarkerInfoWindow(
    Completer<GoogleMapController> mapsController, String markerId) async {
  final GoogleMapController controller = await mapsController.future;
  try {
    if (await controller.isMarkerInfoWindowShown(MarkerId(markerId))) {
      await controller.hideMarkerInfoWindow(MarkerId(markerId));
    }
  } on PlatformException {
    throw PlatformException(
        code: "400",
        message: "Ocorreu um erro inesperado",
        stacktrace: StackTrace.current.toString());
  }
}
