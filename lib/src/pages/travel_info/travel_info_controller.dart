// ignore_for_file: avoid_print

import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smavy/src/models/directions_model.dart';
import 'package:smavy/src/models/directions_repository.dart';
import 'package:smavy/src/pages/api/environment.dart';
import 'package:smavy/src/utils/snackbar.dart';
import 'package:location/location.dart' as location;

class TravelInfoController{
  final DirectionsService directionsService = DirectionsService();
  final Completer<GoogleMapController> _mapController = Completer();
  late BuildContext context;
  late Function refresh;
  

  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(-33.0452126, -71.6151596),
    zoom: 14.4746,
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  late BitmapDescriptor markerDriver;
  late BitmapDescriptor markerPlace;
  late String time = "";
  late String distance = "";
  late Directions info;

  late String fromText = "";
  late String toText = "";
  late LatLng fromLatLng;
  late LatLng toLatLng;
  late List<Map<String, dynamic>> listaDirecciones = [];
  late bool rutaComenzada = false;

  Set<Polyline> polylines = {};
  List<LatLng> points = [];
  
  late Position? _position;
  // ignore: unused_field
  late StreamSubscription<Position> _positionStream;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    checkGPS();

    Map<String, dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map <String, dynamic>;
    
    fromText = arguments['fromText'];
    toText = arguments['toText'];
    fromLatLng = arguments['fromLatLng'];
    toLatLng = arguments['toLatLng'];
    listaDirecciones = arguments['listaDirecciones'];

