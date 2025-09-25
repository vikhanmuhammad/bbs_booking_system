import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OperasionalAdmin extends StatefulWidget {
  @override
  _OperasionalAdminState createState() => _OperasionalAdminState();
}

class _OperasionalAdminState extends State<OperasionalAdmin> {
  TimeOfDay? selectedOpeningTime;
  TimeOfDay? selectedClosingTime;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showIncompleteDataAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Data Belum Lengkap',
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          ),
          content: Text('Silakan pilih waktu buka dan waktu tutup.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Waktu Operasional Diatur',
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          ),
          content: Text('Waktu operasional telah berhasil diatur.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveOperationalTimes() async {
    if (selectedOpeningTime == null || selectedClosingTime == null) {
      _showIncompleteDataAlert();
      return;
    }

    try {
      await _firestore.collection('store').doc('operational_hours').set({
        'opening_time': {
          'hour': selectedOpeningTime!.hour,
          'minute': selectedOpeningTime!.minute,
        },
        'closing_time': {
          'hour': selectedClosingTime!.hour,
          'minute': selectedClosingTime!.minute,
        },
      });

      _showSuccessAlert();
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 10),
                Text('Error'),
              ],
            ),
            content: Text('Gagal menyimpan data: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final Color yellowColor = Colors.yellow.withOpacity(1);
    final Color kuningBBS = Color(0xFFFFB600);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: SizedBox(
                  width: screenWidth * 0.85,
                  child: ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedOpeningTime ?? TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedOpeningTime = pickedTime;
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
                        Icon(Icons.timelapse),
                        SizedBox(
                          width: screenWidth * 0.02,
                        ),
                        Text(
                          selectedOpeningTime != null
                              ? 'Buka : ' + selectedOpeningTime!.format(context)
                              : 'Waktu Buka',
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
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedClosingTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedClosingTime = pickedTime;
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
                      Icon(Icons.timelapse),
                      SizedBox(
                        width: screenWidth * 0.02,
                      ),
                      Text(
                        selectedClosingTime != null
                            ? 'Tutup : ' + selectedClosingTime!.format(context)
                            : 'Waktu Tutup',
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
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.05),
                child: SizedBox(
                  width: screenWidth * 0.85,
                  child: ElevatedButton(
                    onPressed: _saveOperationalTimes,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: kuningBBS,
                      elevation: screenWidth * 0.02,
                    ),
                    child: Text(
                      'Atur Waktu Operasional',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.045,
                      ),
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
