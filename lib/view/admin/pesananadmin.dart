import 'package:bbs_booking_system/view/admin/riwayatpesanadmin.dart';
import 'package:flutter/material.dart';

class PesananAdmin extends StatefulWidget {
  @override
  _PesananAdminState createState() => _PesananAdminState();
}

class _PesananAdminState extends State<PesananAdmin> {
  int selectedButtonIndex = 0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final Color kuningBBS = Color(0xFFFFB600);

    List<int> tableNumbers;
    if (selectedButtonIndex == 0) {
      tableNumbers = [1, 2, 3, 4, 5, 6];
    } else {
      tableNumbers = [7, 8, 9, 10, 11, 12];
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.04),
              child: Center(
                child: Text(
                  'Pilih meja mana yang\ningin anda lihat',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
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
                            'Ruko 1',
                            style: TextStyle(
                              fontWeight: selectedButtonIndex == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: screenWidth * 0.038,
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
                            'Ruko 2',
                            style: TextStyle(
                              fontWeight: selectedButtonIndex == 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: screenWidth * 0.038,
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
            Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.11,
                top: screenHeight * 0.05,
                bottom: screenHeight * 0.01,
              ),
              child: Text(
                'Lantai 1',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildElevatedButton(
                    context, 1, tableNumbers[0], screenWidth),
                _buildElevatedButton(
                    context, 1, tableNumbers[1], screenWidth),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.11,
                top: screenHeight * 0.07,
                bottom: screenHeight * 0.01,
              ),
              child: Text(
                'Lantai 2',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildElevatedButton(
                    context, 2, tableNumbers[2], screenWidth),
                _buildElevatedButton(
                    context, 2, tableNumbers[3], screenWidth),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.11,
                top: screenHeight * 0.07,
                bottom: screenHeight * 0.01,
              ),
              child: Text(
                'Lantai 3',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildElevatedButton(
                    context, 3, tableNumbers[4], screenWidth),
                _buildElevatedButton(
                    context, 3, tableNumbers[5], screenWidth),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildElevatedButton(
      BuildContext context, int lantai, int meja, double screenWidth) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RiwayatPesanAdmin(
                    meja: meja,
                  )),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(screenWidth * 0.015),
        minimumSize: Size(screenWidth * 0.22, screenWidth * 0.22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          side: BorderSide(color: Color(0xFFFFB600), width: 2),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed))
              return Color(0xffFFB600).withOpacity(0.1);
            return null;
          },
        ),
      ),
      child: Text(
        meja.toString(),
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
