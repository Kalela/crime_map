import 'package:firebase_auth/firebase_auth.dart';

class AppState {
  bool isLoading = false;
  bool showRegister = false;
  FirebaseUser user;

  AppState();

  AppState.fromAppState(AppState another) {
    isLoading = another.isLoading;
    showRegister = another.showRegister;
    user = another.user;
  }
}