import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smavy/src/models/ruta_guardada.dart';
import 'package:smavy/src/providers/auth_provider.dart';

class RutaGuardadaProvider {
  final uid = AuthProvider().getUser()?.uid;
  late CollectionReference _ref;

  RutaGuardadaProvider() {
    _ref = FirebaseFirestore.instance.collection('RutaGuardada');
  }

  Future<void> create(RutaGuardada rutaGuardada) {
    String errorMessage;

    try {
      return _ref.doc(rutaGuardada.idRuta).set(rutaGuardada.toJson());
    } catch (error) {
      // ignore: avoid_print
      print(error);
      errorMessage = error.hashCode as String;
      return Future.error(errorMessage);
    }
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

  Future<void> update(Map<String, dynamic> data, String id) async {
    return _ref.doc(id).update(data);
  }

  Future<void> delete(String id) {
    return _ref.doc(id).delete();
  }
}
