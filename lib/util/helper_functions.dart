import 'package:crimemap/model/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<FirebaseUser> signInWithGoogle(_auth, googleSignIn) async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  return currentUser;
}

void signOutGoogle(googleSignIn) async {
  await googleSignIn.signOut();

  print("User Sign Out");
}

Future<CrimeAppLocation> getCurrentLocation(BuildContext context) async {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  CrimeAppLocation result = new CrimeAppLocation();

  await geolocator
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
      .then((Position position) {
        result.lat = position.latitude;
        result.lng = position.longitude;
        result.position = position;
  }).catchError((e) {
    print(e);
  });

  return result;
}
