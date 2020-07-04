import 'dart:async';
import 'package:crimemap/model/app_state.dart';
import 'package:crimemap/model/location.dart';
import 'package:crimemap/util/colorconstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  static const LatLng _center = const LatLng(45.521563, -122.677433);
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Location location = new Location();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: whiteBackGround,
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
                    zoomControlsEnabled: false,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: FloatingActionButton(
                      elevation: 5,
                      onPressed: () {
                        print("add pressed");
                      },
                      child: Icon(Icons.add),
                    ),
                  ),
                )
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
