import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mensa_rating_app/meal.dart';
import 'package:mensa_rating_app/meal_view.dart';

import 'meal_input.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Mensa Rating Tracker', home: MealOverview());
  }
}

class MealOverviewState extends State<MealOverview> {
   var _meals = <Meal>[];

  Widget _buildMealList() {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: _meals.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
            color: Colors.amber[200],
            child: ListTile(
              title: Text(_meals[index].name),
              trailing: Text('Rating: ' + _meals[index].rating.toString()),
              onTap: () => _viewMeal(_meals[index]),
            ),);
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mensa Meal Ratings')),
      body: _buildMealList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMeal,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addNewMeal() async {
    final result = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => MealInput()));
    if (result != null) {
      setState(() {
        _meals.add(result);
      });
    }
  }

   void _viewMeal(Meal meal) async {
    print(meal.notes);
     final result = await Navigator.push(
         context, MaterialPageRoute(builder: (context) => MealView(meal)));
     }
   }


class MealOverview extends StatefulWidget {
  @override
  MealOverviewState createState() => new MealOverviewState();
}
