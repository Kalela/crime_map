import 'dart:async';
import 'dart:ui';
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
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class MapPage extends StatelessWidget {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  static const LatLng _center = const LatLng(45.521563, -122.677433);
  CrimeAppLocation location;

  BitmapDescriptor mapIcon;

  Future<BitmapDescriptor> getIconBitMap() async {
    final iconData = Icons.location_on;
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final iconStr = String.fromCharCode(iconData.codePoint);
    textPainter.text = TextSpan(
        text: iconStr,
        style: TextStyle(
          letterSpacing: 0.0,
          fontSize: 48.0,
          fontFamily: iconData.fontFamily,
          color: Colors.red,
        ));
    textPainter.layout();
    textPainter.paint(canvas, Offset(0.0, 0.0));
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(48, 48);
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    final bitmapDescriptor =
        BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());

    return bitmapDescriptor;
  }

  void addMarkerToMarkerList(
      BuildContext context, double lat, double lng, String placeid) async {
    Marker marker = Marker(
      markerId: MarkerId(placeid),
      position: LatLng(lat, lng),
      icon: mapIcon,
    );
    StoreProvider.of<AppState>(context).dispatch(MapMarkerAction(marker));
  }

  void animateCameraPosition(
      double lat, double lng, double zoom) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lng),
      zoom: zoom,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return StatefulWrapper(
            onInit: () {
              getIconBitMap().then((value) {
                this.mapIcon = value;
              });
              print(mapIcon);
            },
            child: WillPopScope(
              onWillPop: () {
                if (state.showSearch) {
                  StoreProvider.of<AppState>(context)
                      .dispatch(ShowSearchAction(false));
                }
              },
              child: Scaffold(
                resizeToAvoidBottomInset: true,
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
                          try {
                            getCurrentLocation(context).then((value) {
                              print(
                                  "current location state ${state.currentLocation}");
                              location = state.currentLocation;
                              animateCameraPosition(
                                  location.lat, location.lng, 14);
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        markers: state.markers,
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
                            color: appMainColor.withOpacity(0.5),
                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.only(top: padding150),
                            child: Column(
                              children: <Widget>[
                                Text(report_crime),
                                Padding(
                                  padding: EdgeInsets.only(top: padding15),
                                ),
                                Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText:
                                              state.searchedLocation == null ||
                                                      state.searchedLocation
                                                          .description.isEmpty
                                                  ? search_location
                                                  : state.searchedLocation
                                                      .description,
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
                                            StoreProvider.of<AppState>(context)
                                                .dispatch(
                                                    SearchedLocationAction(p));
                                            var addresses = await Geocoder.local
                                                .findAddressesFromQuery(
                                                    p.description);
                                            var first = addresses.first;
                                            animateCameraPosition(
                                                first.coordinates.latitude
                                                    .toDouble(),
                                                first.coordinates.longitude
                                                    .toDouble(),
                                                15.0);
                                            addMarkerToMarkerList(
                                                context,
                                                first.coordinates.latitude
                                                    .toDouble(),
                                                first.coordinates.latitude
                                                    .toDouble(),
                                                p.placeId);
                                          }
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(right: padding15),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: padding15),
                                ),
                                Text("OR"),
                                Padding(
                                  padding: EdgeInsets.only(top: padding5),
                                ),
                                RaisedButton(
                                  color: appMainColor,
                                  onPressed: () {
                                    print("report crime");
                                  },
                                  child: Text(use_current_location),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: padding150),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: RaisedButton(
                                    color: appMainColor,
                                    onPressed: () {
                                      print("report crime");
                                    },
                                    child: Text(report),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: padding15),
                                ),
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
}
