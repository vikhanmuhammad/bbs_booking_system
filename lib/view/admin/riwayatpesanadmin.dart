import 'package:bbs_booking_system/controller/bookingController.dart';
import 'package:bbs_booking_system/view/admin/detailriwayatpesananadmin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RiwayatPesanAdmin extends StatelessWidget {
  final int meja;

  const RiwayatPesanAdmin({super.key, required this.meja});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pesanan Meja $meja'),
      ),
      body: _readRiwayatPesanan(context, screenWidth),
    );
  }

  Widget _readRiwayatPesanan(BuildContext context, double screenWidth) {
    BookingService _bookingService = BookingService();
    return StreamBuilder(
      stream: _bookingService.getBookingPerMeja(meja),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const Text('Loading...'));
        }
        if (snapshot.hasData) {
          return Container(
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

  Widget _buildRiwayatPesanan(
      DocumentSnapshot doc, BuildContext context, double screenWidth) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String tanggal = formatDate(data['waktuMulai']);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DetailRiwayatPesananAdmin(bookingModel: data)),
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
                  data['userBook'],
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Meja ${data['meja']} Lantai ${data['lantai']}',
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
