import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


final auth = FirebaseAuth.instance;
final dbRef = FirebaseFirestore.instance;
final storage = firebase_storage.FirebaseStorage.instance;



class Meal {
  String id;
  String name;
  String notes;
  double rating;
  Timestamp createdAt;
  DocumentReference reference;
  String photoURL = '';

  Meal(this.name, this.rating) {
    this.createdAt = Timestamp.now();
  }

  Meal.withNotes(this.name, this.rating, this.notes) {
    this.createdAt = Timestamp.now();
  }

  Meal.fromMap(Map<String, dynamic> map, {this.reference}) :
      assert(map['name'] != null),
      assert(map['rating'] != null),
      name = map['name'],
      rating = map['rating'],
      notes = map['notes'],
        createdAt = map['createdAt'];

  Meal.fromSnapshot(DocumentSnapshot snapshot) :
      this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => 'Meal<$name:$rating>';

  void deleteReference(){
    FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser.uid)
        .collection("meals")
        .doc(id).delete();
  }

  void safeReference() {
    final Map<String, dynamic> mealData = {};
    mealData["name"] = name;
    mealData["notes"] = notes;
    mealData["rating"] = rating;
    mealData["createdAt"] = createdAt;
    dbRef
        .collection("users")
        .doc(auth.currentUser.uid)
        .collection("meals")
    .doc(id).set(mealData);
  }

  Future<String> getPhotoURL() async {
    String userID = auth.currentUser.uid;
    final ref = storage.ref('users/$userID/meals/$id.png');

    return await ref.getDownloadURL();
  }
}