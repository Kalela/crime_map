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
    print("reducer payload ${action.payload}");
    newState.currentLocation = new Location(action.payload.latitude, action.payload.longitude);
  }

  return newState;
}
