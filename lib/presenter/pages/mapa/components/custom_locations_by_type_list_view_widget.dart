import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_bloc_teste/domain/entities/location_entity.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/utils/geolocator_utils.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/utils/google_maps_utils.dart' as map_utils;
import 'package:map_bloc_teste/presenter/pages/mapa/utils/google_maps_utils.dart';



class CustomLocationsByTypeListViewWidget extends StatelessWidget {
  final ValueNotifier<Brightness> brightness;
  final Completer<GoogleMapController> mapsController;
  final List<LocationEntity> filteredLocations;
  final Function displayMakeRouteBottomSheet;
  final ThemeData theme;

  const CustomLocationsByTypeListViewWidget({
    Key? key,
    required this.brightness,
    required this.mapsController,
    required this.filteredLocations,
    required this.displayMakeRouteBottomSheet,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(filteredLocations.isEmpty){
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/ema_estudante_metade.png",
              height: 160,
              scale: 2.0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Nenhuma localização encontrada",
                style: TextStyle(
                    color: brightness.value == Brightness.dark
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF424242),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Open Sans'
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 12.0, right: 8.0),
              child: Text(
                "O serviço está indisponível. Por favor, tente novamente mais tarde",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: brightness.value == Brightness.dark
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF424242),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Open Sans'
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Expanded(
      child: ListView.separated(
          padding: const EdgeInsets.only(top:12.0, left: 8, right: 8, bottom: 16),
          shrinkWrap: true,
          itemCount: filteredLocations.length,
          separatorBuilder: (BuildContext context, int index) => const Divider(
            height: 0.1,
            indent: 16.0,
            endIndent: 16.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            final location = filteredLocations[index];
            final locationLatLng = LatLng(location.latitude, location.longitude);
            return MaterialButton(
              splashColor: brightness.value == Brightness.dark
                  ? const Color(0xFF5CB8FF) : theme.secondaryHeaderColor,
              highlightColor: brightness.value == Brightness.dark
                  ? const Color(0xFF5CB8FF) : theme.secondaryHeaderColor,
              onPressed: () async => await _goToLocationAndDisplayMakeRouteBottomSheet(
                  context,
                  location.titulo,
                  locationLatLng
              ),
              child: ListTile(
                title: Text(
                  filteredLocations[index].titulo,
                  style: TextStyle(
                      color: brightness.value == Brightness.dark
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFF424242),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Open Sans'
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  Future<void> _goToLocationAndDisplayMakeRouteBottomSheet(
      BuildContext context, String locationTitle, LatLng locationLatLng
  ) async {
    try{
      await map_utils.showMarkerInfoWindow(mapsController, locationTitle);
      await map_utils.goToLocation(mapsController, locationLatLng, 18,).then((value){
        Navigator.pop(context);
      });
      displayMakeRouteBottomSheet(locationTitle);
    } on PlatformException catch(e){
      showSnackBarWithError(context, e.toString());
      Navigator.pop(context);
    } catch(e) {
      showSnackBarWithError(context, e.toString());
      Navigator.pop(context);
    }
  }
}
