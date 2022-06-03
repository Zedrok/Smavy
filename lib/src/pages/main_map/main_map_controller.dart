// ignore_for_file: avoid_print

import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
// import 'package:cloud_firestore/cloud_firestore.dart'; //Utilizado en driver - check connect
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:smavy/src/providers/auth_provider.dart';
import 'package:smavy/src/providers/geofire_provider.dart';
import 'package:smavy/src/utils/my_progress_dialog.dart';
import 'package:smavy/src/utils/snackbar.dart';
import 'package:geocoding/geocoding.dart';

class MainMapController{
  late BuildContext context;
  late Function refresh;
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(-33.0452126,-71.6151596),
    zoom: 14.4746,
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  late Position? _position;
  // late StreamSubscription<Position> _positionStream;
  late BitmapDescriptor markerDriver;
  late GeoFireProvider _geoFireProvider;
  late AuthProvider _authProvider;
  bool isConnect = false;
  late ProgressDialog _progressDialog;
  late LatLng screenCenter;
  
  // late StreamSubscription<DocumentSnapshot> _statusSuscription; //Utilizado en driver - check connect
  late String from = '';
  late LatLng fromLatLng;

  late String to = '';
  late LatLng toLatLng;

  bool isFromSelected = true;

  Future init(BuildContext context, Function refresh) async {
    
    this.refresh = refresh;
    this.context = context;
    _geoFireProvider = GeoFireProvider();
    _authProvider = AuthProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Conectándose...');
    _position = await Geolocator.getCurrentPosition();
    markerDriver = await createMarkerImageFromAsset('assets/img/gpsDriver.png');
    checkGPS();
  }

  // void dispose(){
  //   // _positionStream.cancel();
  //   // _statusSuscription.cancel(); //Utilizado en driver - check connect
  // }

  void onMapCreated(GoogleMapController controller){
    _mapController.complete(controller);
    // controller.setMapStyle('[{"stylers":[{"saturation":25}]},{"featureType":"poi.business","stylers":[{"visibility":"off"}]},{"featureType":"poi.park","elementType":"labels.text","stylers":[{"visibility":"off"}]}]');
    // controller.setMapStyle('[{"stylers":[{"saturation":25}]},{"elementType":"geometry","stylers":[{"color":"#242f3e"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#746855"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"poi.business","stylers":[{"visibility":"off"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]},{"featureType":"poi.park","elementType":"labels.text","stylers":[{"visibility":"off"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#6b9a76"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#38414e"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9ca5b3"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#746855"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1f2835"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#f3d19c"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f3948"}]},{"featureType":"transit.station","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#515c6d"}]},{"featureType":"water","elementType":"labels.text.stroke","stylers":[{"color":"#17263c"}]}]');
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if(isLocationEnabled){
      print('GPS Activado');
      updateLocation();
      // checkIfIsConnect(); //Utilizado en driver - check connect
    }else{
      print('GPS desactivado');
      bool locationGPS = await location.Location().requestService();
      if(locationGPS){
        updateLocation();
        // checkIfIsConnect(); //Utilizado en driver - check connect
        print('Activó el GPS');
      }
    }
  }

  void updateLocation() async{
    try{
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition();
      centerPosition();

    }catch(error){
      print('Error en la localización: $error');
    }
  }

  // ignore: prefer_void_to_null
  Future<Null> setLocationDraggableInfo() async {
    // ignore: unnecessary_null_comparison
    if(initialPosition != null){
      List<Placemark> placemark = await placemarkFromCoordinates(screenCenter.latitude, screenCenter.longitude);
      Placemark address = placemark[0];

      print('el address es : $address');

      String direction = address.thoroughfare!;
      String street = address.subThoroughfare!;
      String city = address.locality!;
      String department = address.administrativeArea!;
      // String country = address.country!;

      if (isFromSelected){
        from = '$direction #$street, $city, $department';
        fromLatLng = LatLng(screenCenter.latitude, screenCenter.longitude);
        print('FROM: $from');
      }else{
        to = '$direction #$street, $city, $department';
        toLatLng = LatLng(screenCenter.latitude, screenCenter.longitude);
        print('FROM: $from');
      }

      refresh();
    }
  }

