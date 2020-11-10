import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'meal.dart';

class MealViewState extends State<MealView> {
  final dbRef = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final storage = firebase_storage.FirebaseStorage.instance;
  final dateFormat = DateFormat("dd-MM-yy");
  final Meal meal;
  String _photoURL;

  MealViewState(@required this.meal);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Meal Details')),
        body: Column(children: <Widget>[
          SizedBox(height: 10),
          Text(
            meal.name,
            style: Theme.of(context).textTheme.headline5,
            textAlign: TextAlign.center,
          ),
          Center(child: _mealPhoto(context)),
          SizedBox(height: 10),
          SizedBox(height: 10),
          Text(meal.notes == '' ? 'No notes for this meal.' : meal.notes),
          SizedBox(height: 10),
          Text(dateFormat.format(meal.createdAt.toDate()),
              style: Theme.of(context).textTheme.caption),
          Spacer(),
          RatingBarIndicator(
            rating: meal.rating,
            direction: Axis.horizontal,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 8.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            unratedColor: Colors.grey,
          ),
          SizedBox(height: 10),
        ]));
  }

  Future<String> _downloadPhoto() async {
    String userID = auth.currentUser.uid;
    String mealID = meal.id;
    final ref = storage.ref('users/$userID/meals/$mealID.png');

    return await ref.getDownloadURL();
  }

  Widget _mealPhoto(BuildContext context) {
    _downloadPhoto().then((value) => setState(() {
          _photoURL = value.toString();
          print(_photoURL);
        }));

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image(
            image: _photoURL == null
                ? AssetImage('assets/mealplate.png')
                : NetworkImage(_photoURL),
            fit: BoxFit.fitWidth),
      ),
    );
  }
}

class MealView extends StatefulWidget {
  final Meal meal;
  @override
  MealViewState createState() => new MealViewState(meal);
  MealView(@required this.meal) : super();
}