    print('fromText $fromText');
    print('toText $toText');
    print('fromLatLng $fromLatLng');
    print('toLatLng $toLatLng');
    print('listaDirecciones = $listaDirecciones');
    
    
    markerDriver = await createMarkerImageFromAsset('assets/img/gpsDriver.png');
    _position = await Geolocator.getCurrentPosition();
  }

  void onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);
    await addMarkerPlace();
    await setPolylines();
    // controller.setMapStyle('[{"stylers":[{"saturation":25}]},{"featureType":"poi.business","stylers":[{"visibility":"off"}]},{"featureType":"poi.park","elementType":"labels.text","stylers":[{"visibility":"off"}]}]');
    // controller.setMapStyle('[{"stylers":[{"saturation":25}]},{"elementType":"geometry","stylers":[{"color":"#242f3e"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#746855"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"poi.business","stylers":[{"visibility":"off"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]},{"featureType":"poi.park","elementType":"labels.text","stylers":[{"visibility":"off"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#6b9a76"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#38414e"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9ca5b3"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#746855"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1f2835"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#f3d19c"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f3948"}]},{"featureType":"transit.station","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#515c6d"}]},{"featureType":"water","elementType":"labels.text.stroke","stylers":[{"color":"#17263c"}]}]');
  }

  Future<void> setPolylines() async{
    PointLatLng pointFromLatLng = PointLatLng(fromLatLng.latitude, fromLatLng.longitude);
    PointLatLng pointToLatLng = PointLatLng(toLatLng.latitude, toLatLng.longitude);

    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      Environment.API_KEY_MAPS,
      pointFromLatLng,
      pointToLatLng
    );

    for(PointLatLng point in result.points){
      points.add(LatLng(point.latitude, point.longitude));
    }

    Polyline polyline = Polyline(
      polylineId: const PolylineId('overview_polyline'),
      color: Colors.teal,
      width: 3,
      points: info.polylinePoints.map((e) => LatLng(e.latitude, e.longitude)).toList(),
    );

    polylines.add(polyline);

    await refresh();
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      print('GPS Activado');
      // checkIfIsConnect(); //Utilizado en driver - check connect
    } else {
      print('GPS desactivado');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        // checkIfIsConnect(); //Utilizado en driver - check connect
        print('Activó el GPS');
      }
    }
  }

  void comenzarRuta() async {
    rutaComenzada = true;
    updateLocation();
  }

  // Esta función funciona para actualizar la posición automáticamente
  void updateLocation() async{
    try{
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition();
      centerPosition();
      // saveLocation();
      addMarker(
        'driver',
        _position!.latitude,
        _position!.longitude,
        'Tu Posición',
        '',
        markerDriver
      );
      refresh();
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 1
        )
      ).listen((Position position){
        _position = position;
        addMarker(
          'driver',
          _position!.latitude,
          _position!.longitude,
          'Tu Posición',
          '',
          markerDriver
        );
        animateCameraToPosition(position.latitude, position.longitude);
        // saveLocation();
        refresh();
      });
    }catch(error){
      print('Error en la localización: $error');
    }
  }

  void addMarker(String markerId, double lat, double lng, String title,
    String context, BitmapDescriptor iconMarker) {
    // Función para crear Marker() con las propiedades indicadas, aquí se recibe
    // el iconMarker ya modificado en getBytesFromAsset
    MarkerId id = MarkerId(markerId);

    Marker marker = Marker(
        markerId: id,
        icon: iconMarker,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title, snippet: context),
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        rotation: _position!.heading);

    markers[id] = marker;
  }

  Future<void> addMarkerPlace() async {
    // Función para crear Marker() con las propiedades indicadas, aquí se recibe
    // el iconMarker ya modificado en getBytesFromAsset
    
    Directions respuesta = (await DirectionsRepository().getDirections(
      origin: fromLatLng,
      destination: toLatLng,
      waypoints: listaDirecciones
    ))!;
  
    info =  Directions(
      bounds: respuesta.bounds,
      polylinePoints: respuesta.polylinePoints,
      totalDistance: respuesta.totalDistance,
      totalDuration: respuesta.totalDuration
    );

    distance = info.totalDistance;
    time = info.totalDuration;

    MarkerId idMarkerFrom = const MarkerId('markerFrom');

    Marker marker = Marker(
      markerId: idMarkerFrom,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      position: LatLng(fromLatLng.latitude, fromLatLng.longitude),
      infoWindow: const InfoWindow(title: 'markerFrom'),
    );

    markers[idMarkerFrom] = marker;

    int i = 0;
    for (var element in listaDirecciones) {
      i++;

      MarkerId idMarker = MarkerId('markerWaypoint{$i}');

      Marker markerWaypoint = Marker(
        markerId: idMarker,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        position: LatLng(double.parse(element['lat']), double.parse(element['lng'])),
        infoWindow: InfoWindow(title: 'markerWaypoint{$i}'),
      );

      markers[idMarker] = markerWaypoint;
    }

    MarkerId idMarkerTo = const MarkerId('markerTo');

    Marker marker2 = Marker(
      markerId: idMarkerTo,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      position: LatLng(toLatLng.latitude, toLatLng.longitude),
      infoWindow: const InfoWindow(title: 'markerTo'),
    );

    markers[idMarkerTo] = marker2;
  
    await refresh();
  }

  Future<BitmapDescriptor> createMarkerImageFromAsset(String path) async {
    // Función para crear un marcador desde una imagen en los assets,
    // el comentario corresponde a la creación de un marker a partir de una imagen sin editar
    final Uint8List markerIcon = await getBytesFromAsset(path);
    // ImageConfiguration configuration = const ImageConfiguration();
    // BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.fromAssetImage(configuration, path);

    return BitmapDescriptor.fromBytes(markerIcon);
  }

  Future<Uint8List> getBytesFromAsset(String path) async {
    // Función para extraer los bits de un Asset para así editar su tamaño
    // y después insertarlo en la propiedad icon de un Marker()
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: pixelRatio.round() * 25);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  
  Future<Position> _determinePosition() async {
    // Determina la posición actual del dispositivo.
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si los servicios están habilitados ya no continúa.
      return Future.error('Location services are disabled.');
    }
    // Si los servicios están deshabilitados, solicita activarlos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void centerPosition() {
    if (_position != null) {
      animateCameraToPosition(_position!.latitude, _position!.longitude);
    } else {
      Snackbar.showSnackbar(
        context, 'Por favor, activa el GPS para obtener la posición', false);
    }
  }

  Future animateCameraToPosition(double latitude, double longitude) async {
    // Función para animar la cámara a la posición indicada
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 0, target: LatLng(latitude, longitude), zoom: 15)));
  }
}