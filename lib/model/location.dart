import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';

class CrimeAppLocation {
  var lat;
  var lng;
  Prediction prediction;
  Position position;
  String countryISO = "ke";
  String roughname = "Unknown";
  String roughid = "rough_id";

  CrimeAppLocation();
}
