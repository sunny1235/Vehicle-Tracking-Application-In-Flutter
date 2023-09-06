import 'package:background_service_exmp/feature/admin/admin_home_screen.dart';
import 'package:background_service_exmp/feature/driver/driver_home_screen.dart';
import 'package:background_service_exmp/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PickUp-s'),
        centerTitle: true,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(title: 'Admin', onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminHomeScreen()));
            }, color: Colors.black),
            const SizedBox(height: 50,),
            CustomButton(title: 'Driver', onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DriverHomeScreen()));
            }, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
