import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:smavy/src/models/direccion_guardada.dart';
import 'package:smavy/src/models/ruta_guardada.dart';
import 'package:smavy/src/models/travel_history.dart';
import 'package:intl/intl.dart';
import 'package:smavy/src/providers/direccion_guardada_provider.dart';
import 'package:smavy/src/providers/ruta_guardada_provider.dart';
import 'package:smavy/src/utils/my_progress_dialog.dart';
import 'package:smavy/src/utils/snackbar.dart';

class AdvancedDetailsController {
  late BuildContext context;
  late String idTravelHistory;
  late Function refresh;

  late TravelHistory travelHistory;
  
  late String fromText = "";
  late String toText = "";
  late LatLng fromLatLng;
  late LatLng toLatLng;
  late List<Map<String, dynamic>> listaDirecciones = [];
  bool rutaRepetida = false;
  bool datosCargados = false;
  TextEditingController aliasText = TextEditingController();
  late RutaGuardadaProvider rutaGuardadaProvider;
  late ProgressDialog progressDialog;
  late DireccionGuardadaProvider direccionGuardadaProvider;
  late bool boolSaved = false;
  

  Future init(BuildContext context, refresh) async {
    this.context = context;
    this.refresh = refresh;
    progressDialog = MyProgressDialog.createProgressDialog(context, 'Guardando...');

    Map<String, dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map <String, dynamic>;

    fromText = arguments['fromText'];
    toText = arguments['toText'];
    fromLatLng = arguments['fromLatLng'];
    toLatLng = arguments['toLatLng'];
    rutaRepetida = arguments['rutaRepetida'];
    travelHistory = arguments['travelHistory'];
    boolSaved = arguments['boolSaved'];
    idTravelHistory = arguments['idTravelHistory'];

    rutaGuardadaProvider = RutaGuardadaProvider();
    direccionGuardadaProvider = DireccionGuardadaProvider();

    getWaypointsFromRoute();

    datosCargados = true;
    refresh();
  }

  String transformarDistancia(int totalDistance) {
    if(totalDistance >= 1000){
      double distance = totalDistance/100;
      distance = distance.truncate().toDouble();
      distance /= 10;
      return '${distance.toString()} km';
    }else{
      return '${totalDistance.toString()} m';
    }
  }

  String readTimestamp(int timestamp) {
    var format = DateFormat('dd/MM/yyyy');
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
    var time = '';
    time = format.format(date);
    return time;
  }

  void getWaypointsFromRoute(){
    int i=0;
    while(i<(travelHistory.legs.length-1)){
      listaDirecciones.add({
        'id': i+1,
        'direccion': travelHistory.legs[i].endAddress,
        'lat': travelHistory.legs[i].endLocation.latitude,
        'lng': travelHistory.legs[i].endLocation.longitude
      });
      i++;
    }
  }

  void guardarRuta(){
    RutaGuardada rutaGuardada = RutaGuardada(
      idUsuario: travelHistory.idUsuario,
      idRuta: travelHistory.id!,
      alias: aliasText.text
    );

    rutaGuardadaProvider.create(rutaGuardada);
    Navigator.pushNamed(context, 'rutas_guardadas');
    Snackbar.showSnackbar(context, 'Ruta agregada con éxito!', true);
  }

  void eliminarRuta(){
    rutaGuardadaProvider.delete(idTravelHistory);
    Navigator.pushNamed(context, 'rutas_guardadas');
    Snackbar.showSnackbar(context, 'Ruta eliminada con exito!', true);
  }

  void guardarDireccion(Map<String, dynamic> direccion) {
    var direccionGuardada = DireccionGuardada(
      idUsuario: travelHistory.idUsuario,
      alias: aliasText.text, 
      direccion: direccion['direccion'], 
      lat: direccion['lat'].toDouble(), 
      lng: direccion['lng'].toDouble()
    );

    direccionGuardadaProvider.create(direccionGuardada);
    Navigator.pop(context);
    Snackbar.showSnackbar(context, 'Direccion agregada con éxito!', true);
  }

  void guardarFrom() {
    var direccionGuardada = DireccionGuardada(
      idUsuario: travelHistory.idUsuario,
      alias: aliasText.text, 
      direccion: fromText, 
      lat: fromLatLng.latitude, 
      lng: fromLatLng.longitude
    );

    direccionGuardadaProvider.create(direccionGuardada);
    Navigator.pop(context);
    Snackbar.showSnackbar(context, 'Direccion agregada con éxito!', true);
  }

  void guardarTo() {
    var direccionGuardada = DireccionGuardada(
      idUsuario: travelHistory.idUsuario,
      alias: aliasText.text, 
      direccion: toText, 
      lat: toLatLng.latitude, 
      lng: toLatLng.longitude
    );

    direccionGuardadaProvider.create(direccionGuardada);
    Navigator.pop(context);
    Snackbar.showSnackbar(context, 'Direccion agregada con éxito!', true);
  }

  void goToTravelMap() {

    Navigator.pushNamed(context, 'travelMap', arguments:{
      'fromText': travelHistory.fromText,
      'toText': travelHistory.toText,
      'fromLatLng': travelHistory.fromLatLng,
      'toLatLng': travelHistory.toLatLng,
      'listaDirecciones': listaDirecciones,
      'routeLegs': travelHistory.legs,
      'rutaRepetida': true,
      'encodedPolyline': travelHistory.overviewPolyline
    });
  }

}