import 'package:bbs_booking_system/view/admin/aturpembagianjamhargaadmin.dart';
import 'package:bbs_booking_system/view/admin/operasionaladmin.dart';
import 'package:flutter/material.dart';
import 'package:bbs_booking_system/view/admin/aturpaketadmin.dart';

class MenuOperasiAdmin extends StatefulWidget {
  @override
  _MenuOperasiAdminState createState() => _MenuOperasiAdminState();
}

class _MenuOperasiAdminState extends State<MenuOperasiAdmin> {

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final Color yellowColor = Colors.yellow.withOpacity(1);
    final Color kuningBBS = Color(0xFFFFB600);

    return Scaffold(
      backgroundColor: Colors.white,
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
                      height: screenWidth * 0.6,
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
                          width: screenWidth * 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Atur Operasional Toko',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.05,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.04),
                child: SizedBox(
                  width: screenWidth * 0.85,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OperasionalAdmin()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: kuningBBS, width: 2.0),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Atur Waktu Operasional',
                          style: TextStyle(
                            color: kuningBBS,
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.04),
                child: SizedBox(
                  width: screenWidth * 0.85,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AturPaketAdmin()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: kuningBBS, width: 2.0),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Atur Paket',
                          style: TextStyle(
                            color: kuningBBS,
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.04),
                child: SizedBox(
                  width: screenWidth * 0.85,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AturPembagianJamHargaAdmin()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: kuningBBS, width: 2.0),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Atur Pembagian Jam & Harga',
                          style: TextStyle(
                            color: kuningBBS,
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
