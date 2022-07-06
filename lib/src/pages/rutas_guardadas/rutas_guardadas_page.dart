// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smavy/src/models/travel_history.dart';
import 'package:smavy/src/pages/rutas_guardadas/rutas_guardadas_controller.dart';
import 'package:smavy/src/widgets/button_app.dart';

class RutasGuardadasPage extends StatefulWidget {
  const RutasGuardadasPage({Key? key}) : super(key: key);

  @override
  State<RutasGuardadasPage> createState() => _RutasGuardadasPageState();
}

class _RutasGuardadasPageState extends State<RutasGuardadasPage> {
  final RutasGuardadasController _con = RutasGuardadasController();

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
    return 
    Scaffold(
      appBar: AppBar(
        title: const Text('Rutas Guardadas'),
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
      body: Column(
        children: [
          (_con.datosCargados && _con.rutasGuardadasList.isNotEmpty)?
          SizedBox(
            height: MediaQuery.of(context).size.height*0.85,
            child: ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: _con.rutasGuardadasList.length,
              itemBuilder: (BuildContext context, int index) =>
                _buildList(_con.rutasGuardadasList[index], index)
            ),
          ):
          SizedBox()
        ],
      ),
    );
  }

  Widget _buildList(TravelHistory data, int index) {
    return ExpansionTile(
      leading: Icon(Icons.location_on),
      title: Row(
        children: [
          SizedBox(
            width: 143,
            child: Text(
              data.alias!,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '  -  ${_con.transformarDistancia(data.totalDistance)}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500]
            ),
          )
        ],
      ),
      children: [
        const Divider(
          thickness: 1,
          indent: 10,
          endIndent: 10,
          color: Colors.grey,
          height: 5.0,
        ),
        Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        child: Text(
                          'Desde',
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.67,
                      child: Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          data.fromText,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
            Row(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        child: Text(
                          'Hasta',
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.65,
                      child: Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          data.toText,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Icon(
                            CupertinoIcons.timer,
                            size: 20,
                          ),
                        ),
                        Text(
                          data.totalDuration.inMinutes.remainder(60).toString().padLeft(2,'0')+':'+
                          data.totalDuration.inSeconds.remainder(60).toString().padLeft(2,'0')
                        ),
                        SizedBox(width: 30),
                        SizedBox(
                          width: 30,
                          child: Icon(
                            Icons.directions_walk,
                            size: 20,
                          ),
                        ),
                        Text(
                          _con.transformarDistancia(data.totalDistance)
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
            _buttonRuta(data.id!)
          ],
        )
      ]
    );
  }

  Widget _buttonRuta(String id) {
    return Container(
      height: 35,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: ButtonApp(
        onPressed: () {
          _con.goToSummaryPage(id);
        },
        text: 'Ver Ruta',
        buttonIcon: false,
        
      ),
    );
  }

  void refresh(){
    setState(() {});
  }
}