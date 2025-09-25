import 'package:bbs_booking_system/view/navbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbs_booking_system/controller/timerProvider.dart';

class TimerBayar extends StatefulWidget {
  @override
  _TimerBayarState createState() => _TimerBayarState();
}

class _TimerBayarState extends State<TimerBayar> {
  @override
  void initState() {
    super.initState();
    Provider.of<TimerProvider>(context, listen: false).startTimer();
  }

  @override
  void dispose() {
    Provider.of<TimerProvider>(context, listen: false).resetTimer();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final timerProvider = Provider.of<TimerProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        iconSize: screenWidth * 0.08,
                        onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => NavBar())),
                      ),
                      SizedBox(
                        width: screenWidth * 0.15,
                      ),
                      Text(
                        'Pembayaran',
                        style: TextStyle(
                            fontSize: screenWidth * 0.053,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Container(
                        width: screenWidth,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.04),
                          color: Color(0xffFF0000).withOpacity(0.2),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Batas waktu pembayaran',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(timerProvider.duration),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xffFF0000),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Container(
                        width: screenWidth,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.04),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Kode Virtual',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    '1029831029481',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Container(
                        width: screenWidth,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.04),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Ringkasan Pembayaran',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenWidth * 0.0375),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ceritanya ringkasan',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Rp30.000',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenWidth * 0.125),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Pembayaran ',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Rp30.000',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: screenWidth * 0.08,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  elevation: 4.0,
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.025),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Konfirmasi Pembatalan'),
                        content: Text(
                            'Apakah Anda yakin ingin membatalkan pembayaran?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Tidak',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Provider.of<TimerProvider>(context, listen: false)
                                  .resetTimer();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => NavBar()),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: Text('Ya'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  'Batalkan Pembayaran',
                  style: TextStyle(
                      fontSize: screenWidth * 0.053,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => TimerProvider(),
//       child: MaterialApp(
//         home: TimerBayar(),
//       ),
//     ),
//   );
// }
