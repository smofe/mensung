import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mensa_rating_app/main.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class AuthenticationViewState extends State<AuthenticationView> {
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Sign in')),
      body: Container(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/logo.png'),
              ),
              Padding(
                padding: EdgeInsets.only(top: 40.0),
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: new InputDecoration(
                    labelText: "Enter Email",
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0))),
                controller: _emailController,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
              ),
              TextFormField(
                obscureText: true,
                decoration: new InputDecoration(
                    labelText: "Enter Password",
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0))),
                controller: _passwordController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    child: Text("Register"),
                    onPressed: () => _registerWithEmail(),
                  ),
                  TextButton(
                    child: Text("Sign in"),
                    onPressed: () => _signInWithEmail(),
                  ),
                ],
              ),
              TextButton(
                child: Text("Continue as guest"),
                style: TextButton.styleFrom(primary: Colors.grey),
                onPressed: () => _signInAnonymously(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _registerWithEmail() async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MealOverview()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: new Text('The password provided is too weak.'),
        ));
      } else if (e.code == 'email-already-in-use') {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: new Text('The account already exists for that email'),
        ));
      }
    } catch (e) {
      print(e);
    }

  }

  void _signInWithEmail() async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MealOverview()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: new Text('No user with that email found.'),
        ));
      } else if (e.code == 'wrong-password') {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: new Text('Wrong password provided for that user.'),
        ));
      }
    }
  }

  void _signInAnonymously() async {
    UserCredential userCredential = await auth.signInAnonymously();
    print(userCredential);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MealOverview()));
  }
}

class AuthenticationView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AuthenticationViewState();
}
