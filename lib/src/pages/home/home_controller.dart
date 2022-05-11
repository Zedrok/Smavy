import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePageController{
  late BuildContext context;
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(	-33.044632, -71.612442),
    zoom: 14.4746,
  );

  Future init(BuildContext context) async {
    this.context = context;
  }

  void onMapCreated(GoogleMapController controller){
    _mapController.complete(controller);
  }
}