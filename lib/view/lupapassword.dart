import 'package:bbs_booking_system/view/authscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LupaPassword extends StatefulWidget {
  @override
  _LupaPasswordState createState() => _LupaPasswordState();
}

class _LupaPasswordState extends State<LupaPassword> {
  TextEditingController emailController = TextEditingController();

  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email reset password terkirim!'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("No user found with this email.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User dengan email tersebut tidak ditemukan.'),
          ),
        );
      } else {
        print("Failed to send password reset email: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengirim email reset password.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final Color yellowColor = Colors.yellow.withOpacity(1);
    final Color kuningBBS = Color(0xFFFFB600);

    return Scaffold(
      backgroundColor: kuningBBS,
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: screenWidth,
                      height: screenWidth - 175,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(200, 100),
                        ),
                        color: Colors.black,
                      ),
                    ),
                    ColorFiltered(
                      colorFilter:
                          ColorFilter.mode(yellowColor, BlendMode.modulate),
                      child: Center(
                        child: Image.asset(
                          'assets/images/lampugantung.png',
                          width: screenWidth - 125,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.28),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: screenHeight * 0.0),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.07,
                                      vertical: screenHeight * 0.03),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            color: kuningBBS,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: screenWidth * 0.04,
                                                vertical: screenHeight * 0.02),
                                            child: Text(
                                              'Lupa Password',
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.05,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.02),
                                      Center(
                                        child: Text(
                                          'Masukkan Email yang terkait dengan akun anda.',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      TextField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.04),
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              bottom: screenHeight * 0.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              resetPassword(
                                                  emailController.text,
                                                  context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              backgroundColor: kuningBBS,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      screenWidth * 0.02),
                                              child: Text(
                                                'Selanjutnya',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: screenWidth * 0.045,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.02),
                                      Center(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: screenWidth * 0.07),
                                              child: Text(
                                                'Batal untuk ganti password?',
                                                style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.03),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          LoginScreen()),
                                                );
                                              },
                                              child: Text(
                                                'Sign In.',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.03,
                                                  color: kuningBBS,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
