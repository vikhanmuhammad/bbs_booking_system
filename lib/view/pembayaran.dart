import 'package:bbs_booking_system/controller/bookingController.dart';
import 'package:bbs_booking_system/controller/userController.dart';
import 'package:bbs_booking_system/model/bookingModel.dart';
import 'package:bbs_booking_system/view/timerBayar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bbs_booking_system/controller/notification_service.dart';

class Pembayaran extends StatefulWidget {
  final BookingModel bookingModel;

  const Pembayaran({super.key, required this.bookingModel, required String token});

  @override
  _PembayaranState createState() => _PembayaranState();
}

class _PembayaranState extends State<Pembayaran> {
  String? selectedMethod;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(width: screenWidth * 0.15),
                      Text(
                        'Pembayaran',
                        style: TextStyle(
                            fontSize: screenWidth * 0.053,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
                    child: Text(
                      'Metode Pembayaran',
                      style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: screenWidth * 0.035, top: screenWidth * 0.01),
                    child: Text(
                      'Pilih metode pembayaran yang akan dipakai',
                      style: TextStyle(
                          fontSize: screenWidth * 0.028,
                          fontWeight: FontWeight.normal,
                          color: Color(0xff969696)),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  buildPaymentMethodRow(
                    context,
                    'GoPay',
                    'Saldo: Rp0',
                    'assets/profile.jpg',
                    screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  buildPaymentMethodRow(
                    context,
                    'Transfer Bank Mandiri',
                    '1300021111111 a.n Figma',
                    'assets/profile.jpg',
                    screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.of(context).pop(),
                              child: DraggableScrollableSheet(
                                initialChildSize: 0.75,
                                maxChildSize: 0.75,
                                minChildSize: 0.25,
                                builder: (BuildContext context,
                                    ScrollController scrollController) {
                                  return GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              screenWidth * 0.04),
                                          topRight: Radius.circular(
                                              screenWidth * 0.04),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: screenWidth * 0.0125),
                                            child: Container(
                                              width: screenWidth * 0.12,
                                              height: screenWidth * 0.01,
                                              decoration: BoxDecoration(
                                                  color: Color(0xffD9D9D9)),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(
                                                screenWidth * 0.04),
                                            child: Text(
                                              'Metode Pembayaran',
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.047,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    screenWidth * 0.0125),
                                            child: Container(
                                              width: screenWidth,
                                              height: 1,
                                              decoration: BoxDecoration(
                                                  color: Color(0xffD9D9D9)),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListView(
                                              controller: scrollController,
                                              children: [
                                                ListTile(
                                                  leading: Icon(Icons.payment),
                                                  title: Text('Pembayaran 1'),
                                                  onTap: () {},
                                                ),
                                                ListTile(
                                                  leading: Icon(Icons.payment),
                                                  title: Text('Pembayaran 2'),
                                                  onTap: () {},
                                                ),
                                                // Add more ListTile widgets here as needed
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenWidth * 0.0125),
                        child: Row(
                          children: [
                            Text(
                              'Lihat Pembayaran Lainnya',
                              style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff007EA7)),
                            ),
                          ],
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
                                        fontWeight: FontWeight.w600),
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
                                        color: Colors.black),
                                  ),
                                  Text(
                                    'Rp30.000',
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        color: Colors.black),
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
                                        color: Colors.black),
                                  ),
                                  Text(
                                    'Rp30.000',
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black),
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
              bottom: 0,
              child: Container(
                height: screenWidth * 0.425,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: screenWidth * 0.33,
              left: screenWidth * 0.085,
              child: Text(
                'Harga',
                style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey),
              ),
            ),
            Positioned(
              bottom: screenWidth * 0.25,
              left: screenWidth * 0.085,
              child: Text(
                'Rp30.000',
                style: TextStyle(
                    fontSize: screenWidth * 0.053, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              bottom: screenWidth * 0.08,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffFFB600),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  elevation: 4.0,
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.025),
                ),
                onPressed: () {
                  if (selectedMethod == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Pilih metode pembayaran',
                          style: TextStyle(
                              fontSize: screenWidth * 0.053,
                              fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: Color(0xffFFB600),
                      ),
                    );
                  } else {
                    User? user = FirebaseAuth.instance.currentUser;
                    String fullname = user?.displayName ?? 'User';
                    widget.bookingModel.userBook = fullname;
                    BookingService.addToFirestore(
                        context, widget.bookingModel, widget.bookingModel.meja);
                    ProfileService.addBookDataToUserData(
                        context, widget.bookingModel, widget.bookingModel.meja);

                    DateTime waktuMulai =
                        widget.bookingModel.waktuMulai.toDate();
                    DateTime waktuSelesai =
                        widget.bookingModel.waktuSelesai.toDate();

                    // Schedule notification 5 minutes before the booking start time
                    NotificationService.scheduleNotification(
                      1,
                      'Booking Reminder',
                      'Meja anda sebentar lagi siap, mohon ke meja resepsionis',
                      waktuMulai.subtract(Duration(minutes: 5)),
                    );

                    // Schedule notification 5 minutes before the booking end time
                    NotificationService.scheduleNotification(
                      2,
                      'Booking Reminder',
                      'Waktu main anda hanya tersisa 5 menit.',
                      waktuSelesai.subtract(Duration(minutes: 5)),
                    );

                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TimerBayar()),
                    );
                  }
                },
                child: Text(
                  'Bayar',
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

  Widget buildPaymentMethodRow(
    BuildContext context,
    String methodName,
    String methodDetails,
    String imagePath,
    double screenWidth,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = methodName;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.02, horizontal: screenWidth * 0.04),
        decoration: BoxDecoration(
          color:
              selectedMethod == methodName ? Color(0xff007EA7) : Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.05,
                  backgroundImage: AssetImage(imagePath),
                ),
                SizedBox(width: screenWidth * 0.04),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      methodName,
                      style: TextStyle(
                        fontSize: screenWidth * 0.0425,
                        fontWeight: FontWeight.bold,
                        color: selectedMethod == methodName
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Text(
                      methodDetails,
                      style: TextStyle(
                        fontSize: screenWidth * 0.0325,
                        color: selectedMethod == methodName
                            ? Colors.white
                            : Color(0xff969696),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            selectedMethod == methodName
                ? Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: screenWidth * 0.075,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
