
import 'package:background_service_exmp/utils/firebase_options.dart';
import 'package:background_service_exmp/widgets/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // This is the theme of your application.
      ),
      home: const HomeScreen(),
    );
  }
}
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   // static const String _isolateName = "LocatorIsolate";
//   ReceivePort port = ReceivePort();
//
//   String logStr = '';
//   bool isRunning = false;
//   loc.LocationData? _locationData;
//   late bool hasLocationPermission ;
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (IsolateNameServer.lookupPortByName(
//             LocationServiceRepository.isolateName) !=
//         null) {
//       IsolateNameServer.removePortNameMapping(
//           LocationServiceRepository.isolateName);
//     }
//
//     IsolateNameServer.registerPortWithName(
//         port.sendPort, LocationServiceRepository.isolateName);
//
//     port.listen(
//       (dynamic data) async {
//         print('listening Data :: $data');
//         // await updateUI(data);
//       },
//     );
//     initPlatformState();
//   }
//
//   Future<void> updateUI(LocationDto data) async {
//     print('update UI');
//     // final log = await FileManager.readLogFile();
//
//     // await _updateNotificationText(data);
//
//     // setState(() {
//     //   if (data != null) {
//     //     lastLocation = data;
//     //   }
//     //   logStr = log;
//     // });
//   }
//
//   Future<void> initPlatformState() async {
//     await BackgroundLocator.initialize();
//     final _isRunning = await BackgroundLocator.isServiceRunning();
//
//     bool check = await _checkLocationPermission();
//     // print('permission check  :: $check and $hasLocationPermission');
//     print('initial is running :: $_isRunning');
//   }
//
//   Future<void> startLocationService(loc.LocationData? locationData) async {
//     Map<String, dynamic> data = {
//       'lat': locationData?.latitude ?? 0,
//       'long': locationData?.longitude ?? 0
//     };
//     print('Location Data :: $data');
//     BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
//         initCallback: LocationCallbackHandler.initCallback,
//         initDataCallback: data,
//         disposeCallback: LocationCallbackHandler.disposeCallback,
//         autoStop: false,
//         iosSettings: const IOSSettings(
//             accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
//         androidSettings: const AndroidSettings(
//             accuracy: LocationAccuracy.NAVIGATION,
//             interval: 5,
//             distanceFilter: 0,
//             androidNotificationSettings: AndroidNotificationSettings(
//                 notificationChannelName: 'Location tracking',
//                 notificationTitle: 'Start Location Tracking',
//                 notificationMsg: 'Track location in background',
//                 notificationBigMsg:
//                     'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
//                 notificationIcon: '',
//                 notificationIconColor: Colors.grey,
//                 notificationTapCallback:
//                     LocationCallbackHandler.notificationCallback)));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final start = SizedBox(
//       width: double.maxFinite,
//       child: ElevatedButton(
//         child: const Text('Start'),
//         onPressed: () {
//           // FirebaseFirestore firestore = FirebaseFirestore.instance;
//           // firestore.collection('location').add({
//           //   'lat': 000000,
//           //   'long' : 00000
//           // });
//           _onStart();
//         },
//       ),
//     );
//     final stop = SizedBox(
//       width: double.maxFinite,
//       child: ElevatedButton(
//         child: const Text('Stop'),
//         onPressed: () {
//           onStop();
//         },
//       ),
//     );
//     // final clear = SizedBox(
//     //   width: double.maxFinite,
//     //   child: ElevatedButton(
//     //     child: Text('Clear Log'),
//     //     onPressed: () {
//     //       // FileManager.clearLogFile();
//     //       // setState(() {
//     //       //   logStr = '';
//     //       // });
//     //     },
//     //   ),
//     // );
//     String msgStatus = "-";
//     if (isRunning != null) {
//       if (isRunning) {
//         msgStatus = 'Is running';
//       } else {
//         msgStatus = 'Is not running';
//       }
//     }
//     final status = Text("Status: $msgStatus");
//
//     final log = Text(
//       logStr,
//     );
//
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Flutter background Locator'),
//         ),
//         body: Container(
//           width: double.maxFinite,
//           padding: const EdgeInsets.all(22),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 start,
//                 stop,
//                 // clear,
//                 status,
//                 log
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void onStop() async {
//     await BackgroundLocator.unRegisterLocationUpdate();
//     final _isRunning = await BackgroundLocator.isServiceRunning();
//     print('on stop is running :: $_isRunning');
//     setState(() {
//       isRunning = _isRunning;
//     });
//   }
//
//   void _onStart() async {
//     bool _check  = await _checkLocationPermission();
//     print('location permission on start click:: $hasLocationPermission and check is :: $_check');
//     if (hasLocationPermission) {
//       await startLocationService(_locationData);
//       final _isRunning = await BackgroundLocator.isServiceRunning();
//       print('on start is running :: $_isRunning');
//       setState(() {
//         isRunning = _isRunning;
//         // lastLocation = null;
//       });
//     } else {
//       // show error
//     }
//   }
//
//   Future<bool> _checkLocationPermission() async {
//     loc.Location location = loc.Location();
//
//     bool serviceEnabled;
//     loc.PermissionStatus permissionGranted;
//
//     serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) {
//         print('location service not enabled');
//         hasLocationPermission = false;
//         return false;
//       }
//     }
//
//     permissionGranted = await location.hasPermission();
//     if (permissionGranted == loc.PermissionStatus.denied) {
//       print('check denied');
//       permissionGranted = await location.requestPermission();
//       if (permissionGranted != loc.PermissionStatus.granted) {
//         print('check granted');
//         _locationData = await location.getLocation();
//         hasLocationPermission = true;
//         return true;
//       }
//     } else {
//       print('check granted 2');
//       _locationData = await location.getLocation();
//       hasLocationPermission = true;
//       return true;
//     }
//
//     hasLocationPermission = false;
//     return false;
//   }
// }
