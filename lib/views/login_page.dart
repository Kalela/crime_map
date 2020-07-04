import 'package:crimemap/model/app_state.dart';
import 'package:crimemap/redux/actions.dart';
import 'package:crimemap/util/colorconstants.dart';
import 'package:crimemap/util/helper_functions.dart';
import 'package:crimemap/util/strings.dart';
import 'package:crimemap/views/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () {
            if (state.showRegister == true) {
              StoreProvider.of<AppState>(context)
                  .dispatch(ShowRegisterAction(false));
            } else {
              Navigator.pop(context);
            }
          },
          child: Scaffold(
              backgroundColor: whiteBackGround,
              body: Container(
                padding: EdgeInsets.only(top: 300),
                color: whiteBackGround,
                child: Center(
                    child: _signInButton(context)),
              )),
        );
      },
    );
  }

  Widget _signInButton(BuildContext context) {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        signInWithGoogle(_auth, googleSignIn).then((value) {
          if (value != null) {
            StoreProvider.of<AppState>(context)
                .dispatch(FirebaseUserAction(value));
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) {
                  return MapPage();
                },
              ),
            );
          }
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
