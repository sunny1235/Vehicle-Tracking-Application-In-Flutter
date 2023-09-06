import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addLocationData(
    double lat,
    double long,
      int index,
  ) async {
    await firestore.collection("location").add({'lat': lat, 'long': long,'date' : DateTime.now(), 'index'  : index});
  }


  // Future<void> addIndex(int data)async {
  //   await firestore.collection("location").add({'ind': data, 'date' : DateTime.now()});
  // }

  // List<Marker> locationData = [
  //   const Marker(
  //       markerId: MarkerId('1'),
  //       position: LatLng(19.459804, 72.813621),
  //       infoWindow: InfoWindow(title: 'My Location')),
  //   const Marker(
  //       markerId: MarkerId('2'),
  //       position: LatLng(19.459673, 72.813471),
  //       infoWindow: InfoWindow(title: 'My Location')),
  //   const Marker(
  //       markerId: MarkerId('3'),
  //       position: LatLng(19.459509, 72.813155),
  //       infoWindow: InfoWindow(title: 'My Location')),
  //   const Marker(
  //       markerId: MarkerId('4'),
  //       position: LatLng(19.459401, 72.813051),
  //       infoWindow: InfoWindow(title: 'My Location')),
  //   const Marker(
  //       markerId: MarkerId('5'),
  //       position: LatLng(19.459289, 72.812866),
  //       infoWindow: InfoWindow(title: 'My Location')),
  //   const Marker(
  //       markerId: MarkerId('6'),
  //       position: LatLng(19.459184, 72.812649),
  //       infoWindow: InfoWindow(title: 'My Location')),
  //   const Marker(
  //       markerId: MarkerId('7'),
  //       position: LatLng(19.458799, 72.812266),
  //       infoWindow: InfoWindow(title: 'My Location')),
  //   const Marker(
  //       markerId: MarkerId('8'),
  //       position: LatLng(19.458562, 72.812098),
  //       infoWindow: InfoWindow(title: 'My Location')),
  //   const Marker(
  //       markerId: MarkerId('9'),
  //       position: LatLng(19.458868, 72.810379),
  //       infoWindow: InfoWindow(title: 'My Location')),
  //   const Marker(
  //       markerId: MarkerId('10'),
  //       position: LatLng(19.458735, 72.809858),
  //       infoWindow: InfoWindow(title: 'My Location')),
  // ];


  // Stream<Marker> locationDataEmitter() async* {
  //   for (int i = 0; i < locationData.length; i++) {
  //     await Future.delayed(const Duration(seconds: 2));
  //     print('emitting... catch me if you can!');
  //     yield locationData[i];
  //   }
  // }
  // Future<void> editProduct(bool _isFavourite,String id) async {
  //   await Firestore.instance
  //       .collection("products")
  //       .document(id)
  //       .updateData({"isFavourite": !_isFavourite});
  // }
  //
  // Future<void> deleteProduct(DocumentSnapshot doc) async {
  //   await Firestore.instance
  //       .collection("products")
  //       .document(doc.documentID)
  //       .delete();
  // }
}
