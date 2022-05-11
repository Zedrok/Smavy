import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smavy/src/models/app_user.dart';

class UserProvider{

  late CollectionReference _ref;

  UserProvider(){
    _ref = FirebaseFirestore.instance.collection('AppUsers');
  }

  Future<void> create(AppUser user){
    String errorMessage;

    try {
      return _ref.doc(user.id).set(user.toJson());
    } catch(error) {
      // ignore: avoid_print
      print(error);
      errorMessage = error.hashCode as String;
      return Future.error(errorMessage);
    }
  }
}