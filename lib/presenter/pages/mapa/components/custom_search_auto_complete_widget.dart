import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_bloc_teste/domain/entities/location_entity.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/controllers/search_auto_complete_widget_visibility_controller.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/utils/geolocator_utils.dart' as geolocator_utils;
import 'package:map_bloc_teste/presenter/pages/mapa/utils/google_maps_utils.dart' as googleMaps_utils;


class CustomSearchAutoCompleteWidget extends StatelessWidget {
  final List<LocationEntity> locationsList;
  final Completer<GoogleMapController> mapsController;
  final SearchAutoCompleteWidgetVisibilityController autoCompleteWidgetVisibilityController;
  final ThemeData theme;
  final Function displayMakeRouteBottomSheet;

  const CustomSearchAutoCompleteWidget({
    Key? key,
    required this.locationsList,
    required this.mapsController,
    required this.autoCompleteWidgetVisibilityController,
    required this.theme,
    required this.displayMakeRouteBottomSheet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Autocomplete<LocationEntity>(
              optionsBuilder: (TextEditingValue textEditingValue) =>
                  _filterLocations(textEditingValue.text),
              displayStringForOption: (LocationEntity location) => location.titulo,
              fieldViewBuilder: (BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted) {
                return TextFormField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  autofocus: true,
                  onFieldSubmitted: (String locationInput) async {
                    await _handleLocationInput(context, locationInput);
                  },
                  keyboardType: TextInputType.text,
                  autofillHints: const [AutofillHints.location],
                  decoration: InputDecoration(
                    hintText: "Pesquise aonde você quer ir",
                    hintStyle: const TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Open Sans'
                    ),
                    contentPadding: EdgeInsets.zero,
                    fillColor: theme.cardColor,
                    filled: true,
                    border: const OutlineInputBorder(),
                    prefixIcon: IconButton(
                      icon: Icon(Icons.arrow_back, color: theme.primaryColor,),
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        autoCompleteWidgetVisibilityController.setSearchAutoCompleteWidgetInvisible();
                      },
                    ),
                  ),
                );
              },
              onSelected: (LocationEntity selection) async {
                await _goToLocationAndDisplayBottomSheet(
                    context, selection.titulo, LatLng(selection.latitude, selection.longitude)
                );
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<LocationEntity> onSelected,
                  Iterable<LocationEntity> locations) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        child: AnimatedContainer(
                          height: _calculateOptionsHeight(locations.length),
                          width: MediaQuery.of(context).size.width - 48,
                          color: theme.backgroundColor,
                          duration: const Duration(milliseconds: 500),
                          child: ListView.separated(
                              padding: const EdgeInsets.all(10.0),
                              shrinkWrap: true,
                              itemCount: locations.length,
                              separatorBuilder: (BuildContext context, int index) => const Divider(),
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    onSelected(locations.elementAt(index));
                                  },
                                  child: ListTile(
                                    title: Text(locations.elementAt(index).titulo,),
                                  ),
                                );
                              }
                          ),
                        ),
                      ),
                    );
              }
          ),
        ),
      ],
    );
  }

  Iterable<LocationEntity> _filterLocations(String searchText) {
    if (searchText.isEmpty || locationsList.isEmpty) {
      return const Iterable<LocationEntity>.empty();
    }

    return locationsList.where((LocationEntity location) =>
             location.titulo.toLowerCase().startsWith(searchText.toLowerCase())
    );
  }

  Future<void> _handleLocationInput(BuildContext context, String locationInput) async {
    if (locationInput.isNotEmpty && locationsList.isNotEmpty) {
      LocationEntity? location = locationsList.firstWhereOrNull(
              (LocationEntity? location) =>
                location!.titulo.toLowerCase() == locationInput.toLowerCase());
      if (location != null) {
        await _goToLocationAndDisplayBottomSheet(
            context, location.titulo, LatLng(location.latitude, location.longitude)
        );
      }
    }
  }

  Future<void> _goToLocationAndDisplayBottomSheet(
      BuildContext context, String locationTitle, LatLng locationLatLng
  ) async{
    try{
      FocusManager.instance.primaryFocus?.unfocus();
      await googleMaps_utils.showMarkerInfoWindow(mapsController, locationTitle);
      await googleMaps_utils.goToLocation(mapsController, locationLatLng, 18,);
      displayMakeRouteBottomSheet(locationTitle);
    } on PlatformException catch(e){
      geolocator_utils.showSnackBarWithError(context, e.toString());
      FocusManager.instance.primaryFocus?.unfocus();
    } catch(e){
      geolocator_utils.showSnackBarWithError(context, e.toString());
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  double _calculateOptionsHeight(int items){
    if(items > 2){
      return 200;
    } else if(items == 2){
      return 148;
    } else if(items == 1){
      return 72;
    } else {
      return 0;
    }
  }
}
