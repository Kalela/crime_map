import 'package:firebase_auth/firebase_auth.dart';

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