import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smavy/src/pages/home/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomePageController _con = HomePageController();

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    // ignore: avoid_print
    print('INIT STATE - HomePage');
    _con.init(context);

    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _con.init(context);
      // ignore: avoid_print
      print('METODO SCHEDULER - HomePage');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: (Text('Esto es el home c: después pondremos una imagen uwu')),
      ),
    );
  }
}
