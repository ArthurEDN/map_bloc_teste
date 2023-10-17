import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_bloc_teste/domain/entities/latlng_entity.dart';
import 'package:map_bloc_teste/domain/entities/location_entity.dart';
import 'package:map_bloc_teste/presenter/blocs/app_lifecycle_bloc/app_life_cycle_bloc.dart';
import 'package:map_bloc_teste/presenter/blocs/location_bloc/locations_bloc.dart';
import 'package:map_bloc_teste/presenter/blocs/location_bloc/locations_event.dart';
import 'package:map_bloc_teste/presenter/blocs/location_bloc/locations_state.dart';
import 'package:map_bloc_teste/presenter/blocs/location_permissions_boc/location_permissions_bloc.dart';
import 'package:map_bloc_teste/presenter/blocs/location_service_status_bloc/location_service_status_bloc.dart';
import 'package:map_bloc_teste/presenter/blocs/route_bloc/route_bloc.dart';
import 'package:map_bloc_teste/presenter/blocs/user_position_bloc/user_position_bloc.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/components/custom_bottom_navigation_item_widget.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/components/custom_floating_action_buton_widget.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/components/custom_locations_by_type_list_view_widget.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/components/custom_search_auto_complete_widget.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/components/custom_search_card_widget.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/components/custom_states_body_stop_route_bottomSheet_widget.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/components/single_touch_recognizer.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/controllers/markers_controller.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/controllers/polylines_controller.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/controllers/searchCard_visibility_controller.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/controllers/search_auto_complete_widget_visibility_controller.dart';
import 'package:map_bloc_teste/presenter/pages/mapa/utils/geolocator_utils.dart' as geolocator_utils;
import 'package:map_bloc_teste/presenter/pages/mapa/utils/google_maps_utils.dart' as google_maps_utils;


enum LocationType{
  BLOCO,
  ENTRADA,
  SERVICO,
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late String _mapStyle;
  final Completer<GoogleMapController> _mapsController = Completer<GoogleMapController>();
  final MarkersController _markersController = MarkersController();
  final PolylineController _polylineController = PolylineController();
  final SearchAutoCompleteWidgetVisibilityController _searchAutoCompleteWidgetVisibilityController = SearchAutoCompleteWidgetVisibilityController();
  final SearchCardVisibilityController _searchCardVisibilityController = SearchCardVisibilityController();
  final ValueNotifier<Brightness> _notifierBrightness = ValueNotifier(SchedulerBinding.instance.window.platformBrightness);
  final ValueNotifier<int> _currentPageIndex = ValueNotifier(100);
  final ValueNotifier<bool> _theRouteWasMake = ValueNotifier(false);
  AnimationController? _persistentBottomSheetAnimationController;
  AnimationController? _bottomSheetAnimationController;
  List<LocationEntity> _locationsList = [];

