// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smavy/src/pages/main_map/main_map_controller.dart';
import 'dart:io';

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

    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
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
    return WillPopScope(
      onWillPop: () async => _onWillPopScope(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'prueba',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: _bodyPart(), //body guardado en funcion manteniendo stack
        drawer: _drawer(
            context), //drawer guardado en funcion para simplificar codigo
      ),
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
              child: const Icon(Icons.location_searching_outlined,
                  color: Colors.white, size: 25)),
        ));
  }

//funcion para el body
  Widget _bodyPart() => Stack(children: [
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
        ))
      ]);

  Widget _googleMapsWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
    );
  }

//funcion de drawer lateral izquierdo.
  Drawer _drawer(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 77, 236, 213),
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
    ));
  }

//funcion destinada para cada menu del drawer
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
