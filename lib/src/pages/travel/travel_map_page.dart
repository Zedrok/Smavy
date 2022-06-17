import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smavy/src/pages/travel/travel_map_controller.dart';
import 'package:smavy/src/widgets/button_app.dart';

class TravelMapPage extends StatefulWidget {
  const TravelMapPage({Key? key}) : super(key: key);

  @override
  State<TravelMapPage> createState() => _TravelMapPageState();
}

class _TravelMapPageState extends State<TravelMapPage> {
  final TravelMapController _con = TravelMapController();
  Timer? timer;
  Duration duration = const Duration();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPopScope(),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.67,
              child: Align(
                child: _googleMapsWidget(),
                alignment: Alignment.topCenter,
              ),
            ),
            Align(
              child: _cardTravelInfo(),
              alignment: Alignment.bottomCenter,
            ),
            Align(
              child: _buttonBack(),
              alignment: Alignment.topLeft,
            ),
            // Align(
            //   child: _cardKmInfo(),
            //   alignment: Alignment.topRight,
            // ),
            Align(
              child: _cardTimeInfo(),
              alignment: Alignment.topRight,
            )
          ],
        ),
      ),
    );
  }

  Widget _cardTimeInfo(){
    return SafeArea(
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(top: 10, right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: const BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              CupertinoIcons.clock_fill,
              color: Colors.white,
              size: 18),
            Text(
              duration.inMinutes.remainder(60).toString().padLeft(2,'0')+':'+
              duration.inSeconds.remainder(60).toString().padLeft(2,'0'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonBack() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 10, top: 10),
        child: GestureDetector(
          onTap: (){
            _onWillPopScope();
          },
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.arrow_back,
              color: Colors.teal,
            )
          ),
        )
      ),
    );
  }

  Widget _cardTravelInfo() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.33,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.teal.shade300),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 75,
            child: Center(
              child: ListTile(
                title: const Text(
                  'Desde',
                  style: TextStyle(
                    fontSize: 15
                  ),
                ),
                subtitle: Text(
                  ((){
                    if(!_con.rutaComenzada){
                      return _con.fromText;
                    }else{
                      return _con.currentStartAddress;
                    }
                  }()),
                  style: const TextStyle(
                    fontSize: 13
                  )
                ),
                leading: SizedBox(
                  width: 38,
                  height: 38,
                  child: _con.legStartIcon()
                ),
              ),
            ),
          ),
          SizedBox(
            height: 75,
            child: Center(
              child: ListTile(
                title: const Text(
                  'Hasta',
                  style: TextStyle(
                    fontSize: 15
                  ),
                ),
                subtitle: Text(
                  ((){
                    if(!_con.rutaComenzada){
                      return _con.toText;
                    }else{
                      return _con.currentEndAddress;
                    }
                  }()),
                  style: const TextStyle(
                    fontSize: 13
                  )
                ),
                leading: SizedBox(
                  width: 38,
                  height: 38,
                  child: _con.legEndIcon()
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              (_con.currentLeg > 0)?
              _buttonPreviousLeg():
              _buttonCancel(),

              (!_con.rutaComenzada)?
                _buttonStart():
                  (!_con.rutaTerminada)?
                  _buttonNextLeg():
                  _buttonFinish()
            ],
          )
        ],
      ),
    );
  }

  Widget _buttonPreviousLeg(){
    return SizedBox(
      width: 150,
      child: ButtonApp(
        buttonIcon: false,
        margin: 10,
        onPressed: () {
          _con.previousLeg();
          refresh();
        },
        text: 'Volver',
        textColor: Colors.white,
        color: Colors.red.shade800,
      ),
    );
  }

  Widget _buttonCancel(){
    return SizedBox(
      width: 150,
      child: ButtonApp(
        buttonIcon: false,
        margin: 10,
        onPressed: () {
          _onWillPopScope();
        },
        text: 'Cancelar',
        textColor: Colors.white,
        color: Colors.red.shade800,
      ),
    );
  }

  Widget _buttonStart(){
    return SizedBox(
      width: 150,
      child: ButtonApp(
        buttonIcon: false,
        margin: 10,
        onPressed: () {
          if(!_con.rutaComenzada){
            _con.comenzarRuta();
            startTimer();
          }
          refresh();
        },
        text: 'Comenzar',
        textColor: Colors.white,
        color: Colors.teal,
      ),
    );
  }

  Widget _buttonFinish(){
    return SizedBox(
      width: 150,
      child: ButtonApp(
        buttonIcon: false,
        margin: 10,
        onPressed: () {
          refresh();
          _con.setLastLegDuration(duration);
          timer!.cancel();
          _con.finishRoute(duration);
        },
        text: 'Finalizar',
        textColor: Colors.white,
        color: Colors.teal,
      ),
    );
  }

  Widget _buttonNextLeg(){
    return SizedBox(
      width: 150,
      child: ButtonApp(
        buttonIcon: false,
        margin: 10,
        onPressed: () {
          _con.setLastLegDuration(duration);
          _con.nextLeg();
          refresh();
        },
        text: 'Siguiente',
        textColor: Colors.white,
        color: Colors.teal,
      ),
    );
  }

  Widget _googleMapsWidget() {
    return GoogleMap(
      polylines: _con.polylines,
      trafficEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
    );
  }

  void startTimer(){
    timer = Timer.periodic(const Duration(seconds: 1), (timer) { addTime(); });
  }

  void addTime(){
    setState((){
      final seconds = duration.inSeconds + 1;
      duration = Duration(seconds: seconds);
    });
  }

  Future<bool> _onWillPopScope() async {
    if(_con.rutaComenzada){
      return await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('¿Desea cancelar la ruta en curso?'),
          actions: [
            FloatingActionButton(
                onPressed: () => {Navigator.pop(context), Navigator.pop(context)}, child: const Text('Si')),
            FloatingActionButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No')),
          ],
        ),
      );
    }else{
      return await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('¿Desea volver a planificar la ruta?'),
          actions: [
            FloatingActionButton(
                onPressed: () => {Navigator.pop(context), Navigator.pop(context)}, child: const Text('Si')),
            FloatingActionButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No')),
          ],
        ),
      );
    }
  }

  void refresh() async {
    if(mounted){
      setState(() {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      });
    }
    
  }
}
