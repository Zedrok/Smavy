// ignore_for_file: avoid_print, unnecessary_string_escapes, unnecessary_string_interpolations

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smavy/src/pages/main_map/main_map_controller.dart';
import 'package:smavy/src/providers/auth_provider.dart';
import 'dart:io';

import 'package:smavy/src/widgets/button_app.dart';

class MainMapPage extends StatefulWidget {
  const MainMapPage({Key? key}) : super(key: key);

  @override
  State<MainMapPage> createState() => _MainMapPageState();
}

class _MainMapPageState extends State<MainMapPage> {
  final MainMapController _con = MainMapController();
  final ScrollController scrollController = ScrollController();
  final double heightAddLocationB = 160.0;
  bool isTrazarB = true;
  User? user = AuthProvider().getUser();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
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
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          key: _globalKey,
          drawer: _drawer(
              context), //drawer guardado en funcion para simplificar codigo
          body: Stack(
            children: [
              _googleMapsWidget(),
              SafeArea(
                child: Column(children: [
                  // CardBoard de ubicaciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: (() {
                          if (!(_con.isSearchSelected)) {
                            return _cardGooglePlacesFromTo();
                          } else {
                            return _cardGooglePlacesSearch();
                          }
                        }()),
                      ),
                    ],
                  ),

