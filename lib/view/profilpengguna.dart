import 'package:bbs_booking_system/controller/dbController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bbs_booking_system/view/authscreen.dart';
import 'package:bbs_booking_system/view/gabungmember.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilPengguna extends StatefulWidget {
  ProfilPengguna();

  @override
  _ProfilPenggunaState createState() => _ProfilPenggunaState();
}

class _ProfilPenggunaState extends State<ProfilPengguna> {
  String phone = "Loading...";
  bool isMember = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        isMember = userData.data()?['member'] ?? false;
        phone = isMember
            ? (userData.data()?['phone'] ?? 'Nomor tidak ditemukan')
            : 'Belum terdaftar member';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String fullname = user?.displayName ?? 'User';
    String email = user?.email ?? 'User';
    DateTime? joined = user?.metadata.creationTime ?? DateTime.now();

    String formattedDate = "${joined.toLocal().toString().split(' ')[0]}";
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
                Text(
                  'Joined: ' + formattedDate,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey,
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
                          Row(
                            children: [
                              Icon(
                                Icons.phone_android_outlined,
                                size: screenWidth * 0.09,
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: screenWidth * 0.02),
                                child: Container(
                                  width: screenWidth * 0.55,
                                  child: Text(
                                    phone,
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GabungMember()),
                              );
                            },
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
                                    'Member',
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
