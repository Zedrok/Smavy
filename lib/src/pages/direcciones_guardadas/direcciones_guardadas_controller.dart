import 'package:flutter/material.dart';
import 'package:smavy/src/models/direccion_guardada.dart';
import 'package:smavy/src/providers/direccion_guardada_provider.dart';

class DireccionesGuardadasController {
  late BuildContext context;
  late String idTravelHistory;
  late Function refresh;

  late DireccionGuardadaProvider _direccionGuardadaProvider;
  late List<DireccionGuardada> savedLocations = [];
  bool datosCargados = false;
  TextEditingController aliasController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  Future init(BuildContext context, refresh) async {
    this.context = context;
    this.refresh = refresh;
    _direccionGuardadaProvider = DireccionGuardadaProvider();
    getSavedLocations();
  }

  void getSavedLocations() async {
    savedLocations = (await _direccionGuardadaProvider.getUserSavedLocations(aliasController, noteController))!;
    datosCargados = true;
    refresh();
  }

  void deleteSavedLocation(String id) async {
    await _direccionGuardadaProvider.delete(id);
    getSavedLocations();
  }

  void updateSavedLocation(DireccionGuardada data, String id) async {
    data.alias = aliasController.text;
    await _direccionGuardadaProvider.update(data, id);
    refresh();
  }

}