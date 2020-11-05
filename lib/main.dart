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
   static List<Meal> UserMealList = [];

   void _getMealsFromUser() async {
     List mealList = await FirebaseFirestore.instance.collection('meal').get().then((value) => value.docs);
     UserMealList = [];
     for (int i=0; i < mealList.length; i++){
       String mealDocId = mealList[i].documentID.toString();
       //FirebaseFirestore.instance.collection("meal").doc(mealDocId).collection("user").snapshots().listen(_createListOfMeals);
       FirebaseFirestore.instance.collection("meal").doc(mealDocId).collection("user").snapshots().forEach((element) {
         var docs = element.docs;
         for (var d in docs) {
           /*print("Meal: " + mealDocId + " | " + (auth.currentUser.uid == d.get("uid")).toString() );
           print("Meal: " + mealDocId + " | current user: " + auth.currentUser.uid + " | meal user: " + d.get("uid")); */
           //FirebaseFirestore.instance.collection("meal").doc(mealDocId).snapshots().first);
           if (auth.currentUser.uid == d.get("uid")) {
               UserMealList.add(Meal.fromSnapshot(mealList[i]));
           }
         }
       });
     }
   }

   Widget _buildBody(BuildContext context) {
     _getMealsFromUser();
     print(UserMealList);
     return ListView.builder(
         padding: const EdgeInsets.all(8),
         itemCount: UserMealList.length,
         itemBuilder: (BuildContext context, int index) {
           Meal meal = UserMealList[index];
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
     );
     /*return StreamBuilder<QuerySnapshot>(
         stream: FirebaseFirestore.instance.collection('meal').snapshots(),
         builder: (context, snapshot) {
           if (!snapshot.hasData) return LinearProgressIndicator();
           return _buildMealList(context, snapshot.data.docs);
         }
     ); */
   }

  Widget _buildMealList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {

     Future<bool> _hasUserRatedThisMeal() async {
       var all_meals = FirebaseFirestore.instance.collection('meal');
       var current_meal = await all_meals.doc(data.id).get();
       var current_meal_users = await current_meal.reference.collection('user').get();
       bool user_found = false;
       current_meal_users.docs.forEach((element) {
         user_found = true;
        });
       return user_found;
     }
  //print("logging..." + data.data().toString());
     final meal = Meal.fromSnapshot(data);
     /*_hasUserRatedThisMeal().then((value) {
       print("query complete");
       if (!value) {
         print("user not found");
         return Padding(
           padding: const EdgeInsets.all(0.0),
         );
       }
     }); */
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
        UserMealList.add(result);
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
