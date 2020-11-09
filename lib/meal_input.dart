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
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:mensa_rating_app/main.dart';
import 'package:mensa_rating_app/meal_view.dart';


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
            FutureBuilder<List<MensaMeal>>(
              future: _fetchMeals(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text("${snapshot.error}");
                return snapshot.hasData
                    ? _mensaMealList(context, snapshot.data)
                    : Center(child: CircularProgressIndicator());
              },
            ),
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

  Widget _mensaMealList(BuildContext context, List<MensaMeal> meals) {
    return
      Flexible(
          child: Container(
    padding: EdgeInsets.all(30),
    child:DropdownButton(
              hint: Text("Select a meal from today"),
              isExpanded: true,
              onChanged: (value) {},
              items: meals.map((meal) {
                return new DropdownMenuItem<String>(
                  value: meal.name,
                  child: new Text(meal.name),
                  onTap: () {
                    _mealNameController.text = meal.name;
                    _mealNotesController.text = meal.category;
                    },
                );
              }).toList())))
    ;
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

  Future<dynamic> _savePhoto(String name) async {
    if (_photoPath == null) return null;
    File photo = File(_photoPath);
    try {
      return await storage.ref('$name.png').putFile(photo);
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
    //TODO: Implement asynchronous saving of the photo
    //Currently we have to wait for the photo to be saved in order for it to be displayed correctly in the overview state.
    docRef.then((value) {
      _savePhoto(value.path).then((value) => {
        Navigator.pop(context,_photoPath)
      });
    });
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

  List<MensaMeal> parseMeals(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<MensaMeal>((json) => MensaMeal.fromJson(json)).toList();
  }

  Future<List<MensaMeal>> _fetchMeals() async {
    final dateFormat = DateFormat("yyyy-MM-dd");
    String today = dateFormat.format(DateTime.now());
    final response = await http
        .get('https://openmensa.org/api/v2/canteens/62/days/$today/meals');
    return parseMeals(response.body);
  }
}

class MealInput extends StatefulWidget {
  @override
  MealInputState createState() => new MealInputState();
}

class MensaMeal {
  final String name;
  final String category;

  MensaMeal(this.name, this.category);
  factory MensaMeal.fromJson(Map<String, dynamic> json) {
    return MensaMeal(json['name'], json['category']);
  }
}
