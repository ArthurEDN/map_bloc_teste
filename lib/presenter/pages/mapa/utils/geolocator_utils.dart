import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


LocationSettings initializeGeoLocatorConfigurations(){
  if (Platform.isAndroid) {
    return AndroidSettings(
      accuracy: LocationAccuracy.best,
      intervalDuration: const Duration(milliseconds: 500),
    );
  } else {
    return AppleSettings(
      accuracy: LocationAccuracy.best,
      activityType: ActivityType.fitness,
    );
  }
}

GeolocatorPlatform getGeolocatorInstance(){
  return GeolocatorPlatform.instance;
}

Stream<ServiceStatus> getGeolocatorServiceStatusStream(){
  return getGeolocatorInstance().getServiceStatusStream();
}

Stream<Position> getGeolocatorUserPositionStream(){
  LocationSettings locationSettings = initializeGeoLocatorConfigurations();
  return getGeolocatorInstance().getPositionStream(locationSettings: locationSettings);
}

double getDistanceBetweenLocations(LatLng userLocation, LatLng location){
  return getGeolocatorInstance().distanceBetween(
    userLocation.latitude,
    userLocation.longitude,
    location.latitude,
    location.longitude,
  );
}

Future<bool> isLocationServiceEnabled() async{
  return await getGeolocatorInstance().isLocationServiceEnabled();
}

Future<LocationPermission> checkLocationPermissions() async {
  return await getGeolocatorInstance().checkPermission();
}

Future<void> showDialogToAskForLocationPermission(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Permissão negada"),
      content: const Text("Para continuar, permita que o aplicativo Unifor Online acessa a localização deste dispositivo."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Agora não"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await getGeolocatorInstance().openAppSettings();
          },
          child: const Text("Configurações"),
        )
      ],
    ),
  );
}

Future<void> showDialogToAskForEnableLocationService(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Sua localização está desativada"),
      content: const Text("Para continuar, ative a localização do dispositivo."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Agora não"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await getGeolocatorInstance().openLocationSettings();
          },
          child: const Text("Configurações"),
        )
      ],
    ),
  );
}

void showSnackBarWithError(BuildContext context, String errorMessage){
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.red,
    ));
}