import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smavy/src/pages/main_map/main_map_controller.dart';

class MainMapPage extends StatefulWidget {
  const MainMapPage({ Key? key }) : super(key: key);

  @override
  State<MainMapPage> createState() => _MainMapPageState();
}

class _MainMapPageState extends State<MainMapPage> {

  final MainMapController _con = MainMapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _googleMapsWidget(),
    );
  }

  Widget _googleMapsWidget(){
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
    );
  }
}