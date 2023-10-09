import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_bloc_teste/entity/location_entity.dart';

class MarkersController extends ValueNotifier<Set<Marker>> {
  MarkersController() : super(<Marker>{});

  late Function lateDisplayPersistentBottomSheetToMakeRoute;

  void getMarkers(List<LocationEntity> locations, Function displayPersistentBottomSheetToMakeRoute){
    lateDisplayPersistentBottomSheetToMakeRoute = displayPersistentBottomSheetToMakeRoute;
      if(locations.isNotEmpty){
        final newMarkers = <Marker>{};
        for (LocationEntity location in locations) {
          newMarkers.add(_createMarker(location));
        }
        value = newMarkers;
        notifyListeners();
      }
  }

  void changeVisibilityOfOthersMakers(String title){
    Set<Marker> setWithInvisibleMarkers = {};
    for (Marker marker in value) {
      if(marker.markerId.value != title){
        marker = marker.copyWith(
          visibleParam: false,
        );
      }
      if(marker.markerId.value == title){
        marker = marker.copyWith(
          onTapParam: () => {},
        );
      }
      setWithInvisibleMarkers.add(marker);
    }
    value = setWithInvisibleMarkers;
    notifyListeners();
  }

  void setMarkersVisible(){
    Set<Marker> setWithVisibleMarkers = {};
    for(Marker marker in value){
      if(!marker.visible) {
        marker = marker.copyWith(
          visibleParam: true,
        );
      }
      if(marker.visible){
        marker = marker.copyWith(
          onTapParam: () => lateDisplayPersistentBottomSheetToMakeRoute(marker.markerId.value),
        );
      }
      setWithVisibleMarkers.add(marker);
    }
    value = setWithVisibleMarkers;
    notifyListeners();
  }

  Marker _createMarker(LocationEntity location) {
    if(location.tipoLocal == "PERIMETRO") return Marker(markerId: MarkerId(location.titulo), visible: false);
    return Marker(
      markerId: MarkerId(location.titulo),
      infoWindow: InfoWindow(title: location.titulo, snippet: location.descricao),
      icon: _changeMarkerColor(location.tipoLocal),
      position: LatLng(location.latitude, location.longitude),
      onTap: () => lateDisplayPersistentBottomSheetToMakeRoute(location.titulo),
    );
  }

  BitmapDescriptor _changeMarkerColor(String locationType){
   switch(locationType){
      case "BLOCO":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case "SERVICO":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case "ENTRADA":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case "ESTACAO":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
      case "OUTRO":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

}