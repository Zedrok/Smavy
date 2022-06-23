// ignore_for_file: avoid_print

import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
// import 'package:cloud_firestore/cloud_firestore.dart'; //Utilizado en driver - check connect
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:location/location.dart' as location;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:screenshot/screenshot.dart';
import 'package:smavy/src/pages/api/environment.dart';
import 'package:smavy/src/providers/auth_provider.dart';
import 'package:smavy/src/providers/geofire_provider.dart';

import 'package:smavy/src/models/google_places_flutter2.dart';

import 'package:smavy/src/utils/my_progress_dialog.dart';
import 'package:smavy/src/utils/snackbar.dart';
import 'package:geocoding/geocoding.dart';

class MainMapController {
  late BuildContext context;
  late Function refresh;
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(-33.0452126, -71.6151596),
    zoom: 14.4746,
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  late Position? _position;
  late BitmapDescriptor markerDriver;
  late GeoFireProvider _geoFireProvider;
  late AuthProvider _authProvider;
  bool isConnect = false;
  late ProgressDialog progressDialog;

  late LatLng screenCenter = const LatLng(-33.0452126, -71.6151596);

  // late StreamSubscription<DocumentSnapshot> _statusSuscription; //Utilizado en driver - check connect
  late LatLng fromLatLng = const LatLng(-33.0452126, -71.6151596);
  TextEditingController fromText = TextEditingController();
  LatLng fromPrev = const LatLng(-33.0452126, -71.6151596);

  late LatLng toLatLng = const LatLng(-33.0452126, -71.6151596);
  TextEditingController toText = TextEditingController();
  LatLng toPrev = const LatLng(-33.0452126, -71.6151596);

  late LatLng searchLatLng = const LatLng(-33.0452126, -71.6151596);
  TextEditingController searchText = TextEditingController();
  LatLng searchPrev = const LatLng(-33.0452126, -71.6151596);

  late List<Map<String, dynamic>> listaDirecciones = [];
  List<MarkerData> customMarkers = [];

  bool isFromSelected = true;
  bool isToSelected = false;
  bool isSearchSelected = false;

  Future init(BuildContext context, Function refresh) async {
    this.refresh = refresh;
    this.context = context;
    _geoFireProvider = GeoFireProvider();
    _authProvider = AuthProvider();
    progressDialog = MyProgressDialog.createProgressDialog(context, 'Obteniendo ubicación...');
    checkGPS();
    _position = await Geolocator.getCurrentPosition();
    markerDriver = await createMarkerImageFromAsset('assets/img/gpsDriver.png');
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    print('Se creó el mapita');
    refresh();
  }
  
  void goToTravelInfoPage(){
    if(validarDireccion(fromText.text) && validarDireccion(toText.text)){
      if(validarFromTo())
      {
        Navigator.pushNamed(context, 'travelMap', arguments:{
          'fromText': fromText.text,
          'toText': toText.text,
          'fromLatLng': fromLatLng,
          'toLatLng': toLatLng,
          'listaDirecciones': listaDirecciones,
          'rutaRepetida': false
        });
      }else{
        Snackbar.showSnackbar(context, 'El origen y el destino no pueden ser el mismo.');
      }
    }else{
      Snackbar.showSnackbar(context, 'Por favor, revise el origen y el destino.');
    }
    
  }

