import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crimemap/model/app_state.dart';
import 'package:crimemap/model/location.dart';
import 'package:crimemap/redux/actions.dart';
import 'package:crimemap/util/helper_functions.dart';
import 'package:crimemap/util/config_reader.dart';
import 'package:crimemap/util/strings.dart';
import 'package:crimemap/util/color_constants.dart';
import 'package:crimemap/util/size_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class MapPage extends StatelessWidget {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  static const LatLng _center = const LatLng(0, 0);
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: ConfigReader.getGoogleApiKey());
  CollectionReference fireStorePlaces = Firestore.instance.collection('places');

  void addMarkerToMarkerList(BuildContext context, double lat, double lng,
      AppState state, int crimesReported) async {
    BitmapDescriptor markerIcon;
    if (crimesReported > 0 && crimesReported < 5) {
      markerIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    } else if (crimesReported > 5 && crimesReported < 20) {
      markerIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    } else if (crimesReported > 20) {
      markerIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
    Marker marker = Marker(
        markerId: MarkerId("marker_id_${state.markerIdCounter++}"),
        position: LatLng(lat, lng),
        visible: true,
        alpha: 1.0,
        infoWindow: InfoWindow(
            title: "Crimes reported", snippet: crimesReported.toString()),
        icon: markerIcon);
    StoreProvider.of<AppState>(context).dispatch(MapMarkerAction(marker));
    StoreProvider.of<AppState>(context)
        .dispatch(MarkerIdAction(state.markerIdCounter++));
  }

  void animateCameraPosition(double lat, double lng, double zoom) {
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
          return WillPopScope(
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
                  StreamBuilder(
                    stream: fireStorePlaces.snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        for (var locatn in snapshot.data.documents) {
                          addMarkerToMarkerList(context, locatn['lat'],
                              locatn['lng'], state, locatn['crimes_reported']);
                        }
                      }

                      return Container();
                    },
                  ),
                  Container(
                    child: GoogleMap(
                      initialCameraPosition:
                          CameraPosition(target: _center, zoom: 5.0),
                      mapType: MapType.normal,
                      onMapCreated: (GoogleMapController controller) async {
                        mapController = controller;
                        _controller.complete(controller);
                        StoreProvider.of<AppState>(context)
                            .dispatch(IsLoadingAction(true));
                        await getCurrentLocation(context).then((value) {
                          if (value != null) {
                            StoreProvider.of<AppState>(context)
                                .dispatch(CurrentLocationAction(value));

                            animateCameraPosition(value.lat, value.lng, 14);
                          }
                        });
                        StoreProvider.of<AppState>(context)
                            .dispatch(IsLoadingAction(false));
                      },
                      markers: Set<Marker>.of(getMapMarkers(state)),
                      zoomControlsEnabled: false,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 90.0, bottom: 90),
                      child:
                          state.isLoading ? CircularProgressIndicator() : null,
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
                      : null,
                  !state.showSearch
                      ? Container(
                          alignment: Alignment.topCenter,
                          color: Colors.black26,
                          height: 150,
                          child: Align(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(app_name,
                                  style: GoogleFonts.bevan(
                                      fontSize: fontSize32,
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic)),
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                        )
                      : Center(
                          child: Container(
                            decoration: BoxDecoration(
                                color: appMainColor.withOpacity(0.5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            margin: EdgeInsets.symmetric(horizontal: padding5),
                            child: Wrap(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.spaceEvenly,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: <Widget>[
                                Container(
                                  height: padding60,
                                ),
                                Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          EdgeInsets.only(right: padding15),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText:
                                              state.searchedLocation == null ||
                                                      state
                                                          .searchedLocation
                                                          .prediction
                                                          .description
                                                          .isEmpty
                                                  ? search_location
                                                  : state.searchedLocation
                                                      .prediction.description,
                                          fillColor: Color.fromARGB(
                                              255, 255, 255, 255),
                                          filled: true,
                                        ),
                                        onTap: () async {
                                          Prediction p =
                                              await PlacesAutocomplete.show(
                                                  context: context,
                                                  apiKey: ConfigReader
                                                      .getGoogleApiKey(),
                                                  mode: Mode.overlay,
                                                  language: "en",
                                                  components: [
                                                new Component(
                                                    Component.country,
                                                    state.currentLocation
                                                        .countryISO)
                                              ]);
                                          if (p != null) {
                                            PlacesDetailsResponse details =
                                                await _places
                                                    .getDetailsByPlaceId(
                                                        p.placeId);

                                            CrimeAppLocation current =
                                                new CrimeAppLocation();
                                            current.prediction = p;
                                            current.lat = details
                                                .result.geometry.location.lat;
                                            current.lng = details
                                                .result.geometry.location.lng;
                                            StoreProvider.of<AppState>(context)
                                                .dispatch(
                                                    SearchedLocationAction(
                                                        current));
                                            animateCameraPosition(
                                                details.result.geometry.location
                                                    .lat
                                                    .toDouble(),
                                                details.result.geometry.location
                                                    .lng
                                                    .toDouble(),
                                                15.0);
                                            addMarkerToMarkerList(
                                                context,
                                                details.result.geometry.location
                                                    .lat
                                                    .toDouble(),
                                                details.result.geometry.location
                                                    .lat
                                                    .toDouble(),
                                                state,
                                                null);
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
                                  padding: EdgeInsets.only(top: padding150),
                                ),
                                state.isLoading
                                    ? Container(
                                        child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          CircularProgressIndicator(),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(top: padding5),
                                          ),
                                          Text(
                                            "Reporting",
                                            style: GoogleFonts.lato(),
                                          )
                                        ],
                                      ))
                                    : Column(
                                        children: <Widget>[
                                          Text(
                                            report_crime,
                                            style: GoogleFonts.lato(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(top: padding15),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              RaisedButton(
                                                elevation: 20,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                color: Colors.white,
                                                onPressed: () {
                                                  StoreProvider.of<AppState>(
                                                          context)
                                                      .dispatch(IsLoadingAction(
                                                          true));
                                                  if (state.currentLocation !=
                                                      null) {
                                                    fireStorePlaces
                                                        .document(state
                                                            .currentLocation
                                                            .roughid)
                                                        .get()
                                                        .then((DocumentSnapshot
                                                            value) {
                                                      if (value.exists) {
                                                        fireStorePlaces
                                                            .document(state
                                                                .currentLocation
                                                                .roughid)
                                                            .updateData({
                                                          'crimes_reported':
                                                              FieldValue
                                                                  .increment(1),
                                                          'name': state
                                                              .currentLocation
                                                              .roughname,
                                                          'lat': state
                                                              .currentLocation
                                                              .lat,
                                                          'lng': state
                                                              .currentLocation
                                                              .lng
                                                        }).then((value) {
                                                          StoreProvider.of<
                                                                      AppState>(
                                                                  context)
                                                              .dispatch(
                                                                  IsLoadingAction(
                                                                      false));
                                                          showSuccessToast(
                                                              context);
                                                        });
                                                      } else {
                                                        fireStorePlaces
                                                            .document(state
                                                                .currentLocation
                                                                .roughid)
                                                            .setData({
                                                          'crimes_reported':
                                                              FieldValue
                                                                  .increment(1),
                                                          'name': state
                                                              .currentLocation
                                                              .roughname,
                                                          'lat': state
                                                              .currentLocation
                                                              .lat,
                                                          'lng': state
                                                              .currentLocation
                                                              .lng
                                                        }).then((value) {
                                                          StoreProvider.of<
                                                                      AppState>(
                                                                  context)
                                                              .dispatch(
                                                                  IsLoadingAction(
                                                                      false));
                                                          showSuccessToast(
                                                              context);
                                                        });
                                                      }
                                                    });
                                                  } else {
                                                    StoreProvider.of<AppState>(
                                                            context)
                                                        .dispatch(
                                                            IsLoadingAction(
                                                                false));
                                                    showFailToast(context);
                                                  }
                                                },
                                                child:
                                                    Text(use_current_location),
                                              ),
                                              RaisedButton(
                                                elevation: 20,
                                                color: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                onPressed: () {
                                                  StoreProvider.of<AppState>(
                                                          context)
                                                      .dispatch(IsLoadingAction(
                                                          true));
                                                  if (state.searchedLocation !=
                                                      null) {
                                                    fireStorePlaces
                                                        .document(state
                                                            .searchedLocation
                                                            .prediction
                                                            .placeId)
                                                        .get()
                                                        .then((DocumentSnapshot
                                                            value) {
                                                      if (value.exists) {
                                                        fireStorePlaces
                                                            .document(state
                                                                .searchedLocation
                                                                .prediction
                                                                .placeId)
                                                            .updateData({
                                                          'crimes_reported':
                                                              FieldValue
                                                                  .increment(1),
                                                          'name': state
                                                              .searchedLocation
                                                              .prediction
                                                              .description,
                                                          'lat': state
                                                              .searchedLocation
                                                              .lat,
                                                          'lng': state
                                                              .searchedLocation
                                                              .lng
                                                        }).then((value) {
                                                          StoreProvider.of<
                                                                      AppState>(
                                                                  context)
                                                              .dispatch(
                                                                  IsLoadingAction(
                                                                      false));
                                                          showSuccessToast(
                                                              context);
                                                        });
                                                      } else {
                                                        fireStorePlaces
                                                            .document(state
                                                                .searchedLocation
                                                                .prediction
                                                                .placeId)
                                                            .setData({
                                                          'crimes_reported':
                                                              FieldValue
                                                                  .increment(1),
                                                          'name': state
                                                              .searchedLocation
                                                              .prediction
                                                              .description,
                                                          'lat': state
                                                              .searchedLocation
                                                              .lat,
                                                          'lng': state
                                                              .searchedLocation
                                                              .lng
                                                        }).then((value) {
                                                          StoreProvider.of<
                                                                      AppState>(
                                                                  context)
                                                              .dispatch(
                                                                  IsLoadingAction(
                                                                      false));
                                                          showSuccessToast(
                                                              context);
                                                        });
                                                      }
                                                    });
                                                  } else {
                                                    StoreProvider.of<AppState>(
                                                            context)
                                                        .dispatch(
                                                            IsLoadingAction(
                                                                false));
                                                    showFailToast(context);
                                                  }
                                                },
                                                child: Text(report),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                Container(
                                  height: padding15,
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
          );
        });
  }

  getMapMarkers(AppState state) {
    return state.markers.values;
  }

  showSuccessToast(BuildContext context) {
    Fluttertoast.showToast(
        msg: "Crime Reported",
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
        gravity: ToastGravity.BOTTOM);
    StoreProvider.of<AppState>(context).dispatch(ShowSearchAction(false));
  }

  showFailToast(BuildContext context) {
    Fluttertoast.showToast(
        msg: "Please provide a location before submitting",
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
        gravity: ToastGravity.BOTTOM);
  }
}
