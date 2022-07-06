// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smavy/src/pages/route_details/advanced_details_controller.dart';
import 'package:smavy/src/widgets/button_app.dart';

class AdvancedDetailsPage extends StatefulWidget {
  const AdvancedDetailsPage({Key? key}) : super(key: key);

  @override
  State<AdvancedDetailsPage> createState() => _AdvancedDetailsPageState();
}

class _AdvancedDetailsPageState extends State<AdvancedDetailsPage> {
  final AdvancedDetailsController _con = AdvancedDetailsController();

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (_con.datosCargados)?
        Text('Detalles de Ruta - ${_con.readTimestamp(_con.travelHistory.timestamp)}'):
        Text('Detalles de Ruta'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ),
      bottomNavigationBar: _bottomButtons(),
      body: ListView(
            padding: EdgeInsets.zero,
            children: [
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
              // _buttonIniciarViaje(),
              // ignore: avoid_unnecessary_containers
            ],
          ),
    );
  }

  Widget _itemFrom() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      title: Text(_con.fromText),
      leading: const Icon(Icons.home, color: Colors.teal, size: 30),
      trailing: SizedBox(
          width: 50,
          child: _buttonFavoriteFrom()
        ),
    );
  }

  Widget _itemTo() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      title: Text(
        _con.toText,
      ),
      leading: const Icon(
        Icons.my_location_outlined,
        color: Colors.teal,
        size: 30,
      ),
      trailing: SizedBox(
          width: 50,
          child: _buttonFavoriteTo()
        ),
    );
  }

  Widget _buttonFavoriteTo(){
    return IconButton(
      icon: const Icon(Icons.star),
      onPressed: () {
        setState(() {
          _con.aliasText.text = _con.toText;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('¿Marcar como favorita?'),
              content: SizedBox(
                height: 120,
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 230,
                          child: TextField(
                            controller: _con.aliasText,
                            decoration: InputDecoration(
                              labelText: 'Alias',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 30,
                        ),
                        SizedBox(
                          width: 200,
                          child: Text(
                            _con.toText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.center,

                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('CANCELAR')
                ),
                TextButton(
                  onPressed: () => _con.guardarTo(),
                  child: Text('GUARDAR')
                ),
              ],
            )
          );
          //Boton eliminar
        }
      );
    }
  );
  }

  Widget _buttonFavoriteFrom(){
    return IconButton(
      icon: const Icon(Icons.star),
      onPressed: () {
        setState(() {
          _con.aliasText.text = _con.fromText;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('¿Marcar como favorita?'),
              content: SizedBox(
                height: 120,
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 230,
                          child: TextField(
                            controller: _con.aliasText,
                            decoration: InputDecoration(
                              labelText: 'Alias',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 30,
                        ),
                        SizedBox(
                          width: 200,
                          child: Text(
                            _con.fromText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.center,

                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('CANCELAR')
                ),
                TextButton(
                  onPressed: () => _con.guardarFrom(),
                  child: Text('GUARDAR')
                ),
              ],
            )
          );
          //Boton eliminar
        });
      }
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
          child: _buttonFavoriteWaypoint(direccion)
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

  Widget _buttonFavoriteWaypoint(Map<String, dynamic> direccion){
    return IconButton(
      icon: const Icon(Icons.star),
      onPressed: () {
        setState(() {
          _con.aliasText.text = "${direccion['direccion']}";
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('¿Marcar como favorita?'),
              content: SizedBox(
                height: 120,
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 230,
                          child: TextField(
                            controller: _con.aliasText,
                            decoration: InputDecoration(
                              labelText: 'Alias',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 30,
                        ),
                        SizedBox(
                          width: 200,
                          child: Text(
                            '${direccion['direccion']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('CANCELAR')
                ),
                TextButton(
                  onPressed: () => _con.guardarDireccion(direccion),
                  child: Text('GUARDAR')
                ),
              ],
            )
          );
        });
      }
    );
  }

  Widget _bottomButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 45,
              width: 320,
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: ((){
                if(_con.boolSaved == false){
                  return ButtonApp(
                    margin: 0,
                    color: Colors.teal,
                    icon: Icons.star,
                    onPressed: () {
                      setState(() {
                        _con.aliasText.text = "Ruta guardada ${_con.readTimestamp(_con.travelHistory.timestamp)}";
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('¿Marcar como favorita?'),
                            content: SizedBox(
                              height: 60,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 230,
                                        child: TextField(
                                          controller: _con.aliasText,
                                          decoration: InputDecoration(
                                            labelText: 'Alias',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('CANCELAR')
                              ),
                              TextButton(
                                onPressed: () => _con.guardarRuta(),
                                child: Text('GUARDAR')
                              ),
                            ],
                          )
                        );
                      });
                    },
                    text: 'Guardar ruta como favorita',
                  );
                }else{
                  return ButtonApp(
                    margin: 0,
                    color: Colors.red[900]!,
                    colorIcon: Colors.red[900]!,
                    icon: Icons.delete,
                    onPressed: () {
                      setState(() {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Quitar ruta de favoritos?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('CANCELAR')
                              ),
                              TextButton(
                                onPressed: () => _con.eliminarRuta(),
                                child: Text('ELIMINAR')
                              ),
                            ],
                          )
                        );
                      });
                    },
                    text: 'Quitar ruta de favoritos',
                  );
                }
              }())
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 45,
              width: 150,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ButtonApp(
                margin: 0,
                color: Colors.red,
                buttonIcon: false,
                onPressed: () {
                  Navigator.pop(context);
                },
                text: 'Volver',
              ),
            ),
            Container(
              height: 45,
              width: 150,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ButtonApp(
                buttonIcon: false,
                margin: 0,
                onPressed: () {
                  _con.goToTravelMap();
                },
                text: 'Repetir Ruta',
              ),
            ),
          ],
        ),
      ],
    );
  }

  void refresh(){
    setState(() {});
  }
}