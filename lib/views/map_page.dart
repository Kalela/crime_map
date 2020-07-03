import 'dart:async';
import 'package:crimemap/model/app_state.dart';
import 'package:crimemap/model/location.dart';
import 'package:crimemap/util/global_app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  static const LatLng _center = const LatLng(45.521563, -122.677433);
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Location locationLatLng = new Location();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: GlobalAppConstants.whiteBackGround,
            body: Stack(
              children: <Widget>[
                Container(
                child: GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _center, zoom: 1.0),
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    // controller.setMapStyle(_mapStyle);
                    mapController = controller;
                    _controller.complete(controller);
                  },
                  markers: Set<Marker>.of(markers.values),
                ),
              ),
              ],
            ),
          );
        });
  }

  void addMarkerToMarkerList(double lat, double lng, BuildContext context) {
    markers.clear();
    Marker marker = Marker(
        markerId: MarkerId('currentSelected'), position: LatLng(lat, lng));
    // setState(() {
    //   markers[marker.markerId] = marker;
    // });
  }

  void resetCameraPosition() {
    markers.clear();
    animateCameraPosition(_center.latitude, _center.longitude, 1.0);
  }

  void animateCameraPosition(lat, lng, zoom) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lng),
      zoom: zoom,
    )));
  }
}
