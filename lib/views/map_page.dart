import 'dart:async';
import 'package:crimemap/model/app_state.dart';
import 'package:crimemap/model/location.dart';
import 'package:crimemap/redux/actions.dart';
import 'package:crimemap/util/helper_functions.dart';
import 'package:crimemap/util/secrets.dart';
import 'package:crimemap/util/strings.dart';
import 'package:crimemap/util/widgets.dart';
import 'package:crimemap/util/color_constants.dart';
import 'package:crimemap/util/size_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class MapPage extends StatelessWidget {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  static const LatLng _center = const LatLng(45.521563, -122.677433);
  CrimeAppLocation location;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return StatefulWrapper(
            onInit: () async {
              try {
                await getCurrentLocation(context).then((value) {
                  // print("value $value");
                  print("current location state ${state.currentLocation}");
                  location = state.currentLocation;
                  animateCameraPosition(location.lat, location.lng, 14);
                });
              } catch (e) {
                print(e);
              }
            },
            child: WillPopScope(
              onWillPop: () {
                if (state.showSearch) {
                  StoreProvider.of<AppState>(context)
                      .dispatch(ShowSearchAction(false));
                }
              },
              child: Scaffold(
                backgroundColor: whiteBackGround,
                body: Stack(
                  children: <Widget>[
                    Container(
                      child: GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: _center, zoom: 10.0),
                        mapType: MapType.normal,
                        onMapCreated: (GoogleMapController controller) {
                          // controller.setMapStyle(_mapStyle);
                          mapController = controller;
                          _controller.complete(controller);
                        },
                        markers: Set<Marker>.of(state.markers.values),
                        zoomControlsEnabled: false,
                      ),
                    ),
                    !state.showSearch
                        ? Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: FloatingActionButton(
                                backgroundColor: appMainColor,
                                elevation: 5,
                                onPressed: () {
                                  StoreProvider.of<AppState>(context)
                                      .dispatch(ShowSearchAction(true));
                                },
                                child: Icon(Icons.add),
                              ),
                            ),
                          )
                        : Container(),
                    !state.showSearch
                        ? Container(
                            alignment: Alignment.topCenter,
                            color: Colors.black26,
                            height: 150,
                            child: Align(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  "Crime Alert",
                                  style: TextStyle(
                                      color: white, fontSize: fontSize32),
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                            ),
                          )
                        : Container(
                            color: Colors.white.withOpacity(0.5),
                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.only(top: padding150),
                            child: Column(
                              children: <Widget>[
                                Text(report_crime),
                                Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: search_location,
                                          fillColor: Color.fromARGB(
                                              255, 255, 255, 255),
                                          filled: true,
                                        ),
                                        onTap: () async {
                                          Prediction p =
                                              await PlacesAutocomplete.show(
                                                  context: context,
                                                  apiKey: googleApiKey,
                                                  mode: Mode.overlay,
                                                  language: "en",
                                                  components: [
                                                new Component(
                                                    Component.country, "ke")
                                              ]);
                                          if (p != null) {
                                            print(p.description);
                                          }
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 15.0),
                                    ),
                                  ],
                                ),
                                Text("OR"),
                                RaisedButton(
                                  color: appMainColor,
                                  onPressed: () {
                                    print("report crime");
                                  },
                                  child: Text(use_current_location),
                                )
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void addMarkerToMarkerList(
      double lat, double lng, BuildContext context, AppState state) {
    state.markers.clear();
    Marker marker = Marker(
        markerId: MarkerId('currentSelected'), position: LatLng(lat, lng));
    // setState(() {
    //   markers[marker.markerId] = marker;
    // });
  }

  void animateCameraPosition(lat, lng, zoom) async {
    print("I am here");
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lng),
      zoom: zoom,
    )));
  }
}
