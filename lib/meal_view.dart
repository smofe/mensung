import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'meal.dart';

class MealView extends StatelessWidget {
  final Meal meal;

  MealView(@required this.meal) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meal Details')),
      body: Column(children: <Widget>[
        Text("Meal name:" + meal.name),
        Text("Meal rating:" + meal.rating.toString()),
        Text("Meal notes:" + meal.notes),
        Text("Meal eating on:" + meal.createdAt.toString()),
      ])
    );
  }

}
