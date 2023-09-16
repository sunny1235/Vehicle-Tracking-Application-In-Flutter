import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../utils/location_service_repo.dart';
import '../../widgets/custom_button.dart';
import 'package:location/location.dart' as loc;

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  ReceivePort port = ReceivePort();

  //initially running status should be taken from local storage..
  bool isRunning = false;
  loc.LocationData? _locationData;
  late bool hasLocationPermission;

  Box? box;
  static const String boxName = 'driverBox';
  static const String isRunningKey = 'isRunningKey';

  @override
  void initState() {
    updateDrivingStatus();

    super.initState();

    if (IsolateNameServer.lookupPortByName(
            LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);

    port.listen(
      (dynamic data) async {
        if (kDebugMode) {
          print('listening Data :: $data');
        }
        final serviceCheck = await BackgroundLocator.isServiceRunning();
        if (kDebugMode) {
          print('listener is running :: $serviceCheck');
        }

        isRunning = serviceCheck;
        if (box != null) {
          box!.put(isRunningKey, isRunning);
        }
        updateUI(data);
      },
    );

    initPlatformState();
  }

  // Future<void> locationDataEmitter2() async {
  //   for (int i = 0; i < staticDataDummy.length; i++) {
  //     await Future.delayed(const Duration(milliseconds: 500));
  //     if (kDebugMode) {
  //       print('emitting... catch me if you can!');
  //     }
  //     FirebaseFirestore.instance
  //         .collection('location')
  //         .add({'index': i, 'date': DateTime.now()});
  //     // yield staticDataDummy[i];
  //     if(i == staticDataDummy.length-1){
  //       print('DONE EMMITING');
  //     }
  //   }
  // }

  Future<void> updateDrivingStatus() async {
    box = await Hive.openBox(boxName);
    if (box != null) {
      if (!box!.containsKey(isRunningKey)) {
        box!.put(isRunningKey, isRunning);
      } else {
        isRunning = box!.get(isRunningKey);
      }
    } else {
      if (kDebugMode) {
        print('BOX IS EMPTY OR NULL');
      }
    }
  }

  void updateUI(double? data) {
    if (mounted) {
      if (data != null) {
        setState(() {});
      }
    }
  }

  Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
    final serviceCheck = await BackgroundLocator.isServiceRunning();
    if (kDebugMode) {
      print('initial is running :: $serviceCheck');
    }
    _checkLocationPermission();
  }

  Future<bool> _checkLocationPermission() async {
    loc.Location location = loc.Location();
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print('location service not enabled');
        }
        hasLocationPermission = false;
        return false;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      if (kDebugMode) {
        print('check denied');
      }
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        if (kDebugMode) {
          print('check granted');
        }
        _locationData = await location.getLocation();
        hasLocationPermission = true;
        return true;
      }
    } else {
      if (kDebugMode) {
        print('check granted 2');
      }
      _locationData = await location.getLocation();
      hasLocationPermission = true;
      return true;
    }

    hasLocationPermission = false;
    return false;
  }

  Future<void> startLocationService(loc.LocationData? locationData) async {
    Map<String, dynamic> data = {
      'lat': locationData?.latitude ?? 0,
      'long': locationData?.longitude ?? 0
    };
    if (kDebugMode) {
      print('Location Data :: $data');
    }
    BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        autoStop: false,
        iosSettings: const IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
        androidSettings: const AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 5,
            distanceFilter: 0,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                    'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIcon: '',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pick Up'),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: ()async{
      //   locationDataEmitter2();
      // },),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Riding status... $isRunning'),
            const SizedBox(
              height: 15,
            ),
            CustomButton(
              title: isRunning ? 'Riding..' : 'Start Riding',
              onTap: isRunning ? null : onStart,
              color: isRunning ? Colors.blueGrey : Colors.black,
            ),
            const SizedBox(
              height: 100,
            ),
            isRunning
                ? CustomButton(
                    title: 'Stop Riding',
                    onTap: !isRunning ? null : onStop,
                    color: isRunning ? Colors.black : Colors.blueGrey,
                  )
                : const SizedBox(),
            // const SizedBox(
            //   height: 10,
            // ),
            // ElevatedButton(
            //     onPressed: () async {
            //       Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => const ServerGMapWidget()));
            //     },
            //     child: const Text('Go to Map'))
          ],
        ),
      ),
    );
  }

  void onStop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
    final serviceStatus = await BackgroundLocator.isServiceRunning();
    if (kDebugMode) {
      print('on stop is running :: $serviceStatus');
    }
    if (mounted) {
      setState(() {
        isRunning = serviceStatus;
        if (box != null) {
          box!.put(isRunningKey, isRunning);
        }
      });
    }
    await deleteAll();
  }

  void onStart() async {
    await _checkLocationPermission();
    if (hasLocationPermission) {
      await startLocationService(_locationData);
      final isServiceRunning = await BackgroundLocator.isServiceRunning();
      if (kDebugMode) {
        print('on start is running :: $isServiceRunning');
      }
      if (mounted) {
        setState(() {
          isRunning = isServiceRunning;
          if (box != null) {
            box!.put(isRunningKey, isRunning);
          }
        });
      }
    } else {
      // show error
    }
  }

  Future<void> deleteAll() async {
    print('Delete all Data');
    await FirebaseFirestore.instance
        .collection('location')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}

class LocationCallbackHandler {
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.init(params);
  }

  static Future<void> disposeCallback() async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  static Future<void> callback(LocationDto locationDto) async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.callback(locationDto);
  }

  static Future<void> notificationCallback() async {
    print('***notificationCallback');
  }
}
