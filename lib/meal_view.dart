import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

import 'meal.dart';

class MealViewState extends State<MealView> {
  final dbRef = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final storage = firebase_storage.FirebaseStorage.instance;
  final Meal meal;
  String _photoURL;

  MealViewState(@required this.meal);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Meal Details')),
        body: Column(children: <Widget>[
          _mealPhoto(context),
          Text("Meal id:" + meal.id),
          Text("Meal name:" + meal.name),
          Text("Meal rating:" + meal.rating.toString()),
          Text("Meal notes:" + meal.notes),
          Text("Meal eating on:" + meal.createdAt.toDate().toString()),
        ]));
  }

  Future<String> _downloadPhoto() async {
    String userID = auth.currentUser.uid;
    String mealID = meal.id;
    final ref = storage.ref('users/$userID/meals/$mealID.png');

    return await ref.getDownloadURL();

    /*print('users/$userID/meals/$mealID.png');
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File downloadToFile = File('${appDocDir.absolute}/download-photo.png');
    try {
      await storage
          .ref('users/$userID/meals/$mealID.png')
          .writeToFile(downloadToFile);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
    return downloadToFile; */
  }

  Widget _mealPhoto(BuildContext context) {
    _downloadPhoto().then((value) => setState(() {
      _photoURL = value.toString();
      print(_photoURL);
    }));

    return Image(
        image: _photoURL == null
            ? AssetImage('assets/mealplate.png')
            : NetworkImage(_photoURL),
        height: 200,
        width: 200,
        fit: BoxFit.fitWidth);
  }
}

class MealView extends StatefulWidget {
  final Meal meal;
  @override
  MealViewState createState() => new MealViewState(meal);
  MealView(@required this.meal) : super();
}
