import 'package:bbs_booking_system/controller/userController.dart';
import 'package:bbs_booking_system/model/bookingModel.dart';
import 'package:bbs_booking_system/view/profilpengguna.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bbs_booking_system/view/detailriwayatpesanan.dart';
import 'package:intl/intl.dart';

class Pesanan extends StatefulWidget {
  @override
  _PesananState createState() => _PesananState();
}

class _PesananState extends State<Pesanan> {
  int selectedButtonIndex = 0;

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String fullname = user?.displayName ?? 'User';
    final Color kuningBBS = Color(0xFFFFB600);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.08,
                right: screenWidth * 0.08,
                top: screenHeight * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang,',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.normal,
                        color: Color(0xff969696),
                      ),
                    ),
                    Container(
                      child: Container(
                        width: screenWidth - screenWidth * 0.47,
                        child: Text(
                          fullname,
                          style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: screenWidth * 0.05,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilPengguna()),
                    );
                  },
                  child: Icon(
                    Icons.settings_outlined,
                    size: screenWidth * 0.1,
                    color: kuningBBS,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Add your onTap code here for the Icon
                  },
                  child: Icon(
                    Icons.notifications_outlined,
                    size: screenWidth * 0.1,
                    color: kuningBBS,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: screenWidth * 0.05),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.04),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedButtonIndex = 0;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenWidth * 0.02),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: selectedButtonIndex == 0
                                  ? kuningBBS
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Kode Aktif',
                          style: TextStyle(
                            fontWeight: selectedButtonIndex == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: screenWidth * 0.032,
                            color: selectedButtonIndex == 0
                                ? Colors.black
                                : Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.04),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedButtonIndex = 1;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenWidth * 0.02),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: selectedButtonIndex == 1
                                  ? kuningBBS
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Riwayat Pesanan',
                          style: TextStyle(
                            fontWeight: selectedButtonIndex == 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: screenWidth * 0.032,
                            color: selectedButtonIndex == 1
                                ? Colors.black
                                : Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: selectedButtonIndex == 0
                ? _readKodeAktif(context, screenWidth)
                : _readRiwayatPesanan(context, screenWidth),
          ),
        ],
      ),
    );
  }

  Widget _readKodeAktif(BuildContext context, double screenWidth) {
    ProfileService _profileService = ProfileService();

    return FutureBuilder<BookingModel?>(
      future: _profileService.getLatestBookingData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const Text('Loading...'));
        }
        if (snapshot.hasData) {
          BookingModel? booking = snapshot.data;
          if (booking != null) {
            if (booking.waktuSelesai.compareTo(Timestamp.now()) >= 0) {
              return Container(
                height: 250, // Specify a height for the container
                child: _buildKodeAktif(booking, screenWidth),
              );
            }
          }
        }
        BookingModel book = BookingModel(
            kodeBooking: '-',
            userBook: '',
            userBookUID: '',
            meja: 0,
            lantai: 0,
            waktuMulai:
                Timestamp.fromDate(DateTime.now().subtract(Duration(days: 1))),
            waktuSelesai: Timestamp.now(),
            statusBayar: false,
            metodeBayar: '',
            paket: '');
        return _buildKodeAktif(book, screenWidth);
      },
    );
  }

  Widget _buildKodeAktif(BookingModel booking, double screenWidth) {
    final Color kuningBBS = Color(0xFFFFB600);

    DateTime dateTimeMulai = booking.waktuMulai.toDate();
    DateTime dateTimeSelesai = booking.waktuSelesai.toDate();

    int hourMulai = dateTimeMulai.hour;
    int minuteMulai = dateTimeMulai.minute;
    int hourSelesai = dateTimeSelesai.hour;
    int minuteSelesai = dateTimeSelesai.minute;
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: kuningBBS,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: screenWidth * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            booking.meja != 0
                                ? 'Meja ' + booking.meja.toString()
                                : 'Meja -',
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Image.asset(
                            'assets/images/Logo BBS Pool & Cafe.png',
                            width: screenWidth * 0.15,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: screenWidth * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: screenWidth * 0.2,
                            child: Center(
                              child: Text(
                                'Tanggal',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: screenWidth * 0.2,
                            child: Center(
                              child: Text(
                                'Lantai',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: screenWidth * 0.2,
                            child: Center(
                              child: Text(
                                'Jam',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: screenWidth * 0.2,
                          child: Center(
                            child: Text(
                              formatDate(booking.waktuMulai) !=
                                      formatDate(Timestamp.fromDate(
                                          DateTime.now()
                                              .subtract(Duration(days: 1))))
                                  ? formatDate(booking.waktuMulai)
                                  : '-',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: screenWidth * 0.2,
                          child: Center(
                            child: Text(
                              booking.lantai != 0
                                  ? booking.lantai.toString()
                                  : '-',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: screenWidth * 0.2,
                          child: Center(
                            child: Text(
                              formatDate(booking.waktuMulai) !=
                                      formatDate(Timestamp.fromDate(
                                          DateTime.now()
                                              .subtract(Duration(days: 1))))
                                  ? '${hourMulai.toString().padLeft(2, '0')}:${minuteMulai.toString().padLeft(2, '0')} - ${hourSelesai.toString().padLeft(2, '0')}:${minuteSelesai.toString().padLeft(2, '0')} WIB'
                                  : '-',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/bawahantiket.png',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: screenWidth * 0.03,
                      left: screenWidth * 0.09,
                      right: screenWidth * 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: screenWidth * 0.3,
                        child: Text(
                          'Kode Booking',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        width: screenWidth * 0.4,
                        child: Text(
                          booking.kodeBooking,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _readRiwayatPesanan(BuildContext context, double screenWidth) {
    ProfileService _profileService = ProfileService();
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: _profileService.getLatest7Booking(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const Text('Loading...'));
        }
        if (snapshot.hasData) {
          return Container(
            height: 250, // Specify a height for the container
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return _buildRiwayatPesanan(
                    snapshot.data!.docs[index], context, screenWidth);
              },
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey, // Customize the color of the separator
                thickness: 1.0, // Customize the thickness of the separator
              ),
            ),
          );
        }
        return const Text('No data available');
      },
    );
  }

  Widget _buildRiwayatPesanan(DocumentSnapshot<Map<String, dynamic>> doc,
      BuildContext context, double screenWidth) {
    Map<String, dynamic> data = doc.data()!;
    String tanggal = formatDate(data['waktuMulai']);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailRiwayatPesanan(bookingModel: data)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0),
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          children: [
            Image.asset(
              'assets/images/Logo BBS Pool & Cafe.png',
              width: screenWidth * 0.125,
            ),
            SizedBox(width: screenWidth * 0.05),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meja ${data['meja']}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Lantai ${data['lantai']}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  tanggal,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('d MMMM yyyy', 'id').format(dateTime);
  }
}
