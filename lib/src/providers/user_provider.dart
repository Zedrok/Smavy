import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smavy/src/models/app_user.dart';
import 'package:smavy/src/providers/auth_provider.dart';

class UserProvider {
  final uid = AuthProvider().getUser()!.uid;

  late CollectionReference _ref;
  // ignore: unused_field

  UserProvider() {
    _ref = FirebaseFirestore.instance.collection('AppUsers');
  }

  Future<void> create(AppUser user) {
    String errorMessage;

    try {
      return _ref.doc(user.id).set(user.toJson());
    } catch (error) {
      // ignore: avoid_print
      print(error);
      errorMessage = error.hashCode as String;
      return Future.error(errorMessage);
    }
  }

  Future<bool> updateUserData(int n, String text) async {
    var data =
        await FirebaseFirestore.instance.collection('AppUsers').doc(uid).get();
    if (n == 0) {
      data.data()!.update('username', (value) => text);
      return true;
    }

    if (n == 1) {
      data.data()!.update('email', (value) => text);
      return true;
    }

    if (n == 2) {
      data.data()!.update('password', (value) => text);
      return true;
    }

    return false;
  }

  Stream<DocumentSnapshot<Object?>> getByIdStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<AppUser?> getbyId(String id) async {
    DocumentSnapshot document = await _ref.doc(id).get();
    Map<String, dynamic> map = document.data() as Map<String, dynamic>;

    if (document.exists) {
      AppUser appUser = AppUser.fromJson(map);
      return appUser;
    }
    return null;
  }

  Future<void> update(Map<String, dynamic> data, String id) async {
    return _ref.doc(id).update(data);
  }

  Future<void> delete(String id) {
    return _ref.doc(id).delete();
  }
}
