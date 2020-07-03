import 'package:firebase_auth/firebase_auth.dart';
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
  final List<Marker> payload;

  MapMarkersAction(this.payload);

}

class MapMarkerAction {
  final Marker payload;

  MapMarkerAction(this.payload);

}