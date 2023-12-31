import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:skanmed/pages/sos.dart';
import 'package:url_launcher/url_launcher.dart';

class MapDisp extends StatefulWidget {
  const MapDisp({super.key});

  @override
  State<MapDisp> createState() => _MapDispState();
}

class _MapDispState extends State<MapDisp> {
  List<Marker> markers = [];
  late List pos;
  late List speciality;
  late bool isAvailable;
  late String number;
  TextStyle hospitalStyle = GoogleFonts.poppins(
    fontWeight: FontWeight.bold,
    fontSize: 18,
    color: Colors.black,
  );
  void initState() {
    super.initState();
    // _determinePosition();
    _setLocation();
  }

  bool _isHospitalSelected = false;
  final user = FirebaseAuth.instance.currentUser!;

  //Map<String, dynamic>?
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  initMarker(request) {
    var p = request['lat'];
    var markerIdVal = request['name'];
    bool isPresent = request['isPresent'];
    var mobile = request['number'];
    var specialities = request['specialities'];
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
      onTap: () {
        setState(() {
          _isHospitalSelected = !_isHospitalSelected;
          _hospitalSelected = markerIdVal;
          pos = p;
          isAvailable = isPresent;
          number = mobile;
          speciality = specialities;
        });
      },
      icon: isPresent
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
          : BitmapDescriptor.defaultMarker,
      markerId: markerId,
      position: LatLng(p[0], p[1]),
      // infoWindow: InfoWindow(
      //   title: request['name'],
      //   onTap: () {
      //     launchUrl(Uri.parse("google.navigation:q=${p[0]},${p[1]}"));
      //     setState(() {
      //       _isHospitalSelected = !_isHospitalSelected;
      //       _hospitalSelected = markerIdVal;
      //     });
      //   },
      // ),
    );
    setState(() {
      _markers[markerId] = marker;
    });
  }

  Future _populateMarks() async {
    FirebaseFirestore.instance
        .collection('hospitals')
        .get()
        .then((value) => value.docs.forEach((element) {
              initMarker(element);
            }));
  }

  String _hospitalSelected = '';

  Completer<GoogleMapController> _controller = Completer();

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      var snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'An Error Occurred',
          message:
              'Location Services are disabled.\nPlease try Again with location enabled',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  void _setLocation() async {
    Position position = await _determinePosition();
    final GoogleMapController controller = await _controller.future;
    await _populateMarks();
    //print(_hospitalData);
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
          position.latitude,
          position.longitude,
        ),
        zoom: 14.4746)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SOSPage()));
        },
        label: Text("SOS"),
        icon: Icon(Icons.emergency_outlined),
        backgroundColor: Colors.red,
      ),
      body: Stack(alignment: Alignment.bottomCenter, children: [
        GoogleMap(
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          markers: Set.of(_markers.values),
          mapType: MapType.normal,
          myLocationButtonEnabled: false,
          initialCameraPosition: CameraPosition(
            target: LatLng(143.2, 154.78),
            zoom: 14.4746,
          ),
          onMapCreated: (GoogleMapController controller) async {
            _controller.complete(controller);
          },
        ),
        if (_isHospitalSelected)
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Container(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_hospitalSelected}",
                          style: hospitalStyle,
                        ),
                        SizedBox(height: 10),
                        isAvailable
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Emergency available',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                  Spacer(),
                                  Icon(
                                    FlutterRemix.check_fill,
                                    color: Colors.green,
                                  ),
                                  Spacer(flex: 6),
                                  IconButton(
                                    onPressed: () {
                                      launchUrl(Uri.parse("tel:${number}"));
                                    },
                                    icon: Icon(
                                      FlutterRemix.phone_fill,
                                      size: 36,
                                    ),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      launchUrl(Uri.parse(
                                          "google.navigation:q=${pos[0]},${pos[1]}"));
                                    },
                                    icon: Icon(
                                      FlutterRemix.compass_discover_fill,
                                      size: 36,
                                    ),
                                  ),
                                  // Spacer(flex:1),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Emergency unavailable',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  Spacer(),
                                  Icon(
                                    FlutterRemix.close_fill,
                                    color: Colors.red,
                                  ),
                                  Spacer(flex: 6),
                                  IconButton(
                                    onPressed: () {
                                      launchUrl(Uri.parse("tel:${number}"));
                                    },
                                    icon: Icon(
                                      FlutterRemix.phone_fill,
                                      size: 36,
                                    ),
                                  ),

                                  Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      launchUrl(Uri.parse(
                                          "google.navigation:q=${pos[0]},${pos[1]}"));
                                    },
                                    icon: Icon(
                                      FlutterRemix.compass_discover_fill,
                                      size: 36,
                                    ),
                                  ),
                                  // Spacer(flex:1),
                                ],
                              ),
                        Text('Specialities:'),
                        Expanded(
                          child: GridView.count(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            childAspectRatio: 3,
                            crossAxisCount: 2,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: speciality[0]
                                          ? Colors.green[100]
                                          : Colors.red[100]),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('ICU',
                                            style: TextStyle(
                                                color: speciality[0]
                                                    ? Colors.green
                                                    : Colors.red)),
                                        Icon(
                                            speciality[0]
                                                ? FlutterRemix.check_fill
                                                : FlutterRemix.close_fill,
                                            color: speciality[0]
                                                ? Colors.green
                                                : Colors.red)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: speciality[1]
                                          ? Colors.green[100]
                                          : Colors.red[100]),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Cardiology',
                                            style: TextStyle(
                                                color: speciality[1]
                                                    ? Colors.green
                                                    : Colors.red)),
                                        Icon(
                                            speciality[1]
                                                ? FlutterRemix.check_fill
                                                : FlutterRemix.close_fill,
                                            color: speciality[1]
                                                ? Colors.green
                                                : Colors.red)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: speciality[2]
                                          ? Colors.green[100]
                                          : Colors.red[100]),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Chemotherapy',
                                            style: TextStyle(
                                                color: speciality[2]
                                                    ? Colors.green
                                                    : Colors.red)),
                                        Icon(
                                            speciality[2]
                                                ? FlutterRemix.check_fill
                                                : FlutterRemix.close_fill,
                                            color: speciality[2]
                                                ? Colors.green
                                                : Colors.red)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: speciality[3]
                                          ? Colors.green[100]
                                          : Colors.red[100]),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Isolation Ward',
                                            style: TextStyle(
                                                color: speciality[3]
                                                    ? Colors.green
                                                    : Colors.red)),
                                        Icon(
                                            speciality[3]
                                                ? FlutterRemix.check_fill
                                                : FlutterRemix.close_fill,
                                            color: speciality[3]
                                                ? Colors.green
                                                : Colors.red)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(height: 50)
                      ],
                    ),
                  ),
                ),
              )),
      ]),
    );
  }
}
