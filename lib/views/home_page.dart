import 'package:crimemap/model/app_state.dart';
import 'package:crimemap/util/global_app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: GlobalAppConstants.whiteBackGround,
          );
        });
  }
}
