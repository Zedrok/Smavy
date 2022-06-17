import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smavy/src/pages/home/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final HomePageController _con = HomePageController();
  late AnimationController _animation;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    // ignore: avoid_print
    print('INIT STATE - HomePage');
    _con.init(context);
    _animation = AnimationController(
        vsync: this, duration: const Duration(seconds: 2), value: 360);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
      // ignore: avoid_print
      print('METODO SCHEDULER - HomePage');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // ignore: avoid_unnecessary_containers
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value,
              child: const Image(
                image: AssetImage(
                    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png'),
              ),
            );
          },
        ),
      ),
    );
  }
}
