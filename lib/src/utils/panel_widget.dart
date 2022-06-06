import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smavy/src/utils/ubicaciones.dart';
import 'package:smavy/src/widgets/button_app.dart';

class PanelWidget extends StatelessWidget {
  final ScrollController controller;
  final PanelController panelController;

  PanelWidget({
    Key? key,
    required this.controller,
    required this.panelController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildAboutText();
  }

  final List<Ubicaciones> _direcciones = [];

  Widget _buildAboutText() => ListView(
        padding: EdgeInsets.zero,
        controller: controller,
        children: [
          const SizedBox(
            height: 5,
          ),
          _buildDragHandle(),
          const SizedBox(
            height: 18,
          ),
          ..._direcciones.map((e) {
            return buildItem(e);
          }).toList(),
          const SizedBox(
            height: 24,
          ),
        ],
      ); //_buildAboutText()

  Widget _buildDragHandle() => Container(
        alignment: Alignment.topCenter,
        child: GestureDetector(
          child: ButtonApp(
            onPressed: () {},
            text: 'COMENZAR RUTA',
            color: Colors.teal,
            textColor: Colors.white,
          ),
          onTap: _togglePanel,
        ),
      );

  Widget buildItem(Ubicaciones e) {
    return ListTile(
      title: Text(e.direccion),
      subtitle:
          Text('latitud: $e.latLng.latitude longitud: $e.latLng.longitude'),
    );
  }

  void _togglePanel() {
    panelController.isPanelOpen
        ? panelController.close()
        : panelController.open();
  }

  void agregarItem(Ubicaciones dir) {
    _direcciones.add(dir);
  }
}
