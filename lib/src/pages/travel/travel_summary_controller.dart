import 'package:flutter/material.dart';
import 'package:smavy/src/models/travel_history.dart';
import 'package:smavy/src/providers/travel_history_provider.dart';

class TravelSummaryController {
  late BuildContext context;
  late String idTravelHistory;
  late Function refresh;

  late TravelHistoryProvider _travelHistoryProvider;
  late TravelHistory travelHistory;

  Future init(BuildContext context, refresh) async {
    this.context = context;
    this.refresh = refresh;
    idTravelHistory = ModalRoute.of(context)!.settings.arguments as String;
    _travelHistoryProvider = TravelHistoryProvider();
    getTravelHistory();
  }

  void getTravelHistory() async {
    travelHistory = (await _travelHistoryProvider.getById(idTravelHistory))!;
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
}