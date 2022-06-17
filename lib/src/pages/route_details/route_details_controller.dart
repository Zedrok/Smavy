import 'package:flutter/material.dart';
import 'package:smavy/src/models/travel_history.dart';
import 'package:smavy/src/providers/travel_history_provider.dart';
import 'package:intl/intl.dart';

class RouteDetailsController {
  late BuildContext context;
  late String idTravelHistory;
  late Function refresh;

  late TravelHistoryProvider _travelHistoryProvider;
  late TravelHistory travelHistory;
  bool datosCargados = false;

  Future init(BuildContext context, refresh) async {
    this.context = context;
    this.refresh = refresh;

    idTravelHistory = ModalRoute.of(context)!.settings.arguments as String;
    
    _travelHistoryProvider = TravelHistoryProvider();
    getTravelHistory();
  }

  void getTravelHistory() async {
    travelHistory = (await _travelHistoryProvider.getById(idTravelHistory))!;
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

  List<Map<String, dynamic>> getWaypointsFromRoute(){
    List<Map<String, dynamic>> listaDirecciones = [];
    
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
    return listaDirecciones;
  }

  void goToTravelMap() {
    List<Map<String, dynamic>> listaDirecciones = getWaypointsFromRoute();

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