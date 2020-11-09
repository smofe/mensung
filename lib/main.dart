import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mensa_rating_app/authentication_view.dart';
import 'package:mensa_rating_app/meal.dart';
import 'package:mensa_rating_app/meal_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'meal_input.dart';

FirebaseAuth auth = FirebaseAuth.instance;
final storage = firebase_storage.FirebaseStorage.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Mensa Rating Tracker', home: AuthenticationView());
  }
}

class MealOverviewState extends State<MealOverview> {
  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser.uid)
            .collection("meals")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return _buildMealList(context, snapshot.data.docs);
        });
  }

  Widget _buildMealList(BuildContext context, List<DocumentSnapshot> snapshot) {
    if (snapshot.length == 0) {
      return Center(
        child: Text('No meals added yet.'),
      );
    }
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
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
      child: Dismissible(
        background: Container(color: Colors.red),
        key: ValueKey(meal.name),
        onDismissed: (direction) {
          meal.deleteReference();

          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('$meal dismissed'),
            action: SnackBarAction(
              label: "UNDO",
              onPressed: () => meal.safeReference(),
            ),
          ));
        },
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: _mealPhoto(context, meal)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mensa Meal Ratings'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _handleMenuClick,
            itemBuilder: (BuildContext context) {
              return {
                'Logout',
              }.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMeal,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addNewMeal() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MealInput())).then((value) {
          print(value);
          setState(() {

          });
    });
  }

  void _handleMenuClick(String value) {
    switch (value) {
      case 'Logout':
        _logout();
    }
  }

  void _logout() async {
    await auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => AuthenticationView()));
  }

  void _viewMeal(Meal meal) async {
    print(meal.notes);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MealView(meal)));
  }

  Future<String> _downloadPhoto(String mealID) async {
    String userID = auth.currentUser.uid;
    final ref = storage.ref('users/$userID/meals/$mealID.png');

    return await ref.getDownloadURL().catchError((error) {
      return null;
    });
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }

  Widget _mealPhoto(BuildContext context, Meal meal) {
    return Stack(alignment: Alignment.bottomCenter, children: <Widget>[
      GestureDetector(
          onTap: () => _viewMeal(meal),
          child: FutureBuilder(
              future: _downloadPhoto(meal.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return CachedNetworkImage(
                    imageUrl: snapshot.data,
                    width: 200,
                    height: 200,
                    fit: BoxFit.fitWidth,
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else
                  return Image(
                    image: AssetImage('assets/mealplate.png'),
                    width: 200,
                    height: 200,
                  );
              })),
      Text(meal.name)
    ]);
  }
}

class MealOverview extends StatefulWidget {
  @override
  MealOverviewState createState() => new MealOverviewState();
}
