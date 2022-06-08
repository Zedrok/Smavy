import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smavy/src/pages/travel_info/travel_info_controller.dart';
import 'package:smavy/src/widgets/button_app.dart';

class TravelInfoPage extends StatefulWidget {
  const TravelInfoPage({Key? key}) : super(key: key);

  @override
  State<TravelInfoPage> createState() => _TravelInfoPageState();
}

class _TravelInfoPageState extends State<TravelInfoPage> {
  final TravelInfoController _con = TravelInfoController();

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
    return Scaffold(
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
          Align(
            child: _cardKmInfo(),
            alignment: Alignment.topRight,
          ),
          Align(
            child: _cardTimeInfo(),
            alignment: Alignment.topRight,
          )
        ],
      ),
    );
  }

  Widget _cardKmInfo(){
    return SafeArea(
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(top: 10, right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: const BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Text(
          _con.distance,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _cardTimeInfo(){
    return SafeArea(
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(top: 40, right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: const BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Text(
          // _con.info!.totalDuration ?? ' ',
          _con.time,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.teal,
          ),
        ),
      ),
    );
  }

  Widget _buttonBack() {
    return SafeArea(
      child: Container(
          margin: const EdgeInsets.only(left: 10, top: 10),
          child: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.arrow_back,
                color: Colors.teal,
              ))),
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
          ListTile(
            title: const Text(
              'Desde',
              style: TextStyle(
                fontSize: 15
              ),
            ),
            subtitle: Text(
              _con.fromText,
              style: const TextStyle(
                fontSize: 13
              )
            ),
            leading: const Icon(Icons.my_location),
          ),
          ListTile(
            title: const Text(
              'Hasta',
              style: TextStyle(
                fontSize: 15
              ),
            ),
            subtitle: Text(
              _con.toText,
              style: const TextStyle(
                fontSize: 13
              )
            ),
            leading: const Icon(Icons.location_on),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                child: ButtonApp(
                  buttonIcon: false,
                  margin: 10,
                  onPressed: () {},
                  text: 'Cancelar',
                  textColor: Colors.white,
                  color: Colors.red.shade800,
                ),
              ),
              SizedBox(
                width: 150,
                child: ButtonApp(
                  buttonIcon: false,
                  margin: 10,
                  onPressed: () {},
                  text: 'Confirmar',
                  textColor: Colors.white,
                  color: Colors.teal,
                ),
              ),
            ],
          )
        ],
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
      // onCameraMove: (position) {
      //   FocusManager.instance.primaryFocus?.unfocus();
      //   _con.initialPosition = position;
      //   _con.screenCenter = position.target;
      //   print('ON CAMERA MOVE: $position');
      // },
      // onCameraIdle: () async {
      //   await _con.setLocationDraggableInfo();
      // },
      // onTap: (argument) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  void refresh(){
    if(mounted){
      setState(() {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      });
    }
  }
}
