import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbs_booking_system/view/booking.dart';
import 'package:bbs_booking_system/view/beranda.dart';
import 'package:bbs_booking_system/view/pesanan.dart';
import 'package:bbs_booking_system/controller/timerProvider.dart';
import 'package:bbs_booking_system/view/timerBayar.dart';

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    Beranda(),
    Booking(),
    Pesanan(),
  ];

  void _onItemTapped(int index) {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    setState(() {
      if (index == 1 && timerProvider.isTimerActive) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => TimerBayar()));
      } else {
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final Color kuningBBS = Color(0xFFFFB600);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            backgroundColor: kuningBBS,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_outlined, size: 32),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_rounded),
                activeIcon: Icon(Icons.calendar_today_rounded, size: 32),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_rounded),
                activeIcon: Icon(Icons.list_alt_rounded, size: 32),
                label: 'Pesanan',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
            selectedLabelStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Positioned(
            top: -screenHeight * 0.04,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () {
                  _onItemTapped(1);
                },
                child: Container(
                  width: screenWidth * 0.23,
                  height: screenWidth * 0.23,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: screenWidth * 0.09,
                          color: _selectedIndex == 1 ? Colors.white : kuningBBS,
                        ),
                        Text(
                          'Booking',
                          style: TextStyle(
                            color:
                                _selectedIndex == 1 ? Colors.white : kuningBBS,
                            fontSize: screenWidth * 0.03,
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
