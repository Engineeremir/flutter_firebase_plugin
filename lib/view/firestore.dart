
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FireStoreOperations extends StatefulWidget {
  const FireStoreOperations({Key? key}) : super(key: key);

  @override
  _FireStoreOperationsState createState() => _FireStoreOperationsState();
}

class _FireStoreOperationsState extends State<FireStoreOperations> {

  FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _addData, child: Text('Add Data')),
            ElevatedButton(
                onPressed: _transaction, child: Text('Transaction Data')),
            ElevatedButton(onPressed: _deleteData, child: Text('Delete Data')),
            ElevatedButton(onPressed: _readData, child: Text('Read Data')),
            ElevatedButton(onPressed: _queryData, child: Text('Query Data')),

          ],
        ),
      ),
    );
  }

  void _addData() {
    Map<String, dynamic> add = Map();
    add['name'] = "emir";
    add['surname'] = "kalem";
    add['money'] = 900;

    //CREATE DATA:

    _fireStore
        .collection("users")
        .doc("emirhan_kalem")
        .set((add), SetOptions(merge: true))
        .then((value) => debugPrint("added"));
    _fireStore.collection("users").doc("omer_kalem").set(
        {"name": "Ömer", "surname": "kalem", "money": 300},
        SetOptions(merge: true)).then((value) => debugPrint("added"));

    //OR

    /*_fireStore.collection("users").add({"name": "Elif", "surname": "kalem","money":300}).catchError((e) {
      debugPrint("Error!! Data couldn\'t add: $e");
    });*/

    //UPDATE DATA:

    _fireStore
        .doc("users/emirhan_kalem")
        .update({"name": "emirhan", "time": FieldValue.serverTimestamp()})
        .then((value) => debugPrint("name updated"))
        .catchError((e) => debugPrint("Error!! Data couldn\'t update: $e"));
  }

  void _transaction() {
    final DocumentReference? _emirRef = _fireStore.doc("users/emirhan_kalem");
    _fireStore.runTransaction((Transaction transaction) async {
      DocumentSnapshot? emirData = await _emirRef!.get();

      DocumentReference? _omerRef = _fireStore.doc("users/omer_kalem");

      var emirMoney = emirData.get("money");

      try {
        if (emirData.exists) {
          try {
            if (emirMoney > 100) {
               transaction.update(_emirRef, {'money': (emirMoney - 100)});
               transaction
                  .update(_omerRef, {'money': FieldValue.increment(100)});
            }
          } catch (e) {
            debugPrint('insufficient balance: $e');
          }
        }
      } catch (e) {
        debugPrint("Collection does not exists: $e");
      }
    });
  }

  void _deleteData() {
    _fireStore
        .doc("users/emirhan_kalem")
        .delete()
        .then((value) => debugPrint("deleted"))
        .catchError((e) => debugPrint("Error!! Data couldn\'t delete: $e"));

    //DELETE ANY FİELD
    _fireStore
        .doc("users/omer_kalem")
        .update({"surname": FieldValue.delete()})
        .then((value) => debugPrint("Surname Deleted"))
        .catchError((e) => debugPrint("Surname couldn\'t delete: $e"));
  }

  void _readData() async {
    DocumentSnapshot _documentSnapshot =
        await _fireStore.doc("emirhan_kalem").get();

    debugPrint("Document Id : " + _documentSnapshot.id);
    debugPrint(
        "Document exist or not : " + _documentSnapshot.exists.toString());
    debugPrint("Document String : " + _documentSnapshot.toString());
    debugPrint("Is Document coming from cache ?  : " +
        _documentSnapshot.metadata.isFromCache.toString());
    debugPrint("Is Document coming from cache ?  : " +
        _documentSnapshot.data().toString());
    _fireStore.collection("users").get().then((querysnapshots) {
      debugPrint("Element lenght of User collection:" +
          querysnapshots.docs.length.toString());

      for (int i = 0; i < querysnapshots.docs.length; i++) {
        debugPrint(querysnapshots.docs[i].data().toString());
      }

      //Listening Instant Changing Values
      var ref = _fireStore.collection("users").doc("emirhan_kalem");
      ref.snapshots().listen((changingValue) {
        debugPrint("instant : " + changingValue.data().toString());
      });
    });
  }

  void _queryData() async {
    var documents = await _fireStore
        .collection("users")
        .where("name", isEqualTo: "emirhan")
        .get();
    for (var document in documents.docs) {
      debugPrint(document.data().toString());
    }

    var limited = await _fireStore.collection("users").limit(2).get();
    for (var document in limited.docs) {
      debugPrint("Limited values : " + document.data().toString());
    }

    var queryCommon = await _fireStore
        .collection("users")
        .where("mail", arrayContains: "emirhan@gmail.com")
        .get();
    for (var document in queryCommon.docs) {
      debugPrint("Common Values : " + document.data().toString());
    }
  }

}
