
import 'dart:async';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';

import '../../widgets/map_action_button.dart';

class ServerGMapWidget extends StatefulWidget {
  const ServerGMapWidget({super.key});

  @override
  State<ServerGMapWidget> createState() => _ServerGMapWidgetState();
}

class _ServerGMapWidgetState extends State<ServerGMapWidget> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static double lat = 1;
  static double long = 1;
  static double initialLat = 1;
  static double initialLong = 1;

  Box<dynamic>? myLcStorage;
  final StreamController<List<CustomLatLong>> controller = StreamController();
  final Set<Polyline> _polyline = {};
  List<CustomLatLong> latLngListForPolyline = [];
  List<num> testArray = [];

  Uint8List? markerIcon;
  Uint8List? startMarkerIcon;

  // CameraPosition cameraPosition = CameraPosition(
  //   target: LatLng(lat, long),
  //   zoom: 16,
  // );

  @override
  void initState() {
    fetchInitialLocationFromDB();
    super.initState();
  }

  // @override
  // void dispose(){
  //   print('ON DISPOSE :: $myLcStorage');
  //   if (myLcStorage != null) {
  //     if(!myLcStorage!.containsKey(polylineDataKey)){
  //       print('inside dispose putting');
  //       List<Map<String, double>> dataToAdd = [];
  //       latLngListForPolyline.forEach((element) {
  //         dataToAdd.add({
  //           'lat': element.latitude,
  //           'long': element.longitude
  //         });
  //       });
  //       myLcStorage!.put(polylineDataKey, dataToAdd);
  //     }
  //
  //   }
  //   print('DATA LEN AT DISPOSE :: ${myLcStorage!.get(polylineDataKey)}');
  //   super.dispose();
  // }

  // void setInitialPolylineData() async{
  //   myLcStorage = await Hive.openBox('driverLocalStorage');
  //   if (myLcStorage != null) {
  //     print('HIVE WORKING  going in :: ${myLcStorage!.containsKey(polylineDataKey)}');
  //     if (myLcStorage!.containsKey(polylineDataKey)) {
  //       latLngListForPolyline.addAll((myLcStorage!.get(polylineDataKey) as List<Map<String, double>>).map((e) => LatLng(e['lat']!, e['long']!) ));
  //       print('hive working loaded with Data ${latLngListForPolyline.length}');
  //     }
  //   } else {
  //     print('local storage setup is null');
  //   }
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

  Future<void> resizeMarker() async {
    markerIcon = await getBytesFromAsset('assets/icons/car1.png', 150);
    startMarkerIcon =
        await getBytesFromAsset('assets/icons/start_position.png', 150);
  }

  void fetchInitialLocationFromDB() async {
    await resizeMarker();
    var collectionRef = await FirebaseFirestore.instance
        .collection('location')
        .orderBy('date')
        .get();
    latLngListForPolyline.addAll(collectionRef.docs
        .map((e) => CustomLatLong(LatLng(e['lat'], e['long']), e['index']))
        .toList());
    testArray.addAll(collectionRef.docs.map((e) => e['index']));

    print('TEST ARRAY AT INITIAL :: $testArray');
    // var collectionRef = await FirebaseFirestore.instance.collection('location').orderBy('date').get();
    // testArray.addAll(collectionRef.docs.map((e) => (e['index'] as num) ).toList());
    //
    //
    // print('first array val :: ${testArray.first}');

    // var a = await FirebaseFirestore.instance
    //     .collection('location')
    //     .get()
    //     .asStream()
    //     .first;
    // lat = (a.docs.first['lat'] as num).toDouble();
    // long = (a.docs.first['long'] as num).toDouble();
    // initialLat = lat; //staticLocationData.first.latitude; //lat;
    // initialLong = long; // staticLocationData.first.longitude; //long;

    // lat = latLngListForPolyline.first.latLng.longitude;
    // long = latLngListForPolyline.first.latLng.longitude;

    print('DATA AT BUILD1 :: $lat $long');

    initialLat = lat;
    initialLong = long;

    controller.add(latLngListForPolyline);
    FirebaseFirestore.instance
        .collection('location')
        .orderBy('date')
        .snapshots()
        .listen((event) {
      if (latLngListForPolyline.indexWhere((element) =>
              element.index == (event.docs.last['index'] as num)) >=
          0) return;
      lat = (event.docs.last['lat'] as num).toDouble();
      long = (event.docs.last['long'] as num).toDouble();
      print('DATA AT BUILD2 :: $lat $long');
      latLngListForPolyline
          .add(CustomLatLong(LatLng(lat, long), event.docs.last['index']));
      testArray.add(event.docs.last['index'] as num);
      controller.add(latLngListForPolyline);
    });
  }
  // Stream<LatLng> locationDataEmitter() async* {
  //   for (int i = 0; i < staticLocationData.length; i++) {
  //     await Future.delayed(const Duration(seconds: 1));
  //     if (kDebugMode) {
  //       print('emitting... catch me if you can!');
  //     }
  //     yield staticLocationData[i];
  //   }
  // }
  //

  // Future<void> locationDataEmitter2() async {
  //   for (int i = 0; i < staticDataDummy.length; i++) {
  //     await Future.delayed(const Duration(seconds: 3));
  //     if (kDebugMode) {
  //       print('emitting... catch me if you can!');
  //     }
  //     FirebaseFirestore.instance.collection('location').add({'index' : i, 'date' : DateTime.now()});
  //     // yield staticDataDummy[i];
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Server Pick Up Map'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MapActionButton(
            icon: Icons.local_shipping_outlined,
            onTap: () {
              print('DATA AT BUTTON :: $lat $long');
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
        child: StreamBuilder<List<CustomLatLong>>(
          stream: controller.stream,
          builder: (
            BuildContext context,
            AsyncSnapshot<List<CustomLatLong>> snapshot,
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
                initialLat = snapshot.data!.first.latLng.latitude;
                initialLong = snapshot.data!.first.latLng.longitude;

                _polyline.add(Polyline(
                  polylineId: const PolylineId('-1'),
                  points: List.of((snapshot.data ?? []).map((e) => e.latLng)),
                  color: Colors.blue,
                  width: 8,
                  patterns: [
                    PatternItem.dot,
                    PatternItem.gap(15),
                  ],
                ));
                print('DATA AT BUILD FOR MARKER :: $lat $long');
                return ((initialLong == 1.0 && initialLat == 1.0) ||
                        (lat == 1.0 && long == 1.0))
                    ? const Center(
                        child: SizedBox(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            )),
                      )
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(lat, long),
                          tilt: 15,
                          zoom: 16,
                        ),
                        // 19.45981 72.82
                        mapType: MapType.normal,
                        markers: <Marker>{
                          Marker(
                              markerId: const MarkerId('1'),
                              position: LatLng(initialLat, initialLong),
                              icon:
                                  BitmapDescriptor.fromBytes(startMarkerIcon!),
                              infoWindow:
                                  const InfoWindow(title: 'Start Point')),
                          Marker(
                              markerId: MarkerId(lat.toString()),
                              position: LatLng(lat, long),
                              icon: BitmapDescriptor.fromBytes(
                                  markerIcon!), //  markerIcon,
                              infoWindow:
                                  const InfoWindow(title: 'Current Location'))
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
        CameraPosition(target: location, zoom: 16, tilt: 30)));
  }
}

class CustomLatLong {
  final LatLng latLng;
  final int index;

  CustomLatLong(this.latLng, this.index);
}
