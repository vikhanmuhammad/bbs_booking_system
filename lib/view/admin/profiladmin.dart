import 'package:bbs_booking_system/controller/dbController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bbs_booking_system/view/authscreen.dart';

class ProfilAdmin extends StatefulWidget {
  ProfilAdmin();

  @override
  _ProfilAdminState createState() => _ProfilAdminState();
}

class _ProfilAdminState extends State<ProfilAdmin> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String fullname = user?.displayName ?? 'User';
    String email = user?.email ?? 'User';

    // Get the screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: Image.asset(
                    'assets/images/Logo BBS Pool & Cafe.png',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Text(
                    fullname,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: screenWidth * 0.065,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.02,
                      bottom: screenHeight * 0.02,
                      left: screenWidth * 0.1,
                      right: screenWidth * 0.1),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_2_outlined,
                                size: screenWidth * 0.09,
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: screenWidth * 0.02),
                                child: Container(
                                  width: screenWidth * 0.55,
                                  child: Text(
                                    fullname,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: screenWidth * 0.045,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Icon(
                                Icons.mail_outline,
                                size: screenWidth * 0.09,
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: screenWidth * 0.02),
                                child: Container(
                                  width: screenWidth * 0.55,
                                  child: Text(
                                    email,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: screenWidth * 0.045,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          InkWell(
                            onTap: () {},
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: screenWidth * 0.09,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: screenWidth * 0.02),
                                  child: Text(
                                    'Feedback',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: screenWidth * 0.045,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.chevron_right,
                                  size: screenWidth * 0.09,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: SizedBox(
                    width: screenWidth * 0.85,
                    child: ElevatedButton(
                      onPressed: () {
                        FirebaseAuth _auth = FirebaseAuth.instance;
                        _auth.signOut();
                        DatabaseHelper().deleteDatabase();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Color(0xFFFFB600),
                      ),
                      child: Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: screenWidth * 0.045,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
