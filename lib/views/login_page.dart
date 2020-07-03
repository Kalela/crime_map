import 'package:crimemap/model/app_state.dart';
import 'package:crimemap/redux/actions.dart';
import 'package:crimemap/util/global_app_constants.dart';
import 'package:crimemap/util/helper_functions.dart';
import 'package:crimemap/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
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
              backgroundColor: GlobalAppConstants.whiteBackGround,
              body: Container(
                color: GlobalAppConstants.whiteBackGround,
                child: Center(
                    child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 100),
                    ),
                    Text(
                      GlobalAppConstants.appName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Color.fromARGB(255, 111, 190, 11),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                    ),
                    state.showRegister
                        ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Form(
                              key: _registerFormKey,
                              child: Column(
                                children: <Widget>[
                                  Text("Register here"),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Username cannot be empty';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      // registerAppUser.username = value;
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Username",
                                      fillColor:
                                          Color.fromARGB(255, 255, 255, 255),
                                      filled: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                  ),
                                  TextFormField(
                                    validator: (value) => emailValidator(value),
                                    onSaved: (value) {
                                      // registerAppUser.email = value;
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Email",
                                      fillColor:
                                          Color.fromARGB(255, 255, 255, 255),
                                      filled: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Password cannot be empty';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      // registerAppUser.password = value;
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Password",
                                      fillColor:
                                          Color.fromARGB(255, 255, 255, 255),
                                      filled: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                  ),
                                  state.isLoading == false
                                      ? Material(
                                          elevation: 5,
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              // gradient: GlobalAppConstants
                                              //     .buttonGradient,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                if (_registerFormKey
                                                    .currentState
                                                    .validate()) {
                                                  _registerFormKey.currentState
                                                      .save();
                                                }
                                              },
                                              child: Container(
                                                height: 45,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 20.0),
                                                    ),
                                                    Text(
                                                      "Register",
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'Montesserat'),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 20.0),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : CircularProgressIndicator(),
                                  Padding(
                                    padding: EdgeInsets.only(top: 20),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text("Already have an account? "),
                                        Ink(
                                          child: InkWell(
                                            onTap: () {
                                              StoreProvider.of<AppState>(
                                                      context)
                                                  .dispatch(ShowRegisterAction(
                                                      false));
                                            },
                                            child: Text(
                                              "Log in",
                                              // style: TextStyle(
                                              //     color: GlobalAppConstants
                                              //         .appGreen),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Form(
                              key: _loginFormKey,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                  ),
                                  TextFormField(
                                    validator: (value) => emailValidator(value),
                                    onSaved: (value) {
                                      // loginAppUser.email = value;
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Email",
                                      fillColor:
                                          Color.fromARGB(255, 255, 255, 255),
                                      filled: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Password cannot be empty';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      // loginAppUser.password = value;
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Password",
                                      fillColor:
                                          Color.fromARGB(255, 255, 255, 255),
                                      filled: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                  ),
                                  state.isLoading == false
                                      ? Material(
                                          elevation: 5,
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              // gradient: GlobalAppConstants
                                              //     .buttonGradient,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                if (_loginFormKey.currentState
                                                    .validate()) {
                                                  _loginFormKey.currentState
                                                      .save();
                                                }
                                              },
                                              child: Container(
                                                height: 45,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 20.0),
                                                    ),
                                                    Text(
                                                      "Login",
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'Montesserat'),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 20.0),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : CircularProgressIndicator(),
                                  Padding(
                                    padding: EdgeInsets.only(top: 30),
                                  ),
                                  _signInButton(context),
                                  Padding(
                                    padding: EdgeInsets.only(top: 20),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                            "Don't have an account? No Problem. Go to "),
                                        Ink(
                                          child: InkWell(
                                            onTap: () {
                                              StoreProvider.of<AppState>(
                                                      context)
                                                  .dispatch(
                                                      ShowRegisterAction(true));
                                            },
                                            child: Text(
                                              "Sign Up",
                                              // style: TextStyle(
                                              //     color: GlobalAppConstants
                                              //         .appGreen),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                  ],
                )),
              )),
        );
      },
    );
  }

  emailValidator(value) {
    if (value.isEmpty) {
      return 'Email cannot be empty';
    }

    if (!value.contains("@") || !value.contains(".com")) {
      return 'Email provided is not a valid email';
    }

    return null;
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
                  return HomePage();
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
