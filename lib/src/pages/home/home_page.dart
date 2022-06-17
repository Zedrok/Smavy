import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smavy/src/pages/home/home_controller.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final HomePageController _con = HomePageController();
  late AnimationController _animation;
  late Animation<double> animation;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    // ignore: avoid_print
    print('INIT STATE - HomePage');

    _animation = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
        animationBehavior: AnimationBehavior.preserve);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
      // ignore: avoid_print
      print('METODO SCHEDULER - HomePage');
    });
    setRotation(180);

    _con.init(context);
  }

  @override
  void dispose() {
    _animation.dispose();

    super.dispose();
  }

  void setRotation(int grados) {
    final angulo = grados * pi / 180;
    animation = Tween<double>(
      begin: 0,
      end: angulo,
    ).animate(_animation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: TweenAnimationBuilder(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 4),
          child: const Image(
            image: AssetImage('assets/img/ic_launcher.png'),
          ),
          builder: (context, value, x) {
            return Transform.rotate(
                angle: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    x!,
                    const Text(
                      'Smavy',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ));
          },
        ),
      ),
    );
  }
}
