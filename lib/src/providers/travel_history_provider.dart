import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smavy/src/models/travel_history.dart';
import 'package:smavy/src/providers/auth_provider.dart';

class TravelHistoryProvider {

  late CollectionReference _ref;
  late AuthProvider _authProvider;

  TravelHistoryProvider() {
    _authProvider = AuthProvider();
    _ref = FirebaseFirestore.instance.collection('TravelHistory');
  }

  Future<String> create(TravelHistory travelHistory) async {
    String errorMessage;

    try {
      String id = _ref.doc().id;
      travelHistory.id = id;

      await _ref.doc(travelHistory.id).set(travelHistory.toJson());
      int i = 1;
      for(var leg in travelHistory.legs){
        await _ref.doc(travelHistory.id).collection('Legs').doc(i.toString()).set(leg.toJson());
        i++;
      }
      return id;
    } catch(error) {
      errorMessage = error.hashCode.toString();
    }
    return Future.error(errorMessage);
  }

  Stream<DocumentSnapshot> getByIdStream(String id) {
    return _ref.doc(id).snapshots(includeMetadataChanges: true);
  }

  Future<TravelHistory?> getById(String id) async {
    DocumentSnapshot document = await _ref.doc(id).get();
    if (document.exists) {
      TravelHistory travelHistory = TravelHistory.fromJson(document.data() as Map<String,dynamic>);
      int i = 1;
      DocumentSnapshot documentLeg = await _ref.doc(id).collection('Legs').doc(i.toString()).get();
      while(documentLeg.exists){
        travelHistory.legs.add(RouteLeg.fromJson(documentLeg.data() as Map<String,dynamic>));
        i++;
        documentLeg = await _ref.doc(id).collection('Legs').doc(i.toString()).get();
      }
      return travelHistory;
    }
    return null;
  }

  Future<List<TravelHistory>?> getUserTravels() async {
    List<TravelHistory> _travelHistoryList = [];
    List<DocumentSnapshot> docs = [];

    await _ref.where('id_usuario', isEqualTo: _authProvider.getUser()!.uid).get().then((query) {
      return docs = query.docs;
    });

    if (docs.isNotEmpty) {
      for(var document in docs){
        TravelHistory travelHistory = TravelHistory.fromJson(document.data() as Map<String,dynamic>);
        _travelHistoryList.add(travelHistory);
      }
    }
    
    _travelHistoryList.sort((a, b) {
      return b.timestamp.compareTo(a.timestamp);
    });

    return _travelHistoryList;
  }

  Future<void> update(Map<String, dynamic> data, String id) {
    return _ref.doc(id).update(data);
  }

  Future<void> delete(String id) {
    return _ref.doc(id).delete();
  }

}