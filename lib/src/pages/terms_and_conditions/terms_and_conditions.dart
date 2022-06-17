import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:smavy/src/pages/terms_and_conditions/t_y_c_controller.dart';

class TerminosyCondicionesPage extends StatefulWidget {
  const TerminosyCondicionesPage({Key? key, Function? setState})
      : super(key: key);

  @override
  State<TerminosyCondicionesPage> createState() =>
      _TerminosyCondicionesPageState();
}

class _TerminosyCondicionesPageState extends State<TerminosyCondicionesPage> {
  final TyCcontroller _con = TyCcontroller();

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    // ignore: avoid_print
    print('INIT STATE');
    _con.init(context, refresh);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
      // ignore: avoid_print
      print('METODO SCHEDULER');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Terminos y Condiciones'),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Text(_con.textFromFile),
            )
          ],
        ),
      ),
    );
  }

  void refresh() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    setState(() {});
  }
}
