import 'package:bbs_booking_system/view/admin/navbaradmin.dart';
import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

class BookingBerhasilAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NavBarAdmin()),
        );
      },
      child: Scaffold(
        backgroundColor: Color(0xffFFB600),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // // Animasi menggunakan Lottie
              // Lottie.asset(
              //   'assets/success_animation.json', // Path ke file animasi Lottie
              //   width: 150,
              //   height: 150,
              //   fit: BoxFit.fill,
              // ),
              SizedBox(height: 20),
              Text(
                'Booking Berhasil!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
