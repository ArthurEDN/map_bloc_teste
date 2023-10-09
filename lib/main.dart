import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_bloc_teste/bloc/location_permissions_boc/location_permissions_bloc.dart';
import 'package:map_bloc_teste/bloc/location_service_status_bloc/location_service_status_bloc.dart';
import 'package:map_bloc_teste/bloc/userPosition_bloc/user_position_bloc.dart';
import 'package:map_bloc_teste/components/custom_floating_action_buton_widget.dart';
import 'package:map_bloc_teste/entity/location_entity.dart';
import 'package:map_bloc_teste/utils/geolocator_utils.dart' as geolocator_utils;
import 'package:map_bloc_teste/utils/google_maps_utils.dart' as google_maps_utils;
import 'bloc/app_lifecycle_bloc/app_life_cycle_bloc.dart';
import 'bloc/bloc_observer.dart';
import 'bloc/locations_bloc/locations_bloc.dart';
import 'bloc/locations_bloc/locations_event.dart';
import 'bloc/locations_bloc/locations_state.dart';
import 'controllers/markers_controller.dart';
import 'controllers/polylines_controller.dart';
import 'entity/latlng_entity.dart';


void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{

  final Completer<GoogleMapController> _mapsController = Completer<GoogleMapController>();
  final MarkersController _markerController = MarkersController();
  final PolylineController _polylineController = PolylineController();
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
  void dispose(){
    _persistentBottomSheetAnimationController?.dispose();
    _bottomSheetAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .inversePrimary,
            title: Text(widget.title),
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<AppLifeCycleBloc, AppLifeCycleStatusState>(
                listenWhen: (previous, next){
                  if(previous.lifeCycleStateStatus == AppLifecycleState.hidden && next.lifeCycleStateStatus == AppLifecycleState.inactive){
                    return true;
                  }
                  return false;
                },
                listener: (context, state){
                    BlocProvider.of<LocationPermissionsBloc>(context).add(const LocationPermissionsCheckedEvent());
                },
              ),
              BlocListener<LocationPermissionsBloc, LocalPermissionStatusState>(
                listenWhen: (previous, next){
                  print("LocationPermissionsBloc${previous.status}");
                  print("LocationPermissionsBloc${next.status}");
                  if(next.status == LocationPermissionsStatus.always || next.status == LocationPermissionsStatus.whileInUse){
                    return true;
                  }
                  return false;
                },
                listener: (context, state) {
                  print("LocationPermissionsBlocListener");
                  print(BlocProvider.of<LocationServiceStatusBloc>(context).locationServiceStatusValue);
                  if(BlocProvider.of<LocationServiceStatusBloc>(context).locationServiceStatusValue == LocationServiceStatus.enabled){
                    print("LocationPermissionsBlocAdd");
                    BlocProvider.of<UserPositionBloc>(context)
                        .add(const UserPositionSubscriptionStarted());
                  }
                },
              ),
              BlocListener<LocationServiceStatusBloc, LocationServiceStatusState>(
                listenWhen: (previous, next){
                  print("LocationServiceStatusBloc${previous.status}");
                  print("LocationServiceStatusBloc${next.status}");
                  return next.status == LocationServiceStatus.enabled;
                },
                listener: (context, state){
                  print("LocationServiceStatusBlocListener");
                  print(BlocProvider.of<LocationPermissionsBloc>(context).locationPermission);
                  if(BlocProvider.of<LocationPermissionsBloc>(context).locationPermission == LocationPermissionsStatus.always
                     || BlocProvider.of<LocationPermissionsBloc>(context).locationPermission == LocationPermissionsStatus.whileInUse){
                    print("LocationServiceStatusBlocAdd");
                    BlocProvider.of<UserPositionBloc>(context)
                        .add(const UserPositionSubscriptionStarted());
                  }

                },
              ),
              BlocListener<LocationsBloc, LocationsState>(
                  listener:(context, state){
                    if (state is LocationsFailureState) {
                      _setLocationsListAndMarkersWithStateLocations(context, state.locations);
                      geolocator_utils.showSnackBarWithError(context, state.errorMessage);
                    } else if (state is LocationsSuccessState) {
                      _setLocationsListAndMarkersWithStateLocations(context, state.locations);
                    }
                  }
              ),
              BlocListener<UserPositionBloc, UserPositionState>(
                listener: (context, state) {
                    if(state is UserPositionFailureState){
                      geolocator_utils.showSnackBarWithError(context, state.message);
                    }
                },
              ),
            ],
            child: Stack(
              children: [
                ValueListenableBuilder<Set<Marker>>(
                  valueListenable: _markerController,
                  builder: (BuildContext context, Set<Marker> markersValue, Widget? child) => GoogleMap(
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
                    markers: _markerController.value,
                    polylines: _polylineController.value,
                  ),
                ),
              ],
            ),
          ),
        floatingActionButton: CustomFloatingActionButton(
          mapsController: _mapsController,
        ),
      ),
    );
  }


  LocationEntity _getLocationByTitle(String title) {
    return _locationsList.firstWhere(
            (LocationEntity location) => location.titulo == title);
  }

  Future<void> checkUserPositionBlocState(BuildContext context) async{
    final state = context.read<UserPositionBloc>().state;
    if(state is UserPositionFailureState){
      await google_maps_utils.goToUserLocation(_mapsController, LatLngEntity(latitude: -3.768964, longitude: -38.478966));
    }
    if(state is UserPositionUpdatedState){
      await google_maps_utils.goToUserLocation(_mapsController, state.userPosition);
    }
  }

  void _setLocationsListAndMarkersWithStateLocations(
    BuildContext context, List<LocationEntity> locationsList
  ){
    _locationsList = locationsList;
    _markerController.getMarkers(
        locationsList,
        (String chosenLocation) async {
          // await _displayBottomSheetToMakeRouteAndFilterChosenLocation(
          //   context,
          //   _getLocationByTitle(chosenLocation),
          // );
        }
    );
  }


  // void _makeRoute(LocationEntity location){
  //   _markerController.changeVisibilityOfOthersMakers(location.titulo);
  //   _polylineController.makeRoute(LatLng(location.latitude, location.longitude), userPositionStream);
  //   _theRouteWasMake.value = true;
  // }

  // Future<void> _stopMakingRoute() async{
  //   await _polylineController.stopMakingRoute();
  //   _theRouteWasMake.value = false;
  // }
  //
  // FutureOr<void> _displayBottomSheetToMakeRouteAndFilterChosenLocation(
  //   BuildContext mapPageContext, LocationEntity location
  // ) async{
  //   await _bottomSheetAnimationController!.animateBack(0, curve: Curves.easeIn).then((value){
  //     Scaffold.of(mapPageContext).showBottomSheet(
  //         elevation: 15,
  //         shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.vertical(
  //             top: Radius.circular(25.0),
  //           ),
  //         ),
  //         (context) => SizedBox(
  //           height: MediaQuery.of(context).size.height/4.5,
  //           child: Column(
  //             children: [
  //               Row(
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.only(left: 16.0, top: 24.0),
  //                     child: IconButton(
  //                       iconSize: 32,
  //                       icon: const Icon(Icons.arrow_back_outlined),
  //                       color: const Color(0xFF005B9B),
  //                       onPressed: () => Navigator.pop(context),
  //                     ),
  //                   ),
  //                   Flexible(
  //                     child: Padding(
  //                       padding: const EdgeInsets.only(top: 20.0, right: 24, left: 8.0),
  //                       child: Text(
  //                         location.titulo,
  //                         style: const TextStyle(
  //                           fontSize: 24,
  //                           fontFamily: "Open Sans",
  //                           fontWeight: FontWeight.w500,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               Align(
  //                 alignment: Alignment.bottomCenter,
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(left: 32.0, right: 32.0,),
  //                   child: SizedBox(
  //                     width: double.infinity,
  //                     child: ElevatedButton(
  //                       onPressed: () async {
  //                         try {
  //                           await map_utils.checkLocationPermissions().then((value) async{
  //                             _makeRoute(location);
  //                             _displayBottomSheetToStopMakingRoute(context, location);
  //                             await map_utils.goToUserLocationAfterMakeRoute(
  //                                 _mapsController,
  //                                 LatLng(location.latitude, location.longitude),
  //                                 18,
  //                                 userPositionStream.first
  //                             );
  //                           });
  //                         } on PermissionsDeniedCustomException catch(e){
  //                           map_utils.showSnackBarWithError(context, e.toString());
  //                         } on LocationServiceDisabledCustomException {
  //                           await map_utils.showDialogToAskForEnableLocationService(context);
  //                         } catch(e){
  //                           map_utils.showSnackBarWithError(context, e.toString());
  //                           await _stopMakingRoute().then((value){
  //                             Navigator.pop(context);
  //                           });
  //                         }
  //                       },
  //                       child: const Text(
  //                         "Como chegar",
  //                         style: TextStyle(
  //                           fontFamily: "Open Sans",
  //                           fontWeight: FontWeight.w500,
  //                           fontSize: 16,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         )
  //     ).closed.whenComplete(() async{
  //       _bottomSheetAnimationController!.forward();
  //       await map_utils.hideMarkerInfoWindow(
  //         _mapsController,
  //         location.titulo,
  //       );
  //     });
  //   });
  // }
  //
  // void _displayBottomSheetToStopMakingRoute(
  //     BuildContext mapPageContext, LocationEntity location
  // ){
  //   Scaffold.of(mapPageContext).showBottomSheet(
  //     elevation: 15,
  //     enableDrag: false,
  //     transitionAnimationController: _persistentBottomSheetAnimationController,
  //         (context) => SizedBox(
  //          height: MediaQuery.of(context).size.height/3,
  //           child: StreamBuilder<LatLng>(
  //             initialData: const LatLng(-3.768964, -38.478966,),
  //             stream: userPositionStream,
  //             builder: (context, snapshot) {
  //               if (snapshot.connectionState == ConnectionState.waiting) {
  //                 return const BodyWaitingState();
  //               }
  //               if (snapshot.hasData) {
  //                 return AbsorbPointer(
  //                   absorbing: _persistentBottomSheetAnimationController!.status == AnimationStatus.reverse,
  //                   child: BodyHasDataState(
  //                     location: location,
  //                     distanceBetweenLocations: map_utils.getDistanceBetweenLocations(
  //                       snapshot.data!,
  //                       LatLng(
  //                         location.latitude,
  //                         location.longitude,
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //               }
  //               if (snapshot.hasError) {
  //                 if (snapshot.error is LocationServiceDisabledException) {
  //                   return const BodyHasErrorState(
  //                     errorMessageTitle: "Oops! Sua localização está desabilitada",
  //                     errorMessageSubTitle: "Por favor, habilite a localização no seu dispositivo",
  //                   );
  //                 } else {
  //                   return const BodyHasErrorState(
  //                     errorMessageTitle: "Ocorreu um erro.",
  //                     errorMessageSubTitle: "O serviço está indisponível. Por favor, tente novamente mais tarde",
  //                   );
  //                 }
  //               }
  //               return const BodyHasErrorState(
  //                 errorMessageTitle: "Ocorreu um erro.",
  //                 errorMessageSubTitle: "O serviço está indisponível. Por favor, tente novamente mais tarde",
  //               );
  //             }
  //         ),
  //     ),
  //   ).closed.whenComplete(() async{
  //     await _stopMakingRoute();
  //     await map_utils.hideMarkerInfoWindow(_mapsController, location.titulo,);
  //   });
  // }


}

