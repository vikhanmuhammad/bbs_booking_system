import 'package:bbs_booking_system/controller/dbController.dart';
import 'package:bbs_booking_system/view/admin/navbaradmin.dart';
import 'package:bbs_booking_system/view/authscreen.dart';
import 'package:bbs_booking_system/view/navbar.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: DatabaseHelper().isDatabaseEmpty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data ?? true) {
              return LoginScreen();
            } else {
              return cekAdmin(context);
            }
          } else {
            return Stack();
          }
        },
      ),
    );
  }

  Widget cekAdmin(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: DatabaseHelper().isAdminEmailPresent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data ?? true) {
              return NavBarAdmin();
            } else {
              return NavBar();
            }
          } else {
            return Stack();
          }
        },
      ),
    );
  }
}
