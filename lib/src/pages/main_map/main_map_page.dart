// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smavy/src/pages/main_map/main_map_controller.dart';
import 'dart:io';

import 'package:smavy/src/widgets/button_app.dart';

class MainMapPage extends StatefulWidget {
  const MainMapPage({Key? key}) : super(key: key);

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
    // _con.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _onWillPopScope(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'prueba',
            style: TextStyle(color: Colors.white),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal,
                ),
                child: Text(
                  'Drawer Header',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              _menusDrawer(context, 'Perfil'),
              _menusDrawer(context, 'Historial'),
              _menusDrawer(context, 'Direcciones Guardadas'),
              _menusDrawer(context, 'Ajustes'),
            ],
          ),
        ),
        body: Stack(children: [
          _googleMapsWidget(),
          SafeArea(
            child: Column(
              children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: _cardGooglePlaces(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: _buttonSwitchToSearch()
                      ),
                    ]
                  ),
                  Expanded(child: Container()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: _buttonCenterPosition()
                      ),
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: _buttonSavedLocations()
                      ),
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: _buttonAddLocation()
                      ),
                    ]
                  ),
                  _buttonStartRoute()
                ]
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                child: _iconMyLocation()
              ),
            )
        ]),
      ),
    );
  }

  Widget _buttonStartRoute(){
    return Container(
      height: 50,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: ButtonApp(
        onPressed: (){},
        text: 'X lugares seleccionados',
        color: Colors.teal,
        textColor: Colors.white
      )
    );
  }

  Widget _buttonCenterPosition() {
    return Container(
      alignment: Alignment.centerRight,
      child: Card(
        elevation: 3,
        color: Colors.teal[400],
        shape: const CircleBorder(),
        child: Container(
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.my_location,
            color: Colors.white, size: 25)),
      )
    );
  }

  Widget _buttonSwitchToSearch() {
    return Container(
      alignment: Alignment.centerRight,
      child: Card(
        elevation: 3,
        color: Colors.teal[400],
        shape: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: const Icon(Icons.location_searching_outlined,
          color: Colors.white, size: 25)),
      )
    );
  }

  Widget _buttonSavedLocations() {
    return Container(
      alignment: Alignment.centerRight,
      child: Card(
        elevation: 3,
        color: Colors.teal[400],
        shape: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: const Icon(Icons.where_to_vote,
          color: Colors.white, size: 25)
        ),
      )
    );
  }

  Widget _buttonAddLocation() {
    return Container(
      alignment: Alignment.centerRight,
      child: Card(
        elevation: 3,
        color: Colors.teal[400],
        shape: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(5),
          child: const Icon(Icons.add,
          color: Colors.white, size: 35)
        ),
      )
    );
  }

  Widget _cardGooglePlaces(){
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          ),        
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                const Text(
                  'Origen',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10
                  )
                ),
                Text(
                  _con.from,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  ),
                  maxLines: 2,
                ),
                const SizedBox(width: 5),
                const SizedBox(
                  width: double.infinity,
                  child: Divider(color: Colors.black87, height: 10),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Destino',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10
                  ),
                  maxLines: 2,
                ),
                const Text(
                  'Seleccionar destino',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  ),
                  maxLines: 2,
                ),
              ]
            )
        )
      ),
    );
  }

  Widget _iconMyLocation(){
    return Image.asset(
      'assets/img/location_smavy.png',
      width: 65,
      height: 65,
    );
  }

  Widget _googleMapsWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
      onCameraMove: (position) {
        _con.initialPosition = position;
        print('ON CAMERA MOVE: $position');
      },
      onCameraIdle: () async {
        await _con.setLocationDraggableInfo();
      },
    );
  }

  ListTile _menusDrawer(BuildContext context, String mensaje) {
    return ListTile(
      title: Text(
        mensaje,
        style: const TextStyle(color: Colors.black),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  Future<bool> _onWillPopScope() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('¿Desea salir de la aplicación?'),
        actions: [
          FloatingActionButton(
              onPressed: () => exit(0), child: const Text('Si')),
          FloatingActionButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No')),
        ],
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
