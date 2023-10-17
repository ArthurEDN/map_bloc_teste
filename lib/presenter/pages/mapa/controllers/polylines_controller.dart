import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineController extends ValueNotifier<Set<Polyline>> {
  PolylineController() : super(<Polyline>{});

  late StreamSubscription<LatLng> _userPositionStreamSubscription;

  // void makeRoute(LatLng targetLocationLatLng, Stream<LatLng> userPositionStream) {
  //   _userPositionStreamSubscription = userPositionStream.listen(
  //       (LatLng userPosition) {
  //         _createRoutePolyline(userPosition, targetLocationLatLng);
  //     },
  //     cancelOnError: true,
  //   );
  // }

  void createRoutePolyline(LatLng userPosition, LatLng targetLocationLatLng) {
    value
      ..clear()
      ..add(
        Polyline(
          polylineId: const PolylineId("rota"),
          points: [userPosition, targetLocationLatLng],
          width: 3,
          color: Colors.blueAccent,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
        ),
      );
    notifyListeners();
  }

  Future<void> stopMakingRoute() async {
    value.clear();
    // await _userPositionStreamSubscription.cancel();
    notifyListeners();
  }
}
