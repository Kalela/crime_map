import 'package:crimemap/model/app_state.dart';

AppState reducer(AppState prevState, dynamic action) {
  AppState newState = AppState.fromAppState(prevState);

  return newState;
}
