import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:smavy/src/models/direccion_guardada.dart';
import 'package:smavy/src/models/ruta_guardada.dart';
import 'package:smavy/src/providers/auth_provider.dart';

class DireccionGuardadaProvider {
  final uid = AuthProvider().getUser()?.uid;
  late CollectionReference _ref;

  DireccionGuardadaProvider() {
    _ref = FirebaseFirestore.instance.collection('DireccionGuardada');
  }

  Future<String> create(DireccionGuardada direccionGuardada) async{
    String errorMessage;

    try {
      String id = _ref.doc().id;
      direccionGuardada.id = id;

      await _ref.doc(direccionGuardada.id).set(direccionGuardada.toJson());

      return id;
    } catch (error) {
      // ignore: avoid_print
      print(error);
      errorMessage = error.hashCode as String;
      return Future.error(errorMessage);
    }
  }
  
  Future<List<DireccionGuardada>?> getUserSavedLocations(TextEditingController aliasController, TextEditingController noteController) async {
    List<DireccionGuardada> _direccionGuardadaList = [];
    List<DocumentSnapshot> docs = [];

    await _ref.where('id_usuario', isEqualTo: uid).get().then((query) {
      return docs = query.docs;
    });

    if (docs.isNotEmpty) {
      for(var document in docs){
        DireccionGuardada direccionGuardada = DireccionGuardada.fromJson(document.data() as Map<String,dynamic>);
        aliasController.text = direccionGuardada.alias;
        if(direccionGuardada.nota != null){
          noteController.text = direccionGuardada.nota!;
        }
        _direccionGuardadaList.add(direccionGuardada);
      }
    }
    
    _direccionGuardadaList.sort((a, b) {
      return a.alias.compareTo(b.alias);
    });

    return _direccionGuardadaList;
  }

  Future<List<DireccionGuardada>?> getUserSavedLocationsMainMap() async {
    List<DireccionGuardada> _direccionGuardadaList = [];
    List<DocumentSnapshot> docs = [];

    await _ref.where('id_usuario', isEqualTo: uid).get().then((query) {
      return docs = query.docs;
    });

    if (docs.isNotEmpty) {
      for(var document in docs){
        DireccionGuardada direccionGuardada = DireccionGuardada.fromJson(document.data() as Map<String,dynamic>);
        _direccionGuardadaList.add(direccionGuardada);
      }
    }
    
    _direccionGuardadaList.sort((a, b) {
      return a.alias.compareTo(b.alias);
    });

    return _direccionGuardadaList;
  }

  Stream<DocumentSnapshot<Object?>> getByIdStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<RutaGuardada> getbyId(String id) async {
    DocumentSnapshot document = await _ref.doc(id).get();
    Map<String, dynamic> map = document.data() as Map<String, dynamic>;

    RutaGuardada rutaGuardada = RutaGuardada.fromJson(map);
    return rutaGuardada;
  }

  Future<void> update(DireccionGuardada data, String id) async {
    return _ref.doc(id).update(data.toJson());
  }

  Future<void> delete(String id) {
    return _ref.doc(id).delete();
  }
}
