import 'package:crimemap/model/app_state.dart';
import 'package:crimemap/model/location.dart';
import 'package:crimemap/redux/actions.dart';

AppState reducer(AppState prevState, dynamic action) {
  AppState newState = AppState.fromAppState(prevState);

  if (action is FirebaseUserAction) {
    newState.user = action.payload;
  } else if (action is IsLoadingAction) {
    newState.isLoading = action.payload;
  } else if (action is CurrentLocationAction) {
    newState.currentLocation = action.payload;
  } else if (action is ShowSearchAction) {
    newState.showSearch = action.payload;
  } else if (action is SearchedLocationAction) {
    newState.searchedLocation = action.payload;
  } else if (action is MapMarkerAction) {
    newState.markers[action.payload.markerId] = action.payload;
  } else if (action is MarkerIdAction) {
    newState.markerIdCounter = action.payload;
  } 

  return newState;
}
