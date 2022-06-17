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
import 'package:smavy/src/models/travel_history.dart';
import 'package:smavy/src/providers/auth_provider.dart';
import 'package:smavy/src/providers/travel_history_provider.dart';
import 'package:smavy/src/utils/snackbar.dart';
import 'package:location/location.dart' as location;

class TravelMapController{
  final DirectionsService directionsService = DirectionsService();
  final Completer<GoogleMapController> _mapController = Completer();
  late BuildContext context;
  late Function refresh;
  final stopwatch = Stopwatch();
  List<RouteLeg> routeLegs = [];

  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(-33.0452126, -71.6151596),
    zoom: 14.4746,
  );

  
  late AuthProvider _authProvider;
  late TravelHistoryProvider _travelHistoryProvider;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  late BitmapDescriptor markerDriver;
  late BitmapDescriptor markerPlace;
  late String time = "";
  late String distance = "";
  late Directions info;
  int accumulatedDuration = 0;

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
    
    _authProvider = AuthProvider();
    _travelHistoryProvider = TravelHistoryProvider();

    checkGPS();

    Map<String, dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map <String, dynamic>;

    fromText = arguments['fromText'];
    toText = arguments['toText'];
    fromLatLng = arguments['fromLatLng'];
    toLatLng = arguments['toLatLng'];
    listaDireccionesMainMap = arguments['listaDirecciones'];
    
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
      encodedPolyline: respuesta.encodedPolyline,
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
    RouteLeg newLeg;

    for(var leg in info.legs){
      List<PointLatLng> legPolyline = [];
      String encodedLegPolyline = "";
      
      for(var step in leg['steps']){
        legPolyline += PolylinePoints().decodePolyline(step['polyline']['points']);
        encodedLegPolyline += step['polyline']['points'];
      }

      newLeg = RouteLeg(
        distance: leg['distance']['value'],
        startAddress: leg['start_address'],
        startLocation: LatLng(leg['start_location']['lat'].toDouble(), leg['start_location']['lng'].toDouble()),
        endAddress: leg['end_address'],
        endLocation: LatLng(leg['end_location']['lat'].toDouble(), leg['end_location']['lng'].toDouble()),
        polyline: legPolyline,
        encodedPolyline: encodedLegPolyline,
        duration: const Duration(seconds: 0),
      );

      leg['polyline'] = legPolyline;

      routeLegs.add(newLeg);
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

  void setLastLegDuration(Duration duration) {
    if(currentLeg == 0){
      routeLegs[currentLeg].duration = duration;
      accumulatedDuration += routeLegs[currentLeg].duration.inMilliseconds;
      print('duración del tramo $currentLeg: ${routeLegs[currentLeg].duration.inMilliseconds}');
      print('duracion total: ${duration.inMilliseconds}');
      print('duracion acumulada: $accumulatedDuration');
    }else{
      routeLegs[currentLeg].duration = Duration(milliseconds: ((duration.inMilliseconds) - accumulatedDuration));
      accumulatedDuration += routeLegs[currentLeg].duration.inMilliseconds;
      print('duración del tramo $currentLeg: ${routeLegs[currentLeg].duration.inMilliseconds}');
      print('duracion total: ${duration.inMilliseconds}');
      print('duracion acumulada: $accumulatedDuration');
    }
  }

  void nextLeg() {
    currentLeg++;
    currentStartAddress = routeLegs[currentLeg].startAddress;
    currentEndAddress = routeLegs[currentLeg].endAddress;
    if(currentLeg >= routeLegs.length-1){
      rutaTerminada = true;
    }else{
      rutaTerminada = false;
    }
    setPolyline(routeLegs[currentLeg].polyline);
    refresh();
  }

  void previousLeg() {
    currentLeg--;
    rutaTerminada = false;
    currentStartAddress = routeLegs[currentLeg].startAddress;
    currentEndAddress = routeLegs[currentLeg].endAddress;
    setPolyline(routeLegs[currentLeg].polyline);
    refresh();
  }

  void comenzarRuta() async {
    currentStartAddress = fromText;
    currentEndAddress = listaDireccionesTravelMap[currentLeg]['direccion'];
    setPolyline(routeLegs[currentLeg].polyline);
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

  void finishRoute(Duration totalDuration) {
    saveTravelHistory(totalDuration);
  }

  void saveTravelHistory(Duration totalDuration) async {
    int totalDistance = calculateTotalDistance();
    TravelHistory travelHistory = TravelHistory(
      idUsuario: _authProvider.getUser()!.uid,
      fromText: fromText,
      fromLatLng: fromLatLng,
      toText: toText,
      toLatLng: toLatLng,
      totalDuration: totalDuration,
      totalDistance: totalDistance,
      overviewPolyline: info.encodedPolyline,
      legs: routeLegs,
      timestamp: DateTime.now().millisecondsSinceEpoch
    );

    print('idUsuario: ${travelHistory.idUsuario}');
    print('fromText: ${travelHistory.fromText}');
    print('toText: ${travelHistory.toText}');
    print('totalDistance: ${travelHistory.totalDistance}');
    print('totalDuration: ${travelHistory.totalDuration}');
    print('timestamp: ${travelHistory.timestamp}');

    String id = await _travelHistoryProvider.create(travelHistory);
     
    Navigator.pushNamedAndRemoveUntil(context, 'travelSummary', (route) => false, arguments: id);
  }

  int calculateTotalDistance(){
    int totalDistance = 0;
    for(RouteLeg leg in routeLegs){
      totalDistance += leg.distance;
    }
    return totalDistance;
  }

  Widget legStartIcon(){
    if(currentLeg == 0){
      return Container(
        decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(360),  
        ),
        child: Container(
          alignment: Alignment.topCenter,
          child: const Center(
            child: Icon(
              Icons.home,
              color: Colors.white,
              size: 28,
            )
          )
        )
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(360),
        border: Border.all(
          color: Colors.teal.shade400,
          width: 3
        )
      ),
      child: Container(
        alignment: Alignment.topCenter,
        child: Text(
          (currentLeg).toString(),
          textAlign: ui.TextAlign.center,
          style: TextStyle(
            color: Colors.teal.shade500,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      )
    );
  }

  Widget legEndIcon(){
    if(currentLeg == routeLegs.length-1){
      return Container(
        decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(360),  
        ),
        child: Container(
          alignment: Alignment.topCenter,
          child: const Center(
            child: Icon(
              Icons.my_location,
              color: Colors.white,
              size: 28,
            )
          )
        )
      );
    }
    return ((){
      if(rutaComenzada){
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(360),
            border: Border.all(
              color: Colors.teal.shade400,
              width: 3
            )
          ),
          child: Container(
            alignment: Alignment.topCenter,
            child: Text(
              (currentLeg+1).toString(),
              textAlign: ui.TextAlign.center,
              style: TextStyle(
                color: Colors.teal.shade500,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          )
        );
      }
      return Container(
        decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(360),  
        ),
        child: Container(
          alignment: Alignment.topCenter,
          child: const Center(
            child: Icon(
              Icons.my_location,
              color: Colors.white,
              size: 28,
            )
          )
        )
      );
    }());
  }
}