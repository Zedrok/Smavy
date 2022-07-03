// To parse this JSON data, do
//
//     final travelHistory = travelHistoryFromJson(jsonString);

import 'dart:convert';

DireccionGuardada direccionGuardadaFromJson(String str) => DireccionGuardada.fromJson(json.decode(str));

String direccionGuardadaToJson(DireccionGuardada data) => json.encode(data.toJson());

class DireccionGuardada {
  DireccionGuardada({
      this.id,
      this.nota,
      required this.idUsuario,
      required this.alias,
      required this.direccion,
      required this.lat,
      required this.lng
  });

  String? id;
  String idUsuario;
  String alias;
  String? nota;
  String direccion;
  double lat;
  double lng;

  factory DireccionGuardada.fromJson(Map<String, dynamic> json) => DireccionGuardada(
    id: json["id"],
    idUsuario: json["id_usuario"],
    alias: json["alias"],
    nota: json["nota"],
    direccion: json["direccion"],
    lat: json["lat"].toDouble(),
    lng: json["lng"].toDouble()
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_usuario": idUsuario,
    "alias": alias,
    "nota": nota,
    "direccion": direccion,
    "lat": lat,
    "lng": lng
  };
}
