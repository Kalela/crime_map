import 'package:crimemap/model/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

class MapMarkersAction {
  final Map<MarkerId, Marker> payload;

  MapMarkersAction(this.payload);

}

class CurrentLocationAction {
  Position payload;

  CurrentLocationAction(this.payload);
}

class ShowSearchAction {
  bool payload;

  ShowSearchAction(this.payload);
}