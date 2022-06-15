// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smavy/src/models/directions_model.dart';
import 'package:smavy/src/pages/api/environment.dart';

class DirectionsRepository {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json?';
  
  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();
  
  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
    List<Map<String, dynamic>>? waypoints
  }) async {
    if (waypoints != null && waypoints.isNotEmpty) {

      String paramsWaypoints = 'optimize:true';

      for (var waypoint in waypoints) {
        paramsWaypoints = paramsWaypoints+'|${waypoint['lat']},${waypoint['lng']}';
      }

      print('waypoint != null');
      print(_baseUrl+'origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&waypoints=$paramsWaypoints&key=${Environment.API_KEY_MAPS}');

      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'waypoints': paramsWaypoints,
          'key': Environment.API_KEY_MAPS
        }
      );
      if(response.statusCode == 200){
        return Directions.fromMap(response.data);
      }
    }else{
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': Environment.API_KEY_MAPS
        }
      );
      
      print('waypoint null');
      print(response.requestOptions.queryParameters);

      if(response.statusCode == 200){
        return Directions.fromMap(response.data);
      }
    }

    return null;
  }

}