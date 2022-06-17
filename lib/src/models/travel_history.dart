// To parse this JSON data, do
//
//     final travelHistory = travelHistoryFromJson(jsonString);

import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

TravelHistory travelHistoryFromJson(String str) => TravelHistory.fromJson(json.decode(str));

String travelHistoryToJson(TravelHistory data) => json.encode(data.toJson());

class TravelHistory {
  TravelHistory({
      this.id,
      required this.idUsuario,
      required this.fromText,
      required this.fromLatLng,
      required this.toText,
      required this.toLatLng,
      required this.totalDuration,
      required this.totalDistance,
      required this.overviewPolyline,
      required this.legs,
      required this.timestamp
  });

  String? id;
  String idUsuario;
  String fromText;
  LatLng fromLatLng;
  String toText;
  LatLng toLatLng;
  Duration totalDuration;
  int totalDistance;
  String overviewPolyline;
  List<RouteLeg> legs;
  int timestamp;

  factory TravelHistory.fromJson(Map<String, dynamic> json) => TravelHistory(
    id: json["id"],
    idUsuario: json["id_usuario"],
    fromText: json["fromText"],
    fromLatLng: LatLng(json["fromLat"].toDouble(), json["fromLng"].toDouble()),
    toText: json["toText"],
    toLatLng: LatLng(json["toLat"].toDouble(), json["toLng"].toDouble()),
    totalDuration: Duration(milliseconds: (json["totalDuration"] as int) ),
    totalDistance: json["totalDistance"],
    overviewPolyline: json["overviewPolyline"],
    timestamp: (json['timestamp'] as int),
    legs: []
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_usuario": idUsuario,
    "fromText": fromText,
    "fromLat": fromLatLng.latitude,
    "fromLng": fromLatLng.latitude,
    "toText": toText,
    "toLat": toLatLng.latitude,
    "toLng": toLatLng.longitude,
    "totalDuration": totalDuration.inMilliseconds,
    "totalDistance": totalDistance,
    "overviewPolyline": overviewPolyline,
    "timestamp": timestamp
  };
}

class RouteLeg {
    RouteLeg({
      required this.startAddress,
      required this.startLocation,
      required this.endAddress,
      required this.endLocation,
      required this.distance,
      required this.duration,
      required this.polyline,
      required this.encodedPolyline
    });

    String startAddress;
    LatLng startLocation;
    String endAddress;
    LatLng endLocation;
    int distance;
    Duration duration;
    List<PointLatLng> polyline;
    String encodedPolyline;

    factory RouteLeg.fromJson(Map<String, dynamic> json) => RouteLeg(
      startAddress: json["start_address"],
      startLocation: LatLng(json["start_location_lat"].toDouble(), json["start_location_lng"].toDouble()),
      endAddress: json["end_address"],
      endLocation: LatLng(json["end_location_lat"].toDouble(), json["end_location_lng"].toDouble()),
      distance: json["distance"],
      duration: Duration(milliseconds: (json["duration"] as int)),
      polyline: PolylinePoints().decodePolyline(json["polyline"]),
      encodedPolyline: json["polyline"]
    );

    Map<String, dynamic> toJson() => {
      "start_address": startAddress,
      "start_location_lat": startLocation.latitude,
      "start_location_lng": startLocation.longitude,
      "end_address": endAddress,
      "end_location_lat": endLocation.latitude,
      "end_location_lng": endLocation.longitude,
      "distance": distance,
      "duration": duration.inMilliseconds,
      "polyline": encodedPolyline,
    };
}
