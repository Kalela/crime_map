import 'package:crimemap/model/app_state.dart';
import 'package:crimemap/model/location.dart';
import 'package:crimemap/redux/actions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

AppState reducer(AppState prevState, dynamic action) {
  AppState newState = AppState.fromAppState(prevState);

  if (action is FirebaseUserAction) {
    newState.user = action.payload;
  } else if (action is IsLoadingAction) {
    newState.isLoading = action.payload;
  } else if (action is CurrentLocationAction) {
    newState.currentLocation = new CrimeAppLocation(action.payload.latitude, action.payload.longitude);
  } else if (action is ShowSearchAction) {
    newState.showSearch = action.payload;
  } else if (action is SearchedLocationAction) {
    newState.searchedLocation = action.payload;
  } else if (action is MapMarkerAction) {
    newState.markerIdConter += 1;
    newState.markers[MarkerId("marker_id_${newState.markerIdConter}")] = action.payload;
  }

  return newState;
}
