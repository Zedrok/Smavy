// ignore_for_file: avoid_print, unnecessary_string_escapes

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smavy/src/pages/main_map/main_map_controller.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smavy/src/utils/panel_widget.dart';
import 'dart:io';

import '../../utils/ubicaciones.dart';

class MainMapPage extends StatefulWidget {
  const MainMapPage({Key? key}) : super(key: key);

  @override
  State<MainMapPage> createState() => _MainMapPageState();
}

class _MainMapPageState extends State<MainMapPage> {
  final MainMapController _con = MainMapController();
  final panelController = PanelController();
  late PanelWidget panelw;
  bool isVisible = true;

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
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.7;
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.1;

    return WillPopScope(
      onWillPop: () async => _onWillPopScope(),
      child: Scaffold(
        key: _globalKey,
        drawer: _drawer(
            context), //drawer guardado en funcion para simplificar codigo
        body: Stack(children: [
          _slidingupPanel(panelController, panelHeightOpen, panelHeightClosed),
          _buttonMenu(),
          SafeArea(
            child: Column(children: [
              // CardBoard de ubicaciones
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: _cardGooglePlaces(),
                  ),
                ],
              ),

              // Botón de Búsqueda y Cambio origen/destino
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: _buttonSwitchToSearch()),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: _buttonChangeTo()),
              ]),

              Expanded(child: Container()),

              // Boton Centrar mapa
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: _buttonCenterPosition()),
              ]),

              // Boton direcciones guardadas
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: _buttonSavedLocations()),
              ]),

              // Boton Agregar dirección
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: _buttonAddLocation()),
              ]),
            ]),
          ),
          Visibility(
            visible: isVisible,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                  child: _iconMyLocation()),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buttonMenu() {
    return Positioned(
      top: 10,
      left: -10,
      child: IconButton(
        onPressed: () {
          _globalKey.currentState?.openDrawer();
        },
        icon: const Icon(
          Icons.menu,
          color: Colors.teal,
        ),
      ),
    );
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

  Widget _buttonChangeTo() {
    return GestureDetector(
      onTap: _changeto,
      child: Container(
          alignment: Alignment.centerRight,
          child: Card(
            elevation: 3,
            color: Colors.teal[400],
            shape: const CircleBorder(),
            child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.restart_alt,
                    color: Colors.white, size: 25)),
          )),
    );
  }

  void _changeto() {
    Ubicaciones direccion = Ubicaciones(_con.fromLatLng, _con.from);
    panelw.agregarItem(direccion);
    print(direccion);
    _con.changeFromTo();
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
    return GestureDetector(
      onTap: _agregarItemLista,
      child: Container(
          alignment: Alignment.centerRight,
          child: Card(
            elevation: 3,
            color: Colors.teal[400],
            shape: const CircleBorder(),
            child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.add, color: Colors.white, size: 25)),
          )),
    );
  }

  void _agregarItemLista() => () {
        Ubicaciones direccion = Ubicaciones(_con.toLatLng, _con.to);
        print(direccion);
        panelw.agregarItem(direccion);
      };

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
                    Text(
                      _con.to,
                      style: const TextStyle(
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
        _con.screenCenter = position.target;
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

  Widget _slidingupPanel(PanelController panelController, panelHeightOpen,
          panelHeightClosed) =>
      SlidingUpPanel(
        controller: panelController,
        maxHeight: panelHeightOpen,
        minHeight: panelHeightClosed,
        body: _googleMapsWidget(),
        panelBuilder: (controller) => panelw = PanelWidget(
            controller: controller, panelController: panelController),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        onPanelOpened: () => setState(() {
          isVisible = !isVisible;
        }),
        onPanelClosed: () => setState(() {
          isVisible = !isVisible;
        }),
      );

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

  //void _togglePanel() => _pc.isPanelOpen ? _pc.close() : _pc.open();
  //void _togglePanel2() => _pc.isAttached ? _pc.open() : _pc.close();
}
