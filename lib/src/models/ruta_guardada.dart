// To parse this JSON data, do
//
//     final travelHistory = travelHistoryFromJson(jsonString);

import 'dart:convert';

RutaGuardada travelHistoryFromJson(String str) => RutaGuardada.fromJson(json.decode(str));

String travelHistoryToJson(RutaGuardada data) => json.encode(data.toJson());

class RutaGuardada {
  RutaGuardada({
      required this.idUsuario,
      required this.idRuta,
      required this.alias
  });

  String idUsuario;
  String idRuta;
  String alias;

  factory RutaGuardada.fromJson(Map<String, dynamic> json) => RutaGuardada(
    idUsuario: json["id_usuario"],
    idRuta: json["id_ruta"],
    alias: json["alias"]
  );

  Map<String, dynamic> toJson() => {
    "id_usuario": idUsuario,
    "id_ruta": idRuta,
    "alias": alias
  };
}
