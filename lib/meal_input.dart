import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mensa_rating_app/camera_view.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;


import 'meal.dart';

class MealInputState extends State<MealInput> {
  final dbRef = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final storage = firebase_storage.FirebaseStorage.instance;
  final _formKey = GlobalKey<FormState>();
  var _mealNameController = TextEditingController();
  var _mealNotesController = TextEditingController();

  String _photoPath;

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
            Padding(
              child: Container(),
              padding: EdgeInsets.all(20),
            ),
            _mealPhoto(context),
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
          ])),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _takePicture(context),
        child: Icon(Icons.camera),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _mealPhoto(BuildContext context) {
    return Image(
        image: _photoPath == null
            ? AssetImage('assets/mealplate.png')
            : FileImage(File(_photoPath)),
        height: 200,
        width: 200,
        fit: BoxFit.fitWidth);
  }

  void _safePhoto(String name) async{
    File photo = File(_photoPath);
    try {
      await storage.ref('$name.png').putFile(photo);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  void _addMeal(BuildContext context) async {
    var docRef = dbRef
        .collection("users")
        .doc(auth.currentUser.uid)
        .collection("meals")
        .add({
      'name': _mealNameController.text,
      'notes': _mealNotesController.text,
      'rating': _rating,
      'createdAt': Timestamp.now()
    });
    docRef.then((value) => _safePhoto(value.path));



    Navigator.pop(context, _photoPath);
  }

  void _takePicture(BuildContext context) async {
    var cameras = await availableCameras();
    var firstCamera = cameras.first;
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePictureScreen(camera: firstCamera)));
    if (result != null) {
      setState(() {
        _photoPath = result;
      });
    }
  }
}

class MealInput extends StatefulWidget {
  @override
  MealInputState createState() => new MealInputState();
}
