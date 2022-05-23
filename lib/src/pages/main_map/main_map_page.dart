// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  void initState() {
    super.initState();
    
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  void dispose() {
    // ignore: todo
    // TODO: implement dispose
    super.dispose();
    print('Se ejecutó el dispose');
    _con.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children:[
          _googleMapsWidget(),
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buttonCenterPosition(),
                    ],
                  ),
                )
              ],
            )
          )
        ]
      ),
    );
  }

  Widget _buttonCenterPosition(){
    return Container(
      alignment: Alignment.centerRight,
      child: Card(
        elevation: 3,
        color: Colors.teal[400],
        shape: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: const Icon(
            Icons.location_searching_outlined,
            color: Colors.white,
            size: 25
          )
        ),
      )  
    );
  }

  Widget _googleMapsWidget(){
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
    );
  }

  void refresh (){
    setState((){

    });
  }
}
