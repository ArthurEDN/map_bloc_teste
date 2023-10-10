import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_bloc_teste/bloc/route_bloc/route_bloc.dart';
import 'package:map_bloc_teste/entity/location_entity.dart';

class BodyHasDataState extends StatelessWidget {
  final BuildContext mapPageContext;
  final LocationEntity location;
  final double distanceBetweenLocations;

  const BodyHasDataState({
    super.key,
    required this.mapPageContext,
    required this.location,
    required this.distanceBetweenLocations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 24.0),
              child: IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.arrow_back_outlined),
                  color: const Color(0xFF005B9B),
                  onPressed: () => Navigator.pop(context)),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 26.0, right: 24),
                child: Text(
                  "Caminho para ${location.titulo}",
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
        Center(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 32.0, bottom: 2.0),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFFD3EBFF)),
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, top: 6.0, bottom: 6.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.explore_outlined,
                      size: 36,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: "Distância\n",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.0,
                                  fontFamily: 'Open Sans'),
                            ),
                            TextSpan(
                              text:
                                  _metersOrKilometer(distanceBetweenLocations),
                              style: const TextStyle(
                                color: Color(0xFF0088CC),
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Open Sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          mapPageContext
                              .read<RouteBloc>()
                              .add(const EndRouteEvent());
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Finalizar rota",
                          style: TextStyle(
                            fontFamily: "Open Sans",
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _metersOrKilometer(double distance) {
    if (distance >= 1000) {
      double distanceInKilometer = distance / 1000;
      return "${distanceInKilometer.toStringAsFixed(1)} km";
    }
    return "${distance.toStringAsFixed(0)} m";
  }
}

class BodyWaitingState extends StatelessWidget {
  const BodyWaitingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const LinearProgressIndicator(),
        const Spacer(),
        const Expanded(
            child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            "Traçando sua rota",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontFamily: "Open Sans",
              fontWeight: FontWeight.w500,
            ),
          ),
        )),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancelar",
                  ),
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class BodyHasErrorState extends StatelessWidget {
  final BuildContext mapPageContext;
  final String errorMessageTitle;
  final String errorMessageSubTitle;
  const BodyHasErrorState({
    Key? key,
    required this.mapPageContext,
    required this.errorMessageTitle,
    required this.errorMessageSubTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 24.0,
            ),
            child: Text(
              errorMessageTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Open Sans'),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              errorMessageSubTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Open Sans'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 24.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  mapPageContext.read<RouteBloc>().add(const EndRouteEvent());
                  Navigator.pop(context);
                },
                child: const Text(
                  "Ok",
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
