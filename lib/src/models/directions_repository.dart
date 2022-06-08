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
    LatLng? waypoint
  }) async {
    if (waypoint != null) {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'waypoints': 'optimize:true|${waypoint!.latitude}, ${waypoint.longitude}',
          'key': Environment.API_KEY_MAPS
        }
      );
      print('waypoint != null');
      print(response.requestOptions.queryParameters);
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