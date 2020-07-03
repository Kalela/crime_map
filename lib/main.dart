import 'package:crimemap/redux/reducers.dart';
import 'package:crimemap/util/global_app_constants.dart';
import 'package:crimemap/views/map_page.dart';
import 'package:crimemap/views/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'model/app_state.dart';

void main() {
  var appState = AppState();
  final _initialState = appState;
  final Store<AppState> _store =
      Store<AppState>(reducer, initialState: _initialState);
  runApp(CrimeMapApp(
    store: _store,
  ));
}

class CrimeMapApp extends StatelessWidget {
  final Store<AppState> store;
  CrimeMapApp({this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        theme: ThemeData(primaryColor: GlobalAppConstants.appMainColor),
        title: 'Crime Map',
        home: store.state.user == null ? LoginPage() : MapPage(),
      ),
    );
  }
}
