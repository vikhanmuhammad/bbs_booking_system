import 'package:bbs_booking_system/view/admin/aturtutupadmin.dart';
import 'package:bbs_booking_system/view/admin/berandaadmin.dart';
import 'package:bbs_booking_system/view/admin/bookingadmin.dart';
import 'package:bbs_booking_system/view/admin/menuoperasiadmin.dart';
import 'package:bbs_booking_system/view/admin/pesananadmin.dart';
import 'package:flutter/material.dart';

class NavBarAdmin extends StatefulWidget {
  @override
  _NavBarAdminState createState() => _NavBarAdminState();
}

class _NavBarAdminState extends State<NavBarAdmin> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions() => <Widget>[
        BerandaAdmin(),
        PesananAdmin(), //page pesanan
        BookingAdmin(),
        MenuOperasiAdmin(),
        AturTutupAdmin(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final Color kuningBBS = Color(0xFFFFB600);

    return Scaffold(
      body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 32,),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_rounded, size: 32,),
                label: 'Pesanan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_rounded, size: 32,),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timelapse_outlined, size: 32,),
                label: 'Operasi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_view_month, size: 32,),
                label: 'Tutup',
              ),
            ],
            backgroundColor: kuningBBS,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
            selectedLabelStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: screenWidth * 0.025,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w100,
              fontSize: screenWidth * 0.025,
            ),
          ),
          Positioned(
            top: -screenHeight * 0.03,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () {
                  _onItemTapped(2);
                },
                child: Container(
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    border: Border.all(
                        color: Colors.white, width: screenWidth * 0.01),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: screenWidth * 0.08,
                          color: _selectedIndex == 2 ? Colors.white : kuningBBS,
                        ),
                        Text(
                          'Booking',
                          style: TextStyle(
                            color:
                                _selectedIndex == 2 ? Colors.white : kuningBBS,
                            fontSize: screenWidth * 0.025,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