  @override
  void initState() {
    super.initState();
    _persistentBottomSheetAnimationController = BottomSheet.createAnimationController(this);
    _bottomSheetAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _persistentBottomSheetAnimationController!.duration = const Duration(seconds: 1);
    _persistentBottomSheetAnimationController!.reverseDuration = const Duration(milliseconds: 500);
    _persistentBottomSheetAnimationController!.drive(CurveTween(curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _notifierBrightness.dispose();
    _currentPageIndex.dispose();
    _theRouteWasMake.dispose();
    _persistentBottomSheetAnimationController?.dispose();
    _bottomSheetAnimationController?.dispose();
    _searchAutoCompleteWidgetVisibilityController.dispose();
    _searchCardVisibilityController.dispose();
    _markersController.dispose();
    _polylineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LocationsBloc()
            ..add(GetLocationsEvent()),
        ),
        BlocProvider(
          create: (context) => LocationPermissionsBloc()
            ..add(const LocationPermissionsFirstCheckEvent()),
        ),
        BlocProvider(
          create: (context) => LocationServiceStatusBloc()
            ..add(const LocationServiceIsEnabled()),
        ),
        BlocProvider(
            create: (context) => AppLifeCycleBloc()
              ..add(const AppLifeCycleStarted())),
        BlocProvider(
          create: (context) => UserPositionBloc(),
        ),
        BlocProvider(
          create: (context) => RouteBloc(
            BlocProvider.of<UserPositionBloc>(context),
            _polylineController,
            _mapsController,
            _theRouteWasMake,
          ),
        ),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: MultiBlocListener(
          listeners: [
            BlocListener<AppLifeCycleBloc, AppLifeCycleStatusState>(
              listenWhen: (previous, next) {
                if (previous.lifeCycleStateStatus == AppLifecycleState.hidden &&
                    next.lifeCycleStateStatus == AppLifecycleState.inactive) {
                  return true;
                }
                return false;
              },
              listener: (context, state) {
                BlocProvider.of<LocationPermissionsBloc>(context)
                    .add(const LocationPermissionsCheckedEvent());
              },
            ),
            BlocListener<LocationPermissionsBloc, LocalPermissionStatusState>(
              listenWhen: (previous, next) {
                if (next.status == LocationPermissionsStatus.always ||
                    next.status == LocationPermissionsStatus.whileInUse) {
                  return true;
                }
                return false;
              },
              listener: (context, state) {
                if (BlocProvider.of<LocationServiceStatusBloc>(context).locationServiceStatusValue == LocationServiceStatus.enabled) {
                  BlocProvider.of<UserPositionBloc>(context).add(const UserPositionSubscriptionStarted());
                }
              },
            ),
            BlocListener<LocationServiceStatusBloc, LocationServiceStatusState>(
              listenWhen: (previous, next) {
                return next.status == LocationServiceStatus.enabled;
              },
              listener: (context, state) {
                if (BlocProvider.of<LocationPermissionsBloc>(context).locationPermission == LocationPermissionsStatus.always ||
                    BlocProvider.of<LocationPermissionsBloc>(context).locationPermission == LocationPermissionsStatus.whileInUse) {
                  BlocProvider.of<UserPositionBloc>(context).add(const UserPositionSubscriptionStarted());
                }
              },
            ),
            BlocListener<LocationsBloc, LocationsState>(
                listener: (context, state) {
                  if (state is LocationsFailureState) {
                    _setLocationsListAndMarkersWithStateLocations(context, state.locations);
                    geolocator_utils.showSnackBarWithError(context, state.errorMessage);
                  } else if (state is LocationsSuccessState) {
                    _setLocationsListAndMarkersWithStateLocations(context, state.locations);
                  }
                }),
            BlocListener<UserPositionBloc, UserPositionState>(
              listener: (context, state) {
                if (state is UserPositionFailureState) {
                  geolocator_utils.showSnackBarWithError(context, state.errorMessage);
                }
              },
            ),
            BlocListener<RouteBloc, RouteState>(
              listener: (context, state) async{
                if(state is RouteRequestedState) {
                  _markersController.changeVisibilityOfOthersMakers(state.destination.titulo);
                  _displayBottomSheetToStopMakingRoute(context, state.destination);
                }
                if(state is RouteEndedState){
                  _markersController.setMarkersVisible();
                }
              },
            ),
          ],
          child: Stack(
            children: [
              ValueListenableBuilder<Brightness>(
                valueListenable: _notifierBrightness,
                builder:(BuildContext context, Brightness brightnessValue, Widget? child) {
                  _setMapStyle(context);
                  return  ValueListenableBuilder<Set<Marker>>(
                    valueListenable: _markersController,
                    builder: (BuildContext context, Set<Marker> markersValue, Widget? child) => ValueListenableBuilder<Set<Polyline>>(
                      valueListenable: _polylineController,
                      builder: (BuildContext context, Set<Polyline> value, Widget? child) {
                        return GoogleMap(
                          onMapCreated: (GoogleMapController controller) async {
                            _mapsController.complete(controller);
                            await checkUserPositionBlocState(context);
                          },
                          minMaxZoomPreference: const MinMaxZoomPreference(12, 18.5),
                          mapToolbarEnabled: false,
                          myLocationButtonEnabled: false,
                          compassEnabled: false,
                          zoomControlsEnabled: false,
                          myLocationEnabled: true,
                          zoomGesturesEnabled: true,
                          rotateGesturesEnabled: true,
                          mapType: MapType.normal,
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(-3.768964, -38.478966),
                            tilt: 32,
                            zoom: 18,
                          ),
                          markers: _markersController.value,
                          polylines: _polylineController.value,
                        );
                      },
                    ),
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _searchCardVisibilityController,
                builder: (BuildContext context, bool searchCardVisibility, Widget? widget){
                  return Visibility(
                    visible: searchCardVisibility,
                    child: GestureDetector(
                      onTap: _searchAutoCompleteWidgetVisibilityController.setSearchAutoCompleteWidgetVisible,
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),),
                        margin: const EdgeInsets.only(top: 40, right: 16, left: 16),
                        shadowColor: _notifierBrightness.value == Brightness.dark ? Colors.transparent : Colors.grey,
                        elevation: 3,
                        child:  Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _searchAutoCompleteWidgetVisibilityController,
                            builder: (BuildContext context, bool autoCompleteVisibility, Widget? child) {
                              return autoCompleteVisibility
                                ? CustomSearchAutoCompleteWidget(
                                  locationsList: _locationsList,
                                  mapsController: _mapsController,
                                  autoCompleteWidgetVisibilityController: _searchAutoCompleteWidgetVisibilityController,
                                  theme: _theme,
                                  displayMakeRouteBottomSheet: (String chosenLocation) async{
                                    await _displayBottomSheetToMakeRouteAndFilterChosenLocation(
                                      context,
                                      _getLocationByTitle(chosenLocation),
                                    );
                                  }
                                )
                              : CustomSearchCardWidget(
                                title: "Pesquise aqui",
                                autoCompleteWidgetVisibilityController: _searchAutoCompleteWidgetVisibilityController,
                                theme: _theme,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: CustomFloatingActionButton(
          mapsController: _mapsController,
        ),
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _currentPageIndex,
          builder: (BuildContext context, int bottomItemIndex, Widget? child) {
            return SizeTransition(
              sizeFactor: CurvedAnimation(
                  parent: _bottomSheetAnimationController!,
                  curve: Curves.easeIn,
                  reverseCurve: Curves.easeIn
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: _notifierBrightness.value == Brightness.dark
                      ? const Color(0xFF212121)
                      : const Color(0xFFFFFFFF),
                  boxShadow: [
                    BoxShadow(
                      color:  _notifierBrightness.value == Brightness.dark
                          ? Colors.transparent
                          : Colors.grey,
                      offset: const Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                height: MediaQuery.of(context).size.height / 10,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomBottomNavigationItemWidget(
                        title: 'Blocos',
                        brightness: _notifierBrightness,
                        icon: Icons.grid_view_outlined,
                        currentPageIndex: _currentPageIndex,
                        indexItem: 0,
                        theme: _theme,
                        onPressFunc: () async {
                          _onTabTapped(0);
                          await _showLocationsByTypeBottomSheet(
                            context,
                            _theme,
                            _notifierBrightness,
                            'Blocos',
                            LocationType.BLOCO,
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: CustomBottomNavigationItemWidget(
                        title: 'Entradas',
                        brightness: _notifierBrightness,
                        icon: Icons.door_sliding_outlined,
                        currentPageIndex: _currentPageIndex,
                        indexItem: 1,
                        theme: _theme,
                        onPressFunc: () async{
                          _onTabTapped(1);
                          await _showLocationsByTypeBottomSheet(
                            context,
                            _theme,
                            _notifierBrightness,
                            'Entradas',
                            LocationType.ENTRADA,
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: CustomBottomNavigationItemWidget(
                        title: 'Serviços',
                        brightness: _notifierBrightness,
                        icon: Icons.person_pin_outlined,
                        currentPageIndex: _currentPageIndex,
                        indexItem: 2,
                        theme: _theme,
                        onPressFunc: () async{
                          _onTabTapped(2);
                          await _showLocationsByTypeBottomSheet(
                            context,
                            _theme,
                            _notifierBrightness,
                            'Serviços',
                            LocationType.SERVICO,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  LocationEntity _getLocationByTitle(String title) {
    return _locationsList
        .firstWhere((LocationEntity location) => location.titulo == title);
  }

  List<LocationEntity> _getLocationsByType(String type) {
    return _locationsList.where(
            (LocationEntity location) => location.tipoLocal == type).toList();
  }

  Future<void> checkUserPositionBlocState(BuildContext context) async {
    final state = context.read<UserPositionBloc>().state;
    if (state is UserPositionFailureState) {
      await google_maps_utils.goToUserLocation(_mapsController,
          LatLngEntity(latitude: -3.768964, longitude: -38.478966));
    }
    if (state is UserPositionUpdatedState) {
      await google_maps_utils.goToUserLocation(
          _mapsController, state.userPosition);
    }
  }

  void _setMapStyle(BuildContext context){
    final styleFileName = _notifierBrightness.value == Brightness.dark
        ? 'maps_night_style.json'
        : 'maps_standard_style.json';

    DefaultAssetBundle.of(context).loadString('assets/maps_style/$styleFileName').then((string) {
      _mapStyle = string;
    });
  }

  void _setLocationsListAndMarkersWithStateLocations(BuildContext context, List<LocationEntity> locationsList) {
    _locationsList = locationsList;
    _markersController.getMarkers(locationsList, (String chosenLocation) async {
      await _displayBottomSheetToMakeRouteAndFilterChosenLocation(
        context,
        _getLocationByTitle(chosenLocation),
      );
    });
  }

  void _onTabTapped(int index) {
    if (_currentPageIndex.value == index) {
      _currentPageIndex.value = 100;
    } else {
      _currentPageIndex.value = index;
    }
  }

  Future<void> _displayBottomSheetToMakeRouteAndFilterChosenLocation(BuildContext mapPageContext, LocationEntity location) async {
    await _bottomSheetAnimationController!.animateBack(0, curve: Curves.easeIn).then((value) {
      Scaffold.of(mapPageContext).showBottomSheet(
          elevation: 15,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0),),),
          (context) => SizedBox(
            height: MediaQuery.of(context).size.height / 4.5,
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 24.0),
                      child: IconButton(
                        iconSize: 32,
                        icon: const Icon(Icons.arrow_back_outlined),
                        color: const Color(0xFF005B9B),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, right: 24, left: 8.0),
                        child: Text(
                          location.titulo,
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: "Open Sans",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 32.0,
                      right: 32.0,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<RouteBloc>().add(MakeRouteEvent(destination: location));
                        },
                        child: const Text(
                          "Como chegar",
                          style: TextStyle(
                            fontFamily: "Open Sans",
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )).closed.whenComplete(() async {
        _bottomSheetAnimationController!.forward();
        await google_maps_utils.hideMarkerInfoWindow(
          _mapsController,
          location.titulo,
        );
      });
    });
  }

  void _displayBottomSheetToStopMakingRoute(BuildContext mapPageContext, LocationEntity location) {
    Scaffold.of(mapPageContext).showBottomSheet(
      elevation: 15,
      enableDrag: false,
      transitionAnimationController: _persistentBottomSheetAnimationController,
      (context) => SizedBox(
        height: MediaQuery.of(context).size.height/3,
        child: BlocBuilder<RouteBloc, RouteState>(
          builder: (context, state) {
            if(state is RouteLoadingState){
              return const RouteWaitingStateBody();
            }
            if(state is OnRouteState){
              return AbsorbPointer(
                absorbing: _persistentBottomSheetAnimationController!.status == AnimationStatus.reverse,
                child: OnRouteStateBody(
                  location: location,
                  distanceBetweenLocations: geolocator_utils.getDistanceBetweenLocations(
                    LatLng(state.userPosition.latitude, state.userPosition.longitude),
                    LatLng(location.latitude, location.longitude,),
                  ),
                ),
              );
            }
            if(state is RouteFailureState){
              return RouteFailureStateBody(
                errorMessageTitle: "Oops! Algo deu errado!",
                errorMessageSubTitle: state.errorMessage,
              );
            }
            return Container();
          },
        ),
      ),
    ).closed.whenComplete(() async {
      mapPageContext.read<RouteBloc>().add(const EndRouteEvent());
      await google_maps_utils.hideMarkerInfoWindow(_mapsController, location.titulo);
    });
  }

  Future<void> _showLocationsByTypeBottomSheet(
    BuildContext mapaPageContext,
    ThemeData theme,
    ValueNotifier<Brightness> brightness,
    String title,
    LocationType locationType,
  ) async {
    await showModalBottomSheet(
        context: mapaPageContext,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        builder: (context) => SingleTouchRecognizerWidget(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 5,
                  width: MediaQuery.of(context).size.width/ 9,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _currentPageIndex.value = 100;
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_outlined,
                        size: 28,
                      ),
                      color: const Color(0xFF005B9B),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        title,
                        style: TextStyle(
                            color: brightness.value == Brightness.dark
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF424242),
                            fontSize: 24.0,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Open Sans'
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomLocationsByTypeListViewWidget(
                brightness: brightness,
                theme: theme,
                mapsController: _mapsController,
                filteredLocations: _getLocationsByType(locationType.name),
                displayMakeRouteBottomSheet: (String chosenLocation) async{
                  await _displayBottomSheetToMakeRouteAndFilterChosenLocation(
                    mapaPageContext,
                    _getLocationByTitle(chosenLocation),
                  );
                },
              ),
              // customLocationListView,
            ],
          ),
        )
    ).whenComplete(() {
      _currentPageIndex.value = 100;
    }
    );
  }
}