  void changeFromTo(){
    isFromSelected = !isFromSelected;

    if(isFromSelected){
      Snackbar.showSnackbar(context, 'Estas seleccionando el lugar de Origen', true);
    }else{
      Snackbar.showSnackbar(context, 'Estas seleccionando el lugar de Destino', true);
    }
  }
  

  void saveLocation() async {
    await _geoFireProvider.create(
      _authProvider.getUser()!.uid,
      _position!.latitude,
      _position!.longitude
    );
    _progressDialog.hide();
  }

  void centerPosition(){
    if(_position != null){
      animateCameraToPosition(_position!.latitude, _position!.longitude);
    }else{
      Snackbar.showSnackbar(context, 'Por favor, activa el GPS para obtener la posición', false);
    }
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

  Future animateCameraToPosition(double latitude, double longitude) async {
    // Función para animar la cámara a la posición indicada
    GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(latitude, longitude),
        zoom: 15
      )
    ));
  }

  void addMarker(
    String markerId,
    double lat,
    double lng,
    String title,
    String context,
    BitmapDescriptor iconMarker) {
    // Función para crear Marker() con las propiedades indicadas, aquí se recibe
    // el iconMarker ya modificado en getBytesFromAsset
    MarkerId id = MarkerId(markerId);
    
    Marker marker = Marker(
      markerId: id,
      icon: iconMarker,
      position: LatLng(lat,lng),
      infoWindow: InfoWindow(title: title, snippet: context),
      draggable: false,
      zIndex: 2,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      rotation: _position!.heading
    );

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
    ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: pixelRatio.round() * 25
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  // De aquí hacia abajo hay funciones relacionadas a compartir
  // la ubicación de un dispositivo en tiempo real, subiendo y eliminando
  // los datos de Firestore, un botón debería ejecutar la función connect()
  // y esto ejecutaría el código que hay hacia abajo.

  void connect(){
    // Esta función se ejecuta cuando se presiona un botón, esto
    // habilita o deshabilita el rastreo del dispositivo.
    if(isConnect){
      disconnect();
    }else{
      _progressDialog.show();
      updateLocation();
    }
  }

  void disconnect(){
    // Esta función deja de actualizar la posición y elimina la posición de la db
    // _positionStream.cancel();
    _geoFireProvider.delete(_authProvider.getUser()!.uid);
  }


  //Utilizado en driver - check connect
  // void checkIfIsConnect(){
  //    Stream<DocumentSnapshot> status =
  //    _geoFireProvider.getLocationByIdStream(_authProvider.getUser()!.uid);

  //    _statusSuscription = status.listen((DocumentSnapshot document) {
  //      if(document.exists){
  //        isConnect = true;
  //      }else{
  //        isConnect = false;
  //      }
  //    });

  //    refresh();
  // }

  // Esta función funciona para actualizar la posición automáticamente
  // void updateLocation() async{
  //   try{
  //     await _determinePosition();
  //     _position = await Geolocator.getLastKnownPosition();
  //     centerPosition();
  //     // saveLocation();
  //     addMarker(
  //       'driver',
  //       _position!.latitude,
  //       _position!.longitude,
  //       'Tu Posición',
  //       '',
  //       markerDriver
  //     );
  //     refresh();
  //     _positionStream = Geolocator.getPositionStream(
  //       locationSettings: const LocationSettings(
  //         accuracy: LocationAccuracy.best,
  //         distanceFilter: 1
  //       )
  //     ).listen((Position position){
  //       _position = position;
  //       addMarker(
  //         'driver',
  //         _position!.latitude,
  //         _position!.longitude,
  //         'Tu Posición',
  //         '',
  //         markerDriver
  //       );
  //       animateCameraToPosition(position.latitude, position.longitude);
  //       // saveLocation();
  //       refresh();
  //     });
  //   }catch(error){
  //     print('Error en la localización: $error');
  //   }
  // }
}