  bool validarFromTo(){
    if((fromLatLng.latitude.compareTo(toLatLng.latitude) == 0 &&
      fromLatLng.longitude.compareTo(toLatLng.longitude) == 0)){
      return false;
    }
    return true;
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
  
  Future<void> agregarDireccion() async {
    Map<String, dynamic> nuevaDireccion = {};
    double lat = searchLatLng.latitude;
    double lng = searchLatLng.longitude;
    String text = searchText.text;
    
    if(validarDireccion(text)){
      if (validarPosicion(LatLng(lat,lng))) {
        if(listaDirecciones.isNotEmpty){
          nuevaDireccion = {
            'id': (int.parse(listaDirecciones.last['id'])+1).toString(),
            'direccion': text,
            'lat': lat,
            'lng': lng
          };
        }else{
          nuevaDireccion = {
            'id': '1',
            'direccion': text,
            'lat': lat,
            'lng': lng
          };
        }
        
        listaDirecciones.add(nuevaDireccion);
        await setPlaceMarker(nuevaDireccion);
        
        refresh();
      }else{
        Snackbar.showSnackbar(context, 'Por favor, espere a que la dirección cambie antes de agregarla.', false);
      }
    }else{
      Snackbar.showSnackbar(context, 'Por favor ingrese una ubicación válida.', false);
    }

    print(listaDirecciones.last);
  }

  bool validarPosicion(LatLng posicion){
    if(screenCenter == posicion){
      return true;
    }
    return false;
  }
  
  bool validarDireccion(String text) {
    var trimmed = text.trim();
    if(trimmed[0].compareTo('#') == 0){
      return false;
    }
    return true;
  }

  Future<void> setFromMarker() async {
    double lat = screenCenter.latitude;
    double lng = screenCenter.longitude;

    MarkerId id = const MarkerId('markerFrom');
    Widget widgetMarker = _customFromMarker(Colors.red);
    Uint8List markerIcon = await convertWidgetIntoUint8List(widgetMarker);

    Marker markerData = Marker(
      markerId: id,
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.fromBytes(markerIcon)
    );
    markers[id] = markerData;
    refresh();
  }

  Future<void> setToMarker() async {
    double lat = screenCenter.latitude;
    double lng = screenCenter.longitude;

    MarkerId id = const MarkerId('markerTo');
    Widget widgetMarker = _customToMarker(Colors.red);
    Uint8List markerIcon = await convertWidgetIntoUint8List(widgetMarker);

    Marker markerData = Marker(
      markerId: id,
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.fromBytes(markerIcon)
    );
    markers[id] = markerData;
    refresh();
  }

  Future<void> resetMarkers() async { 
    MarkerId id = const MarkerId('markerFrom');
    Widget widgetMarker = _customFromMarker(Colors.red);
    Uint8List markerIcon = await convertWidgetIntoUint8List(widgetMarker);

    Marker markerData = Marker(
      markerId: id,
      position: LatLng(fromLatLng.latitude, fromLatLng.longitude),
      icon: BitmapDescriptor.fromBytes(markerIcon)
    );
    markers[id] = markerData;

    for(var direccion in listaDirecciones){
      await setPlaceMarker(direccion);
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

  void deleteDireccion(Map<String, dynamic> dir) async {
    for(var direccion in listaDirecciones){
      if(int.parse(direccion['id']) > int.parse(dir['id'])){
        direccion['id'] = (int.parse(direccion['id'])-1).toString(); 
      }
    }

    listaDirecciones.remove(dir);
    markers.clear();
   
    resetMarkers();
    
    refresh();
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationEnabled) {
      print('GPS Activado');
      updateLocation();
      // checkIfIsConnect(); //Utilizado en driver - check connect
    } else {
      print('GPS desactivado');
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        updateLocation();
        // checkIfIsConnect(); //Utilizado en driver - check connect
        print('Activó el GPS');
      }
    }
  }

  void updateLocation() async {
    try {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition();
      centerPosition();
    } catch (error) {
      print('Error en la localización: $error');
    }
  }

  // ignore: prefer_void_to_null
  Future<Null> setLocationDraggableInfo() async {
    // ignore: unnecessary_null_comparison
    if (initialPosition != null) {
      List<Placemark> placemark = await placemarkFromCoordinates(
          screenCenter.latitude, screenCenter.longitude);
      Placemark address = placemark[0];
      String direction = address.thoroughfare!;
      String street = address.subThoroughfare!;
      String city = address.locality!;
      String department = address.administrativeArea!;
      // String country = address.country!;

      if (isFromSelected) {
        if (screenCenter.latitude.compareTo(fromPrev.latitude) != 0 ||
            screenCenter.longitude.compareTo(fromPrev.longitude) != 0) {
          if(toText.text.isEmpty || 
            ((toLatLng.latitude.compareTo(fromLatLng.latitude) == 0) &&
            (toLatLng.longitude.compareTo(fromLatLng.longitude) == 0)
          )){
              toPrev = screenCenter;
              toText.text = '$direction #$street, $city, $department';
              toLatLng = LatLng(screenCenter.latitude, screenCenter.longitude);
          }
          fromPrev = screenCenter;
          fromText.text = '$direction #$street, $city, $department';
          fromLatLng = LatLng(screenCenter.latitude, screenCenter.longitude);
        }
      } else {
        if (isToSelected) {
          if (screenCenter.latitude.compareTo(toPrev.latitude) != 0 ||
              screenCenter.longitude.compareTo(toPrev.longitude) != 0) {
            toPrev = screenCenter;
            toText.text = '$direction #$street, $city, $department';
            toLatLng = LatLng(screenCenter.latitude, screenCenter.longitude);
          }
        } else {
          if (screenCenter.latitude.compareTo(searchPrev.latitude) != 0 ||
              screenCenter.longitude.compareTo(searchPrev.longitude) != 0) {
            searchPrev = screenCenter;
            searchText.text = '$direction #$street, $city, $department';
            searchLatLng = LatLng(screenCenter.latitude, screenCenter.longitude);
          }
        }
      }
      if(searchText.text.isEmpty){
        searchPrev = screenCenter;
        searchLatLng = LatLng(screenCenter.latitude, screenCenter.longitude);
      }
    }
    refresh();
  }

  void changeCardBoard(int option) {
    // 0 = From - Click en From
    // 1 = To - Click en To
    // 2 = Search - Click en Lupa / Casa
    
    if (option == 0) {
      if (!isFromSelected) {
        isFromSelected = true;
        isToSelected = false;
        isSearchSelected = false;
      }
    } else {
      if (option == 1) {
        if (!isToSelected) {
          isFromSelected = false;
          isToSelected = true;
          isSearchSelected = false;
        }
      } else {
        if (option == 2) {
          if (!isSearchSelected) {
            animateCameraToPosition(searchLatLng.latitude, searchLatLng.longitude);
            isFromSelected = false;
            isToSelected = false;
            isSearchSelected = true;
          } else {
            animateCameraToPosition(fromLatLng.latitude, fromLatLng.longitude);
            isFromSelected = true;
            isToSelected = false;
            isSearchSelected = false;
          }
        }
      }
    }
    Future.delayed(Duration.zero, refresh());
  }

  GooglePlaceAutoCompleteTextField showGoogleAutoCompleteFrom(
      bool isFrom, double sizeWidth) {
    return GooglePlaceAutoCompleteTextField(
        textEditingController: fromText,
        googleAPIKey: Environment.API_KEY_MAPS,
        debounceTime: 800,
        countries: const ["cl"],
        isLatLngRequired: true,
        onTap: () {
          changeCardBoard(0);
          animateCameraToPosition(fromLatLng.latitude, fromLatLng.longitude);
        },
        inputDecoration: InputDecoration(
          hintText: "Buscar dirección...",
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
          enabledBorder: (() {
            if (isFromSelected) {
              return (const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal, width: 2)));
            }
          }()),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
          contentPadding: const EdgeInsets.all(5),
          constraints: BoxConstraints(maxWidth: sizeWidth),
          isDense: true,
          prefixIconConstraints: const BoxConstraints(minHeight: 35),
          prefixIcon: const Padding(
              padding: EdgeInsetsDirectional.only(start: 5, end: 2),
              child: Icon(Icons.location_pin)),
          prefixIconColor:
              MaterialStateColor.resolveWith((Set<MaterialState> states) {
            if (isFromSelected) {
              return Colors.teal;
            }
            return Colors.grey;
          }),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        getPlaceDetailWithLatLng: (Prediction prediction) {
          fromLatLng = LatLng(
              double.parse(prediction.lat!), double.parse(prediction.lng!));
          animateCameraToPosition(fromLatLng.latitude, fromLatLng.longitude);
          print("placeDetails " + fromLatLng.toString());
        },
        itmClick: (Prediction prediction) {
          fromText.text = prediction.description!;
          fromText.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description!.length));
        }
        // default 600 ms ,
        );
  }

  GooglePlaceAutoCompleteTextField showGoogleAutoCompleteTo(
      bool isFrom, double sizeWidth) {
    return GooglePlaceAutoCompleteTextField(
        textEditingController: toText,
        googleAPIKey: Environment.API_KEY_MAPS,
        onTap: () {
          changeCardBoard(1);
          animateCameraToPosition(toLatLng.latitude, toLatLng.longitude);
        },
        inputDecoration: InputDecoration(
          hintText: "Buscar dirección...",
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7))),
          enabledBorder: (() {
            if (!isFromSelected) {
              return (const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal, width: 2)));
            }
          }()),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
          contentPadding: const EdgeInsets.all(5),
          constraints: BoxConstraints(maxWidth: sizeWidth),
          isDense: true,
          prefixIconConstraints: const BoxConstraints(minHeight: 35),
          prefixIcon: const Padding(
              padding: EdgeInsetsDirectional.only(start: 5, end: 2),
              child: Icon(Icons.location_pin)),
          prefixIconColor:
              MaterialStateColor.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.focused)) {
              return Colors.teal;
            }
            return Colors.grey;
          }),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        debounceTime: 800,
        countries: const ["cl"],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          toLatLng = LatLng(
              double.parse(prediction.lat!), double.parse(prediction.lng!));
          animateCameraToPosition(toLatLng.latitude, toLatLng.longitude);
          print("placeDetails " + toLatLng.toString());
        },
        itmClick: (Prediction prediction) {
          toText.text = prediction.description!;
          toText.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description!.length));
        }
      // default 600 ms ,
      );
  }

  GooglePlaceAutoCompleteTextField showGoogleAutoCompleteSearch(double sizeWidth) {
    return GooglePlaceAutoCompleteTextField(
        textEditingController: searchText,
        googleAPIKey: Environment.API_KEY_MAPS,
        onTap: () {
          changeCardBoard(3);
          animateCameraToPosition(searchLatLng.latitude, searchLatLng.longitude);
        },
        inputDecoration: InputDecoration(
          hintText: "Buscar dirección...",
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7))),
          enabledBorder: (() {
            if (isSearchSelected) {
              return (const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal, width: 2)));
            }
          }()),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
          contentPadding: const EdgeInsets.all(5),
          constraints: BoxConstraints(maxWidth: sizeWidth),
          isDense: true,
          prefixIconConstraints: const BoxConstraints(minHeight: 35),
          prefixIcon: const Padding(
              padding: EdgeInsetsDirectional.only(start: 5, end: 2),
              child: Icon(Icons.location_pin)),
          prefixIconColor:
              MaterialStateColor.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.focused)) {
              return Colors.teal;
            }
            return Colors.grey;
          }),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        debounceTime: 800,
        countries: const ["cl"],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          searchLatLng = LatLng(
              double.parse(prediction.lat!), double.parse(prediction.lng!));
          animateCameraToPosition(
              searchLatLng.latitude, searchLatLng.longitude);
          print("placeDetails " + searchLatLng.toString());
        },
        itmClick: (Prediction prediction) {
          searchText.text = prediction.description!;
          searchText.selection = TextSelection.fromPosition(
            TextPosition(offset: prediction.description!.length));
        }
        // default 600 ms ,
        );
  }

  String getDir(address) {
    String direction = address.thoroughfare!;
    return direction;
  }

  void saveLocation() async {
    await _geoFireProvider.create(_authProvider.getUser()!.uid,
        _position!.latitude, _position!.longitude);
    progressDialog.hide();
  }

  void centerPosition() {
    if (_position != null) {
      animateCameraToPosition(_position!.latitude, _position!.longitude);
    } else {
      Snackbar.showSnackbar(
          context, 'Por favor, activa el GPS para obtener la posición', false);
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
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 0, target: LatLng(latitude, longitude), zoom: 15)));
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

  // De aquí hacia abajo hay funciones relacionadas a compartir
  // la ubicación de un dispositivo en tiempo real, subiendo y eliminando
  // los datos de Firestore, un botón debería ejecutar la función connect()
  // y esto ejecutaría el código que hay hacia abajo.

  // void connect() {
  //   // Esta función se ejecuta cuando se presiona un botón, esto
  //   // habilita o deshabilita el rastreo del dispositivo.
  //   if (isConnect) {
  //     disconnect();
  //   } else {
  //     progressDialog.show();
  //     updateLocation();
  //   }
  // }

  void disconnect() {
    // Esta función deja de actualizar la posición y elimina la posición de la db
    // _positionStream.cancel();
    _geoFireProvider.delete(_authProvider.getUser()!.uid);
  }
  

  // Utilizado en driver - check connect
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

}
