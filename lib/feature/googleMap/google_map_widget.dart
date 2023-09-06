import 'dart:async';

import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../widgets/map_action_button.dart';
import 'cordinates.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({super.key});

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static double lat = 1;
  static double long = 1;
  static double initialLat = 1;
  static double initialLong =1;

  final Set<Polyline> _polyline = {};
  List<LatLng> latLngListForPolyline = [];

  // BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  Uint8List? markerIcon;
  Uint8List? startMarkerIcon;

  // 19.010274, 72.832725
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(lat, long),
    zoom: 16,
  );

  List<Marker> markers = [
    Marker(
        markerId: const MarkerId('1'),
        position: LatLng(lat, long),
        infoWindow: const InfoWindow(title: 'My Location'))
  ];

  @override
  void initState() {
    fetchInitialLocationFromDB();
    // addCustomIcon();
    resizeMarker();
    super.initState();
  }

  // void addCustomIcon() {
  //   BitmapDescriptor.fromAssetImage(
  //        ImageConfiguration(size: Size(10,10)), "assets/icons/car1.png",)
  //       .then(
  //         (icon) {
  //       setState(() {
  //         // markerIcon = icon;
  //       });
  //     },
  //   );
  // }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  resizeMarker() async {
    markerIcon = await getBytesFromAsset('assets/icons/car1.png', 150);
    startMarkerIcon =
        await getBytesFromAsset('assets/icons/start_point.png', 150);
  }

  void fetchInitialLocationFromDB() async {
    var a = await FirebaseFirestore.instance
        .collection('location')
        .get()
        .asStream()
        .first;
    // lat = (a.docs.first['lat'] as num).toDouble();
    // long = (a.docs.first['long'] as num).toDouble();
    initialLat = staticLocationData.first.latitude; //lat;
    initialLong = staticLocationData.first.longitude; //long;

    print('my initial Lat Long :: $initialLat $initialLong');
  }

  Stream<LatLng> locationDataEmitter() async* {
    for (int i = 0; i < staticLocationData.length; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (kDebugMode) {
        print('emitting... catch me if you can!');
      }
      yield staticLocationData[i];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pick Up Map'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MapActionButton(
            icon: Icons.local_shipping_outlined,
            onTap: () {
              changeCameraPosition(location: LatLng(lat, long));
            },
          ),
          MapActionButton(
            icon: Icons.location_on_outlined,
            onTap: () {
              changeCameraPosition(location: LatLng(initialLat, initialLong));
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child:
        // StreamBuilder<QuerySnapshot>(
        //   stream: FirebaseFirestore.instance.collection('location').snapshots(),
        //   // initialData: QuerySnapshot<>,
        //   builder: ( BuildContext context,
        //       AsyncSnapshot<QuerySnapshot> snapshot,){
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const Center(
        //         child: SizedBox(
        //             height: 50,
        //             width: 50,
        //             child: CircularProgressIndicator(
        //               color: Colors.black,
        //             )),
        //       );
        //     } else if (snapshot.connectionState == ConnectionState.active ||
        //         snapshot.connectionState == ConnectionState.done) {
        //       if (snapshot.hasError) {
        //         return const Text('Error');
        //       } else if (snapshot.hasData) {
        //
        //          double mylat = (snapshot.data!.docs.last['lat'] as num).toDouble();
        //          double mylong = (snapshot.data!.docs.last['long'] as num).toDouble();
        //
        //
        //          latLngListForPolyline.add(LatLng(lat, long));
        //          print('PolyLine Len :: ${latLngListForPolyline.length}');
        //
        //          _polyline.add(Polyline(
        //            polylineId: const PolylineId('-1'),
        //            points: latLngListForPolyline,
        //            color: Colors.blue,
        //            width: 8,
        //            patterns: [
        //              PatternItem.dot,
        //              PatternItem.gap(15),
        //            ],
        //          ));
        //          if (kDebugMode) {
        //            print('stream building... intial :: $initialLat $initialLong  First :: $lat $long My :: $mylat $mylong');
        //          }
        //          return GoogleMap(
        //            initialCameraPosition: CameraPosition(
        //              target: LatLng(initialLat, initialLong),
        //              zoom: 16,
        //            ),
        //            mapType: MapType.normal,
        //            markers: <Marker>{
        //              Marker(
        //                  markerId: const MarkerId('1'),
        //                  position: LatLng(initialLat + 10, initialLong + 10),
        //                  // icon: BitmapDescriptor.fromBytes(startMarkerIcon!),
        //                  infoWindow: const InfoWindow(title: 'Start Point')),
        //              Marker(
        //                  markerId: MarkerId(lat.toString()),
        //                  position: LatLng(lat, long),
        //                  // icon: BitmapDescriptor.fromBytes(
        //                  //     markerIcon!), //  markerIcon,
        //                  infoWindow: const InfoWindow(title: 'Current Location'))
        //            },
        //            // polylines: _polyline,
        //            onMapCreated: (GoogleMapController controller) {
        //              _controller.complete(controller);
        //            },
        //            // markers: Marker(markerId: MarkerId()),
        //          );
        //
        //         return const Text('has Data');
        //       } else {
        //         return const Text('Empty data');
        //       }
        //     } else {
        //       return Text('State: ${snapshot.connectionState}');
        //     }
        //   },
        // )

        StreamBuilder<LatLng>(
          initialData: LatLng(initialLat, initialLong),
          stream: locationDataEmitter(),
          builder: (
            BuildContext context,
            AsyncSnapshot<LatLng> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    )),
              );
            } else if (snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Text('Error');
              } else if (snapshot.hasData) {

                lat = snapshot.data?.latitude ?? lat;
                long = snapshot.data?.longitude ?? long;

                latLngListForPolyline.add(LatLng(lat, long));
                _polyline.add(Polyline(
                  polylineId: const PolylineId('-1'),
                  points: latLngListForPolyline,
                  color: Colors.blue,
                  width: 8,
                  patterns: [
                    PatternItem.dot,
                    PatternItem.gap(15),
                  ],
                ));
                if (kDebugMode) {
                  print('stream building...INITIAL :: $initialLat $initialLong  FIRST :: $lat $long');
                }
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, long),
                    zoom: 16,
                  ),
                  mapType: MapType.normal,
                  markers: <Marker>{
                    Marker(
                        markerId: const MarkerId('1'),
                        position: LatLng(initialLat, initialLong),
                        icon: BitmapDescriptor.fromBytes(startMarkerIcon!),
                        infoWindow: const InfoWindow(title: 'Start Point')),
                    Marker(
                        markerId: MarkerId(lat.toString()),
                        position: LatLng(lat, long),
                        icon: BitmapDescriptor.fromBytes(
                            markerIcon!), //  markerIcon,
                        infoWindow: const InfoWindow(title: 'Current Location'))
                  },
                  polylines: _polyline,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  // markers: Marker(markerId: MarkerId()),
                );
              } else {
                return const Text('Empty data');
              }
            } else {
              return Text('State: ${snapshot.connectionState}');
            }
          },
        ),
      ),
    );
  }

  void changeCameraPosition({required LatLng location}) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 16)));
  }
}


