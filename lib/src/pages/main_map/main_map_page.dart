// ignore_for_file: avoid_print, unnecessary_string_escapes
import 'package:smavy/src/utils/ajustesPage.dart';
import 'package:smavy/src/utils/historial.dart';
import 'package:smavy/src/utils/perfil.dart';
import 'package:smavy/src/utils/save_adresses.dart';
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

    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

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
        key: _globalKey,
        drawer: _drawer(
            context), //drawer guardado en funcion para simplificar codigo
        body: Stack(children: [
          _googleMapsWidget(),
          _buttonMenu(),
          SafeArea(
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: _cardGooglePlaces(),
                  ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: _buttonSwitchToSearch()),
              ]),
              Expanded(child: Container()),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: _buttonCenterPosition()),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: _buttonSavedLocations()),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: _buttonAddLocation()),
              ]),
              _buttonStartRoute()
            ]),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                child: _iconMyLocation()),
          )
        ]),
      ),
    );
  }

  Widget _buttonMenu() {
    return IconButton(
      icon: const Icon(Icons.menu),
      padding: const EdgeInsets.all(10),
      color: Colors.teal,
      onPressed: () {
        _globalKey.currentState?.openDrawer();
      },
    );
  }

  Widget _buttonStartRoute() {
    return Container(
        height: 50,
        alignment: Alignment.bottomCenter,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: ButtonApp(
          onPressed: () {},
          text: 'X lugares seleccionados',
          color: Colors.teal,
          textColor: Colors.white,
        ));
  }

  Widget _buttonCenterPosition() {
    return Container(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: _con.centerPosition,
          child: Card(
            elevation: 3,
            color: Colors.teal[400],
            shape: const CircleBorder(),
            child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.my_location,
                    color: Colors.white, size: 25)),
          ),
        ));
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
              child: const Icon(Icons.search_outlined,
                  color: Colors.white, size: 25)),
        ));
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
                  color: Colors.white, size: 25)),
        ));
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
              child: const Icon(Icons.add, color: Colors.white, size: 35)),
        ));
  }

  Widget _cardGooglePlaces() {
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
                  children: [
                    const Text('Origen',
                        style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text(
                      _con.from,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
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
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                      maxLines: 2,
                    ),
                    const Text(
                      'Seleccionar destino',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                      maxLines: 2,
                    ),
                  ]))),
    );
  }

  Widget _iconMyLocation() {
    return Image.asset(
      'assets/img/location_smavy.png',
      width: 65,
      height: 65,
    );
  }

//funcion para el body
  // Widget _bodyPart() => Stack(children: [
  //       _googleMapsWidget(),
  //       SafeArea(
  //           child: Column(
  //         children: [
  //           Container(
  //             margin: const EdgeInsets.all(10),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 _buttonCenterPosition(),
  //               ],
  //             ),
  //           )
  //         ],
  //       ))
  //     ]);

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

//funcion de drawer lateral izquierdo.
  Drawer _drawer(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
            decoration: const BoxDecoration(color: Colors.teal),
            child: _drawerHeader()),
        _menusDrawer(context, 'Perfil', 'perfil'),
        const Divider(
          thickness: 1,
          height: 10,
          color: Colors.grey,
        ),
        _menusDrawer(context, 'Historial', 'historial'),
        const Divider(
          thickness: 1,
          height: 10,
          color: Colors.grey,
        ),
        _menusDrawer(context, 'Direcciones Guardadas', 'dir_guardadas'),
        const Divider(
          thickness: 1,
          height: 10,
          color: Colors.grey,
        ),
        _menusDrawer(context, 'Ajustes', 'ajustes_page'),
      ],
    ));
  }

  Widget _drawerHeader() {
    return Row(
      children: [
        const CircleAvatar(
            radius: 40, backgroundImage: AssetImage('assets\img\profile.png')),
        const SizedBox(
          width: 20,
        ),
        const SizedBox(
          height: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text('usuario',
                style: TextStyle(fontSize: 14, color: Colors.white)),
            SizedBox(
              width: 10,
            ),
            Text(
              'coreeo@mail.com',
              style: TextStyle(fontSize: 14, color: Colors.white),
            )
          ],
        )
      ],
    );
  }

//funcion destinada para cada menu del drawer
  ListTile _menusDrawer(
      BuildContext context, String mensaje, String routeName) {
    return ListTile(
      title: Text(
        mensaje,
        style: const TextStyle(color: Colors.black),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, routeName);
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
