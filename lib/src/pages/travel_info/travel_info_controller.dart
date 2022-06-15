// ignore_for_file: avoid_print

import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';

import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:smavy/src/models/directions_model.dart';
import 'package:smavy/src/models/directions_repository.dart';
import 'package:smavy/src/utils/snackbar.dart';
import 'package:location/location.dart' as location;

class TravelInfoController{
  final DirectionsService directionsService = DirectionsService();
  final Completer<GoogleMapController> _mapController = Completer();
  late BuildContext context;
  late Function refresh;
  final stopwatch = Stopwatch();
  List<Map<String, dynamic>> routeLegs = [];

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
  late List<Map<String, dynamic>> listaDireccionesMainMap = [];
  late List<Map<String, dynamic>> listaDireccionesTravelMap = [];

  int currentLeg = 0;
  late String currentStartAddress;
  late String currentEndAddress;

  bool rutaComenzada = false;
  bool rutaTerminada = false;

  List<MarkerData> customMarkers = [];
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
    listaDireccionesMainMap = arguments['listaDirecciones'];

    print('fromText $fromText');
    print('toText $toText');
    print('fromLatLng $fromLatLng');
    print('toLatLng $toLatLng');
    print('listaDirecciones = $listaDireccionesMainMap');
    
    
    markerDriver = await createMarkerImageFromAsset('assets/img/gpsDriver.png');
    _position = await Geolocator.getCurrentPosition();
  }

  void onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);
    await getRouteData();
    await setMarkers();
    await setPolyline();
    animateCameraToPosition(fromLatLng.latitude, fromLatLng.longitude);
    Future.delayed(const Duration(milliseconds: 200), 
      refresh()
    );
  }

  Future<void> getRouteData() async {
    Directions respuesta = (await DirectionsRepository().getDirections(
      origin: fromLatLng,
      destination: toLatLng,
      waypoints: listaDireccionesMainMap
    ))!;
  
    info =  Directions(
      legs: respuesta.legs,
      bounds: respuesta.bounds,
      polylinePoints: respuesta.polylinePoints,
      totalDistance: respuesta.totalDistance,
      totalDuration: respuesta.totalDuration,
      waypointsOrder: respuesta.waypointsOrder
    );

    distance = info.totalDistance;
    time = info.totalDuration;
    createLegsAndPolylines();
    _reorderMarkers();
  }

  void _reorderMarkers(){
    List<Map<String, dynamic>> listaAuxiliar = [];
    Map<String, dynamic> direccionAux = {};
    int i = 1;

    if(listaDireccionesMainMap.isNotEmpty){
      for(var direccion in listaDireccionesMainMap){
        direccionAux = {
          'id': direccion['id'],
          'direccion': direccion['direccion'],
          'lat': direccion['lat'],
          'lng': direccion['lng']
        };
        listaAuxiliar.add(direccionAux);
      }

      for(var posicion in info.waypointsOrder){
        listaAuxiliar[posicion]['id'] = i;
        listaDireccionesTravelMap.add(listaAuxiliar[posicion]);
        i++;
      }
    }
  }

  Future<void> createLegsAndPolylines()async {
    Map<String, dynamic> newLeg = {};

    for(var leg in info.legs){
      List<PointLatLng> legPolyline = []; 
      
      for(var step in leg['steps']){
        legPolyline += PolylinePoints().decodePolyline(step['polyline']['points']);
      }

      newLeg = {
        'distance': leg['distance'],
        'steps': leg['steps'],
        'polyline': legPolyline
      };

      routeLegs.add(newLeg);
      print('polyline: '); print(legPolyline);
    }
  }

  Future<void> setPolyline([List<PointLatLng>? polylineList]) async {
    polylines = {};

    if(polylineList == null){
      Polyline polyline = Polyline(
          polylineId: const PolylineId('overview_polyline'),
          color: Colors.teal,
          width: 3,
          points: info.polylinePoints.map((e) => LatLng(e.latitude, e.longitude)).toList(),
        );
      polylines.add(polyline);
    }else{
      Polyline polyline = Polyline(
          polylineId: const PolylineId('overview_polyline'),
          color: Colors.teal,
          width: 3,
          points: polylineList.map((e) => LatLng(e.latitude, e.longitude)).toList(),
        );
      polylines.add(polyline);
    }

     refresh();
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

  void nextLeg() {
    if(currentLeg < routeLegs.length-1){
      currentLeg++;
      print(currentLeg);
      if(currentLeg < listaDireccionesTravelMap.length){
        currentStartAddress = listaDireccionesTravelMap[currentLeg-1]['direccion'];
        currentEndAddress = listaDireccionesTravelMap[currentLeg]['direccion'];
      }else{
        currentStartAddress = listaDireccionesTravelMap.last['direccion'];
        currentEndAddress = toText;
        rutaTerminada = true;
      }

      if(currentLeg < (routeLegs.length)){
        setPolyline((routeLegs[currentLeg]['polyline'] as List<PointLatLng>));
      }
    }
  }

  void previousLeg() {
    if(currentLeg > 0){
      currentLeg--;
      rutaTerminada = false;
      
      print(currentLeg);
      if(currentLeg > 0){
        currentStartAddress = listaDireccionesTravelMap[currentLeg-1]['direccion'];
        currentEndAddress = listaDireccionesTravelMap[currentLeg]['direccion'];
      }else{
        currentStartAddress = fromText;
        currentEndAddress = listaDireccionesTravelMap[currentLeg]['direccion'];
      }

      if(currentLeg >= 0){
        setPolyline((routeLegs[currentLeg]['polyline'] as List<PointLatLng>));
      }else{
      }
    }
  }

  void comenzarRuta() async {
    currentStartAddress = fromText;
    currentEndAddress = listaDireccionesTravelMap[currentLeg]['direccion'];
    setPolyline((routeLegs[currentLeg]['polyline'] as List<PointLatLng>));
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

  Future<Uint8List> convertWidgetIntoUint8List(Widget widgetMarker) async  {
    final _controller = ScreenshotController();
    final bytes = await _controller.captureFromWidget(widgetMarker, delay: Duration.zero);
    return bytes;
 }

  Widget _customMarker(String text, Color color) {
    return Stack(
      children: [
        SizedBox(
          height: 45,
          width: 45,
          child: 
          Center(
            child: Icon(
              Icons.add_location,
              color: color,
              size: 50,
            ),
          )
        ),
        Positioned(
          left: 15,
          top: 8,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                text,
                style: TextStyle(color: Colors.teal[800],
                fontWeight: FontWeight.bold),
              )
            ),
          ),
        )
      ],
    );
  }
  
  Widget _customFromMarker(Color color) {
    return Stack(
      children: [
        SizedBox(
          height: 45,
          width: 45,
          child: 
          Center(
            child: Icon(
              Icons.add_location,
              color: color,
              size: 50,
            ),
          )
        ),
        Positioned(
          left: 15,
          top: 8,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(10)),
            child: const Center(
              child: Icon(
                Icons.home,
                color: Colors.white,
                size: 20
              )
            ),
          ),
        )
      ],
    );
  }

  Widget _customToMarker(Color color) {
    return Stack(
      children: [
        SizedBox(
          height: 45,
          width: 45,
          child: 
          Center(
            child: Icon(
              Icons.add_location,
              color: color,
              size: 50,
            ),
          )
        ),
        Positioned(
          left: 15,
          top: 8,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(10)),
            child: const Center(
              child: Icon(
                Icons.my_location_outlined,
                color: Colors.white,
                size: 20,
              )
            ),
          ),
        )
      ],
    );
  }

  Future<void> setPlaceMarker(Map<String, dynamic> direccion) async {
    MarkerId id = MarkerId('${direccion['id']}');
    Widget widgetMarker = _customMarker('${direccion['id']}', Colors.teal);
    Uint8List markerIcon = await convertWidgetIntoUint8List(widgetMarker);

    Marker markerData = Marker(
      markerId: id,
      position: LatLng(direccion['lat'], direccion['lng']),
      icon: BitmapDescriptor.fromBytes(markerIcon)
    );
    markers[id] = markerData;
  }
  
  Future<void> setMarkers() async {
    // Función para crear Marker() con las propiedades indicadas, aquí se recibe
    // el iconMarker ya modificado en getBytesFromAsset
    
    MarkerId id = const MarkerId('markerFrom');
    Widget widgetMarker = _customFromMarker(Colors.red);
    Uint8List markerIcon = await convertWidgetIntoUint8List(widgetMarker);

    Marker markerData = Marker(
      markerId: id,
      position: LatLng(fromLatLng.latitude, fromLatLng.longitude),
      icon: BitmapDescriptor.fromBytes(markerIcon)
    );
    markers[id] = markerData;

    if(listaDireccionesTravelMap.isNotEmpty){
      for(var direccion in listaDireccionesTravelMap){
        await setPlaceMarker(direccion);
      }
    }

    id = const MarkerId('markerTo');
    widgetMarker = _customToMarker(Colors.red);
    markerIcon = await convertWidgetIntoUint8List(widgetMarker);

    markerData = Marker(
      markerId: id,
      position: LatLng(toLatLng.latitude, toLatLng.longitude),
      icon: BitmapDescriptor.fromBytes(markerIcon)
    );
    markers[id] = markerData;

    await Future.delayed(const Duration(milliseconds: 200), refresh());
    refresh();
  }

  void addMarker(String markerId, double lat, double lng, String title, String context, BitmapDescriptor iconMarker) {
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
        bearing: 0, target: LatLng(latitude, longitude), zoom: 16)));
  }
}