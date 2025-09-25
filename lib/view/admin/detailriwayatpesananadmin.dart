import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailRiwayatPesananAdmin extends StatefulWidget {
  final Map<String, dynamic> bookingModel;

  const DetailRiwayatPesananAdmin({Key? key, required this.bookingModel})
      : super(key: key);

  @override
  _DetailRiwayatPesananState createState() => _DetailRiwayatPesananState();
}

class _DetailRiwayatPesananState extends State<DetailRiwayatPesananAdmin> {
  @override
  Widget build(BuildContext context) {
    final Color kuningBBS = Color(0xFFFFB600);
    double screenWidth = MediaQuery.of(context).size.width;

    DateTime dateTimeMulai = widget.bookingModel['waktuMulai'].toDate();
    DateTime dateTimeSelesai = widget.bookingModel['waktuSelesai'].toDate();

    int hourMulai = dateTimeMulai.hour;
    int minuteMulai = dateTimeMulai.minute;
    int hourSelesai = dateTimeSelesai.hour;
    int minuteSelesai = dateTimeSelesai.minute;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
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
                              widget.bookingModel['userBook'],
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
                                  'Meja',
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
                                formatDate(widget.bookingModel['waktuMulai']),
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
                                widget.bookingModel['meja'].toString(),
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
                                '${hourMulai.toString().padLeft(2, '0')}:${minuteMulai.toString().padLeft(2, '0')} - ${hourSelesai.toString().padLeft(2, '0')}:${minuteSelesai.toString().padLeft(2, '0')} WIB',
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
                            widget.bookingModel['kodeBooking'],
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
      ),
    );
  }

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('d MMMM yyyy', 'id').format(dateTime);
  }
}
