// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smavy/src/models/travel_history.dart';
import 'package:smavy/src/pages/route_details/route_details_controller.dart';
import 'package:smavy/src/widgets/button_app.dart';

class RouteDetailsPage extends StatefulWidget {
  const RouteDetailsPage({Key? key}) : super(key: key);

  @override
  State<RouteDetailsPage> createState() => _RouteDetailsPageState();
}

class _RouteDetailsPageState extends State<RouteDetailsPage> {
  final RouteDetailsController _con = RouteDetailsController();

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
        title: (_con.datosCargados)?
        Text('Historial - ${_con.readTimestamp(_con.travelHistory.timestamp)}'):
        Text('Historial'),
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
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 15),
                _listTileTravelFrom(),
                _listTileTravelTo(),
                SizedBox(height: 0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      child: Column(
                        children: [
                          SizedBox(
                            child: Icon(
                              CupertinoIcons.time
                            )
                          ),
                          SizedBox(height: 10,),
                          SizedBox(
                            child: Text(
                              (_con.datosCargados)?
                              _con.travelHistory.totalDuration.inMinutes.remainder(60).toString().padLeft(2,'0')+':'+
                              _con.travelHistory.totalDuration.inSeconds.remainder(60).toString().padLeft(2,'0'):
                              '',
                            )
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                          child: Icon(
                            Icons.directions_walk
                          )
                        ),
                        SizedBox(height: 10,),
                        SizedBox(
                          child: Text(
                            (_con.datosCargados)?_con.transformarDistancia(_con.travelHistory.totalDistance):''
                          )
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                (_con.datosCargados)?SizedBox(
                  height: MediaQuery.of(context).size.height*0.45,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal:20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: 
                    ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: _con.travelHistory.legs.length,
                      itemBuilder: (BuildContext context, int index) =>
                        _buildList(_con.travelHistory.legs[index], index)
                    ),
                  ),
                ):
                SizedBox()
              ],
            ),
          ]
        ),
      ),
    );
  }

  Widget _buildList(RouteLeg data, int index) {
    return ExpansionTile(
      leading: Icon(Icons.location_on),
      title: Text(
        'Tramo ${index+1}',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          data.startAddress,
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
                      width: MediaQuery.of(context).size.width*0.67,
                      child: Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          data.endAddress,
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
                          data.duration.inMinutes.remainder(60).toString().padLeft(2,'0')+':'+
                          data.duration.inSeconds.remainder(60).toString().padLeft(2,'0')
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
                          _con.transformarDistancia(data.distance)
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5),
          ],
        )
      ]
    );
  }


  Widget _bottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        
        Container(
          height: 50,
          width: 150,
          margin: EdgeInsets.only(bottom: 10),
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
          height: 50,
          width: 150,
          margin: EdgeInsets.only(bottom: 10),
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
    );
  }

  Widget _listTileTravelFrom() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
        title: Text(
          'Inicio',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14
          ),
          maxLines: 1,
        ),
        subtitle: Text(
          (_con.datosCargados)?_con.travelHistory.fromText:'',
          style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 14
          ),
          maxLines: 2,
        ),
        leading: Icon(Icons.home, color: Colors.teal,),
      ),
    );
  }

  Widget _listTileTravelTo(){
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ListTile(
        title: Text(
          'Fin',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14
          ),
          maxLines: 1,
        ),
        subtitle: Text(
          (_con.datosCargados)?_con.travelHistory.toText:'',
          style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 14
          ),
          maxLines: 2,
        ),
        leading: Icon(Icons.my_location, color: Colors.teal,),
      ),
    );
  }

  void refresh(){
    setState(() {});
  }
}