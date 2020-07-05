import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'location.dart';

class AppState {
  bool isLoading = false;
  bool showSearch = false;
  FirebaseUser user;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  CrimeAppLocation currentLocation;

  AppState();

  AppState.fromAppState(AppState another) {
    isLoading = another.isLoading;
    user = another.user;
    markers = another.markers;
    currentLocation = another.currentLocation;
    showSearch = another.showSearch;
  }
}