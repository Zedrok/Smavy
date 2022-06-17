import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  LatLngBounds? bounds;
  final List<PointLatLng> polylinePoints;
  final String encodedPolyline;
  final String totalDistance;
  final String totalDuration;
  List<dynamic>? waypointsOrder = [];
  List<dynamic> legs = [];

  Directions({
    required this.encodedPolyline,
    this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
    this.waypointsOrder,
    required this.legs
  });

  factory Directions.fromMap(Map<String, dynamic> map){
    final data = Map<String, dynamic>.from(map['routes'][0]);

    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      southwest: LatLng(southwest['lat'], southwest['lng']),
      northeast: LatLng(northeast['lat'], northeast['lng']),
    );

    String distance = '';
    String duration = '';
    if((data['legs'] as List).isNotEmpty){
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }

    return Directions(
      waypointsOrder: data['waypoint_order'],
      legs: data['legs'],
      bounds: bounds,
      encodedPolyline: data['overview_polyline']['points'],
      polylinePoints: PolylinePoints().decodePolyline(data['overview_polyline']['points']),
      totalDistance: distance,
      totalDuration: duration
    );
  }
}