import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppState {
  bool isLoading = false;
  bool showRegister = false;
  FirebaseUser user;
  List<Marker> markers;

  AppState();

  AppState.fromAppState(AppState another) {
    isLoading = another.isLoading;
    showRegister = another.showRegister;
    user = another.user;
    markers = another.markers;
  }
}