                  // Botón de Búsqueda y Cambio origen/destino
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: _buttonSwitchToSearch(),
                      ),
                    ],
                  ),

                  Expanded(child: Container()),

                  // Boton Centrar mapa
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: _buttonCenterPosition(),
                      ),
                    ],
                  ),

                  // Boton direcciones guardadas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: _buttonSavedLocations(),
                      ),
                    ],
                  ),

                  // Boton Agregar dirección
                  () {
                    if (_con.isSearchSelected) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(bottom: 60),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: _buttonAddLocation(),
                            ),
                          ]);
                    } else {
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 60),
                          )
                        ],
                      );
                    }
                  }(),
                ]),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                  child: _iconMyLocation(),
                ),
              ),
              _notificationButtonTrazar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fromTextField() {
    return Container(
        padding: const EdgeInsets.symmetric(),
        child: _con.showGoogleAutoCompleteFrom(
            _con.isFromSelected, MediaQuery.of(context).size.width * 0.75));
  }

  Widget _toTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(),
      child: _con.showGoogleAutoCompleteTo(
          _con.isFromSelected, MediaQuery.of(context).size.width * 0.75),
    );
  }

  Widget _searchTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(),
      child: _con.showGoogleAutoCompleteSearch(
          MediaQuery.of(context).size.width * 0.75),
    );
  }

  Widget _cardGooglePlacesFromTo() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
      child: Card(
        shadowColor: Colors.teal,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.teal, width: 0.2),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buttonMenu(),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Origen',
                      style: TextStyle(color: Colors.grey[750], fontSize: 13),
                    ),
                    _fromTextField(),
                    const SizedBox(height: 3),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: const Divider(
                        color: Colors.teal,
                        thickness: 1,
                        height: 10,
                      ),
                    ),
                    Text(
                      'Destino',
                      style: TextStyle(color: Colors.grey[750], fontSize: 13),
                      maxLines: 2,
                    ),
                    _toTextField(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardGooglePlacesSearch() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
      child: Card(
        shadowColor: Colors.teal,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.teal, width: 0.2),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buttonMenu(),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dirección por visitar',
                      style: TextStyle(color: Colors.grey[750], fontSize: 13),
                    ),
                    _searchTextField(),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      child: GestureDetector(
        onTap: () {
          _con.changeCardBoard(2);
        },
        child: Card(
          elevation: 3,
          color: Colors.teal[400],
          shape: const CircleBorder(),
          child: Container(
              padding: const EdgeInsets.all(10),
              child: Icon(
                  (() {
                    if (!(_con.isSearchSelected)) {
                      return Icons.search_outlined;
                    } else {
                      return Icons.house;
                    }
                  }()),
                  color: Colors.white,
                  size: 25)),
        ),
      ),
    );
  }

  Widget _buttonSavedLocations() {
    return Container(
        alignment: Alignment.centerRight,
        child: Card(
          elevation: 0,
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
            child: Positioned(
              right: 20,
              bottom: heightAddLocationB,
              child: IconButton(
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 35,
                ),
                onPressed: () {
                  _con.agregarDireccion();
                  refresh();
                },
              ),
            )));
  }

  Widget _iconMyLocation() {
    return Image.asset(
      'assets/img/location_smavy.png',
      width: 65,
      height: 65,
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
        _menusDrawerinicio(context, 'Inicio'),
        const Divider(
          thickness: 1,
          height: 10,
          color: Colors.grey,
        ),
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
        const SizedBox(
          height: 180,
        ),
        Container(
          padding: const EdgeInsets.only(
            right: 70,
          ),
          alignment: Alignment.bottomLeft,
          height: 50,
          child: ButtonApp(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, 'login');
            },
            color: Colors.red.shade600,
            colorIcon: const Color.fromARGB(255, 197, 27, 15),
            text: 'Cerrar Sesion',
            icon: Icons.logout_outlined,
          ),
        ),
      ],
    ));
  }

  Widget _menusDrawerinicio(BuildContext context, String title) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _drawerHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.white),
            boxShadow: [
              BoxShadow(
                spreadRadius: 2,
                blurRadius: 10,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('${user?.providerData[0].photoURL}'),
            ),
          ),
        ),
        Text(
          '${user!.displayName}',
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          '${user?.providerData[0].email}',
          style: const TextStyle(color: Colors.white),
        ),
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

  Widget panelUp() {
    return DraggableScrollableSheet(
        maxChildSize: 0.9,
        minChildSize: 0.07,
        initialChildSize: 0.07,
        builder: (context, scrollController) {
          return Material(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                controller: scrollController,
                children: [
                  Container(child: _buttonTrazar()),
                  const SizedBox(height: 10),
                  const Divider(
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                    color: Colors.grey,
                    height: 5.0,
                  ),
                  _itemFrom(),
                  const Divider(
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                    color: Colors.grey,
                    height: 5.0,
                  ),
                  ..._crearItem(),
                  _itemTo(),
                  const Divider(
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                    color: Colors.grey,
                    height: 5.0,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _buttonIniciarViaje(),
                  // ignore: avoid_unnecessary_containers
                ],
              ));
        });
  }

  Widget _buttonTrazar() {
    return Container(
        alignment: Alignment.topCenter,
        child: ButtonApp(
          onPressed: () {},
          color: Colors.teal,
          text: '${_con.listaDirecciones.length} Lugares seleccionados',
          icon: _iconButtonTrazar(),
        ));
  }

  IconData iconOrigenDestino() {
    IconData icon = Icons.place;
    // ignore: prefer_is_empty
    if (_con.listaDirecciones.length == 0) {
      icon = Icons.home;
    } else if (_con.listaDirecciones.length == 1) {
      icon = Icons.flag;
    }
    return icon;
  }

  IconData _iconButtonTrazar() {
    IconData icon = Icons.adb_rounded;
    if (isTrazarB == true) {
      icon = Icons.keyboard_arrow_up;
    } else if (isTrazarB == false) {
      icon = Icons.keyboard_arrow_down;
    }
    return icon;
  }

  Widget _buttonIniciarViaje() {
    return Container(
        alignment: Alignment.bottomCenter,
        child: ButtonApp(
          onPressed: () {
            _con.goToTravelInfoPage();
          },
          color: Colors.teal,
          text: 'INICIAR VIAJE',
          icon: Icons.arrow_forward_ios,
        ));
  }

  Widget _notificationButtonTrazar() {
    return NotificationListener<UserScrollNotification>(
      onNotification: (notificacion) {
        if (notificacion.direction == ScrollDirection.forward) {
          setState(() {
            isTrazarB = true;
            refresh();
          });
        } else if (notificacion.direction == ScrollDirection.reverse) {
          setState(() {
            isTrazarB = false;
            refresh();
          });
        }
        return true;
      },
      child: panelUp(),
    );
  }

  Widget _itemFrom() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      title: Text("${_con.fromText.text}"),
      leading: const Icon(Icons.home, color: Colors.teal, size: 30),
    );
  }

  Widget _itemTo() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      title: Text(
        '${_con.toText.text}',
      ),
      leading: const Icon(
        Icons.my_location_outlined,
        color: Colors.teal,
        size: 30,
      ),
    );
  }

  List<Widget> _crearItem() {
    List<Widget> temporal = [];

    for (Map<String, dynamic> direccion in _con.listaDirecciones) {
      Widget item = ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        title: Text("${direccion['direccion']}"),
        leading: SizedBox(
          width: 30,
          child: Text(
            '${direccion['id']}',
            style: const TextStyle(
              color: Colors.teal,
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        trailing: SizedBox(
          width: 50,
          child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _con.deleteDireccion(direccion);
                });
              }),
        ),
      );
      temporal.add(item);
      temporal.add(const Divider(
        indent: 10,
        endIndent: 10,
        color: Colors.grey,
        height: 5.0,
        thickness: 1,
      ));
    }

    return temporal;
  }

  Widget _googleMapsWidget() {
    return GoogleMap(
      trafficEnabled: true,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
      onCameraMove: (position) {
        FocusManager.instance.primaryFocus?.unfocus();
        _con.initialPosition = position;
        _con.screenCenter = position.target;
      },
      onCameraIdle: () async {
        if (_con.isFromSelected) await _con.setFromMarker();
        if (_con.isToSelected) await _con.setToMarker();

        await _con.setLocationDraggableInfo();
      },
      onTap: (argument) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  void refresh() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    setState(() {});
  }
}
