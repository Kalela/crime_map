import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class ShowRegisterAction {
  final bool payload;

  ShowRegisterAction(this.payload);
}

class IsLoadingAction {
  final bool payload;

  IsLoadingAction(this.payload);
}

class FirebaseUserAction {
  final FirebaseUser payload;

  FirebaseUserAction(this.payload);
}

class MapMarkerAction {
  final Marker payload;

  MapMarkerAction(this.payload);
}

class CurrentLocationAction {
  Position payload;

  CurrentLocationAction(this.payload);
}

class ShowSearchAction {
  bool payload;

  ShowSearchAction(this.payload);
}

class SearchedLocationAction {
  Prediction payload;

  SearchedLocationAction(this.payload);
}
