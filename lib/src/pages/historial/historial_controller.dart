import 'package:flutter/material.dart';
import 'package:smavy/src/models/travel_history.dart';
import 'package:smavy/src/providers/travel_history_provider.dart';
import 'package:intl/intl.dart';

class HistorialController {
  late BuildContext context;
  late String idTravelHistory;
  late Function refresh;

  late TravelHistoryProvider _travelHistoryProvider;
  late List<TravelHistory> travelHistoryList = [];
  bool datosCargados = false;

  Future init(BuildContext context, refresh) async {
    this.context = context;
    this.refresh = refresh;
    _travelHistoryProvider = TravelHistoryProvider();
    getTravelHistoryList();
  }

  void getTravelHistoryList() async {
    travelHistoryList = (await _travelHistoryProvider.getUserTravels())!;
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

  void goToSummaryPage(String id) {
     Navigator.pushNamed(
      context, 'routeDetails', arguments:{
        'id': id,
        'boolSaved': false
    });
  }

}