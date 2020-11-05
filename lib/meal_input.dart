import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'meal.dart';

class MealInputState extends State<MealInput> {
  final dbRef = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  var _mealNameController = TextEditingController();
  var _mealNotesController = TextEditingController();

  var _ratingController = TextEditingController();
  double _rating = 3.0;

  @override
  void initState() {
    _ratingController.text = "3.0";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add a new meal')),
        body: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                decoration: new InputDecoration(
                    hintText: "Meal Name",
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15)),
                controller: _mealNameController,
              ),
              RatingBar(
                initialRating: 3,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  _rating = rating;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: new InputDecoration(
                    hintText: "Additional Notes",
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15)),
                controller: _mealNotesController,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _addMeal(context);
                  }
                },
                child: Text('Add meal'),
              ),
            ])));
  }

  void _addMeal(BuildContext context) async {
    dbRef.collection("meal").add({
      'name': _mealNameController.text,
      'notes': _mealNotesController.text,
      'rating': _rating,
      'createdAt': Timestamp.now()
    });
    Navigator.pop(context);
    /*String mealName = _mealNameController.text;
    String mealNotes = _mealNotesController.text;
    Navigator.pop(context, new Meal.withNotes(mealName, _rating, mealNotes)); */
  }
}

class MealInput extends StatefulWidget {
  @override
  MealInputState createState() => new MealInputState();
}
