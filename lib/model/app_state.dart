import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

import 'location.dart';

class AppState {
  bool isLoading = false;
  bool showSearch = false;
  FirebaseUser user;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int markerIdCounter = 0;
  CrimeAppLocation currentLocation;
  Prediction searchedLocation;

  AppState();

  AppState.fromAppState(AppState another) {
    isLoading = another.isLoading;
    user = another.user;
    markers = another.markers;
    currentLocation = another.currentLocation;
    showSearch = another.showSearch;
    searchedLocation = another.searchedLocation;
    markerIdCounter = another.markerIdCounter;
  }
}