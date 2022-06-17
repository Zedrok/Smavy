// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:smavy/src/models/travel_history.dart';
import 'package:smavy/src/pages/travel/travel_summary_controller.dart';
import 'package:smavy/src/widgets/button_app.dart';

class TravelSummaryPage extends StatefulWidget {
  const TravelSummaryPage({Key? key}) : super(key: key);

  @override
  State<TravelSummaryPage> createState() => _TravelSummaryPageState();
}

class _TravelSummaryPageState extends State<TravelSummaryPage> {
  final TravelSummaryController _con = TravelSummaryController();

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
    WillPopScope(
      onWillPop: _onWillPopScope,
      child: Scaffold(
        bottomNavigationBar: _buttonClose(),
        body: Stack(
          children: [
            _bannerSuccess(),
            Column(
              children: [
                SizedBox(height: 150),
                _listTileTravelFrom(),
                _listTileTravelTo(),
                SizedBox(height: 5,),
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
                              _con.travelHistory.totalDuration.inMinutes.remainder(60).toString().padLeft(2,'0')+':'+
                              _con.travelHistory.totalDuration.inSeconds.remainder(60).toString().padLeft(2,'0'),
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
                            _con.transformarDistancia(_con.travelHistory.totalDistance)
                          )
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.35,
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
                        _buildList(_con.travelHistory.legs[index])
                    ),
                  ),
                )
              ],
            ),
          ]
        ),
      ),
    );
  }

//  Widget myWidget(BuildContext context) {
//    return MediaQuery.removePadding(
//      context: context,
//      removeTop: true,
//      child: GridView.builder(
//        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//          crossAxisCount: 3,
//        ),
//        itemCount: 300,
//        itemBuilder: (BuildContext context, int index) {
//          return Card(
//            color: Colors.amber,
//            child: Center(child: Text('$index')),
//          );
//        }
//      ),
//    );
//  }

  Widget _buildList(RouteLeg data) {
    
    return ExpansionTile(
      leading: Icon(Icons.location_on),
      title: Text(
        'Tiempo',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: [
        Text(
          _con.transformarDistancia(data.distance)
        )
      ]
    );
  }


  Widget _buttonClose() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: ButtonApp(
        onPressed: () {},
        text: 'Volver al Inicio',
      ),
    );
  }

  Widget _listTileTravelFrom() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
        title: Text(
          'Desde',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14
          ),
          maxLines: 1,
        ),
        subtitle: Text(
          _con.travelHistory.fromText,
          style: const TextStyle(
              color: Colors.grey,
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
          _con.travelHistory.fromText,
          style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14
          ),
          maxLines: 2,
        ),
        leading: Icon(Icons.my_location, color: Colors.teal,),
      ),
    );
  }

  Widget _bannerSuccess() {
    return ClipPath(
      clipper: ArcClipper(),
      child: Container(
        height: 220,
        width: double.infinity,
        color: Colors.teal,
        child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 70
                ),
              ),
              const Text(
                'TU VIAJE HA FINALIZADO',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
              const SizedBox(height: 10),
            ]
          )
        ),
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

  void refresh(){
    setState(() {});
  }
}