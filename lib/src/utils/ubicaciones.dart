import 'package:google_maps_flutter/google_maps_flutter.dart';

class Ubicaciones {
  late LatLng latLng;
  late String direccion;
  late int orden; //Orden es opcional y no requerido para el constructor
  late String
      nomDireccion; //nombre direccion es solo para direcciones favoritas
  bool isFav = false; //se usa como predeterminado que no esta en favoritos.

  Ubicaciones(
    this.latLng,
    this.direccion,
  );
}
