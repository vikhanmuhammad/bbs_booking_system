import 'package:flutter/material.dart';
import 'package:bbs_booking_system/controller/aturtutupController.dart'; // Import your controller

class AturTutupAdmin extends StatefulWidget {
  @override
  _AturTutupAdminState createState() => _AturTutupAdminState();
}

class _AturTutupAdminState extends State<AturTutupAdmin> {
  DateTime? selectedDate;
  final StoreController _storeController =
      StoreController(); // Instantiate controller

  void _showAlertDialog(
      String title, String content, IconData icon, Color iconColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: iconColor),
              SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

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
                'Atur Tanggal Libur',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.05,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: SizedBox(
                  width: screenWidth * 0.85,
                  child: ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
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
                        Icon(Icons.calendar_month_outlined),
                        SizedBox(
                          width: screenWidth * 0.02,
                        ),
                        Text(
                          selectedDate != null
                              ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                              : 'Pilih Tanggal',
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
              SizedBox(
                width: screenWidth * 0.85,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedDate == null) {
                      _showAlertDialog(
                        'Warning',
                        'Silahkan pilih tanggal terlebih dahulu',
                        Icons.warning,
                        Colors.red,
                      );
                    } else {
                      await _storeController.setStoreClosedDate(selectedDate!);
                      _showAlertDialog(
                        'Success',
                        'Tanggal libur sudah diatur',
                        Icons.check,
                        Colors.green,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: kuningBBS,
                    elevation: screenWidth * 0.02,
                  ),
                  child: Text(
                    'Atur Libur',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.045,
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
