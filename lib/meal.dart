import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  String name;
  String notes;
  double rating;
  Timestamp createdAt;
  DocumentReference reference;

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
}