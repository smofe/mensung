import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mensa_rating_app/authentication_view.dart';
import 'package:mensa_rating_app/meal.dart';
import 'package:mensa_rating_app/meal_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'meal_input.dart';

FirebaseAuth auth = FirebaseAuth.instance;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Mensa Rating Tracker', home: AuthenticationView());
  }
}

class MealOverviewState extends State<MealOverview> {
  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(auth.currentUser.uid).collection("meals").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return _buildMealList(context, snapshot.data.docs);
        }
    );
  }

  Widget _buildMealList(BuildContext context, List<DocumentSnapshot> snapshot) {
    if (snapshot.length == 0) {
      return Center(
        child: Text('No meals added yet.'),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    var meal = Meal.fromSnapshot(data);
    meal.id = data.id;
    return Padding(
      key: ValueKey(meal.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(meal.name),
          trailing: Text(meal.rating.toString()),
          onTap: () => _viewMeal(meal),
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mensa Meal Ratings')),
      body: _buildBody(context),
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
        //UserMealList.add(result);
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
