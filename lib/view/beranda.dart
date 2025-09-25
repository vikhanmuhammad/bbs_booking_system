import 'package:bbs_booking_system/controller/bookingController.dart';
import 'package:bbs_booking_system/view/chat.dart';
import 'package:bbs_booking_system/view/profilpengguna.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bbs_booking_system/controller/aturtutupController.dart';

class Beranda extends StatefulWidget {
  @override
  _BerandaState createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  final StoreController _storeController = StoreController();
  bool isActive = true;

  int selectedCircleIndex = 0;
  int indexMeja = 0;
  DateTime selectedDate = DateTime.now();
  Map<String, dynamic>? operationalHours;
  String selectedLocation = 'Ruko 1';

  @override
  void initState() {
    super.initState();
    updateCircleData(0);
    _checkStoreStatus();
    _fetchOperationalHours();
  }

  void updateCircleData(int index) {
    setState(() {
      if( selectedLocation != 'Ruko 1'){
        indexMeja = index + 7;
      }else{
        indexMeja = index + 1;
      }
      selectedCircleIndex = index;
    });
  }

  Future<void> _checkStoreStatus() async {
    DateTime? closedDate = await _storeController.getClosedDate();
    DateTime today = DateTime.now();

    setState(() {
      if (closedDate != null &&
          closedDate.year == today.year &&
          closedDate.month == today.month &&
          closedDate.day == today.day) {
        isActive = false; // Toko tutup
      } else {
        isActive = true; // Toko buka
      }
    });
  }

  Future<void> _fetchOperationalHours() async {
    operationalHours = await _storeController.getOperationalHours();
    _updateStoreStatusBasedOnTime();
  }

  void _updateStoreStatusBasedOnTime() async {
    if (operationalHours == null) return;

    // Check if the store is closed today
    DateTime? closedDate = await _storeController.getClosedDate();
    DateTime today = DateTime.now();
    if (closedDate != null &&
        closedDate.year == today.year &&
        closedDate.month == today.month &&
        closedDate.day == today.day) {
      setState(() {
        isActive = false;
      });
      return;
    }

    TimeOfDay openingTime = TimeOfDay(
      hour: operationalHours!['opening_time']['hour'],
      minute: operationalHours!['opening_time']['minute'],
    );
    TimeOfDay closingTime = TimeOfDay(
      hour: operationalHours!['closing_time']['hour'],
      minute: operationalHours!['closing_time']['minute'],
    );

    DateTime now = DateTime.now();
    DateTime openingDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      openingTime.hour,
      openingTime.minute,
    );
    DateTime closingDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      closingTime.hour,
      closingTime.minute,
    );

    setState(() {
      isActive = now.isAfter(openingDateTime) && now.isBefore(closingDateTime);
    });
  }

  Future<Map<String, dynamic>> _getOperationalHours() async {
    if (operationalHours == null) {
      await _fetchOperationalHours();
    }
    return operationalHours!;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final Color kuningBBS = Color(0xFFFFB600);

    User? user = FirebaseAuth.instance.currentUser;
    String fullname = user?.displayName ?? 'User';
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
          Container(
            padding: EdgeInsets.all(screenWidth * 0.06),
            child: Center(
              child: Card(
                color: Color(0xffFFB600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.06),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.03,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: _getOperationalHours(),
                        builder: (BuildContext context,
                            AsyncSnapshot<Map<String, dynamic>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData) {
                            return Text('No data available');
                          }

                          Map<String, dynamic> data = snapshot.data!;
                          TimeOfDay openingTime = TimeOfDay(
                            hour: data['opening_time']['hour'],
                            minute: data['opening_time']['minute'],
                          );
                          TimeOfDay closingTime = TimeOfDay(
                            hour: data['closing_time']['hour'],
                            minute: data['closing_time']['minute'],
                          );

                          String openingTimeStr = openingTime.format(context);
                          String closingTimeStr = closingTime.format(context);

                          return Column(
                            children: [
                              Text(
                                'Jam Operasional',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.006),
                              Container(
                                width: screenWidth * 0.3,
                                height: screenHeight * 0.07,
                                padding: EdgeInsets.all(screenWidth * 0.01),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.02),
                                  color: isActive ? Colors.green : Colors.red,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.2),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    isActive ? 'BUKA' : 'TUTUP',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.07,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.012),
                              Text(
                                '$openingTimeStr - $closingTimeStr',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(width: screenWidth * 0.001),
                      Padding(
                        padding: EdgeInsets.only(
                            right: screenWidth * 0.02,
                            top: screenHeight * 0.02),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: screenHeight * 0.006),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                            receiverUserName: 'Admin',
                                            receiverId:
                                                'w5FW2egaiUXMjmlgxSJbmpF7Jiw1',
                                          )),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(screenWidth * 0.01),
                                minimumSize: Size(
                                    screenWidth * 0.14, screenWidth * 0.14),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.02),
                                ),
                                backgroundColor: Colors.white,
                                elevation: 0,
                              ).copyWith(
                                overlayColor:
                                    MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Color(0xffFFB600).withOpacity(0.1);
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              child: Icon(
                                Icons.chat_rounded,
                                size: screenWidth * 0.08,
                                color: Color(0xffFFB600),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'Chat',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.07, right: screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: screenWidth * 0.13,
                  height: screenWidth * 0.13,
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.035),
                    color: Color(0xffFFB600),
                  ),
                  child: Icon(
                    Icons.queue_outlined,
                    size: screenWidth * 0.075,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: screenWidth * 0.05),
                Text(
                  'Cek antrian meja',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.045),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () => _selectDate(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.006,
                        horizontal: screenWidth * 0.01),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffD9D9D9)),
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01, horizontal: screenWidth * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            DateFormat('dd-MM-yyyy').format(selectedDate),
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Icon(
                            Icons.calendar_today,
                            color: Colors.black,
                            size: screenWidth * 0.06,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xffD9D9D9),
                    width: 1.0,
                  ),
                  borderRadius:
                      BorderRadius.circular(12.0),
                ),
                child: DropdownButton<String>(
                  iconEnabledColor: Colors.black,
                  value: selectedLocation,
                  items: <String>['Ruko 1', 'Ruko 2'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01, horizontal: screenWidth * 0.01),
                        child: Row(
                          children: [
                            Icon(
                              Icons.store,
                              color: Colors.black,
                              size: screenWidth * 0.07,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              value,
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLocation = newValue!;
                    });
                  },
                  underline:
                      SizedBox(),
                ),
              )
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Container(
            height: screenHeight * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => GestureDetector(
                  onTap: () {
                    updateCircleData(index);
                  },
                  child: Container(
                    width: screenWidth * 0.15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedCircleIndex == index
                          ? Color(0xffFFB600)
                          : Colors.black,
                    ),
                    child: Center(
                      child: Text(
                        selectedLocation != 'Ruko 1'
                        ?(index + 7).toString() 
                        :(index + 1).toString(),
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
          Expanded(child: _buildBookingList(context, indexMeja))
        ],
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, int meja) {
    BookingService _bookingService = BookingService();
    return StreamBuilder(
      stream: _bookingService.getBookingPerMeja(meja),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: const Text('Error'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const Text('Loading...'));
        }
        if (snapshot.hasData) {
          return Container(
            height: 250, // Specify a height for the container
            child: ListView(
              scrollDirection: Axis.vertical,
              children: snapshot.data!.docs
                  .map((doc) => _buildBookingItem(doc, context))
                  .toList(),
            ),
          );
        }
        return Center(child: const Text('No data available'));
      },
    );
  }

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('EEEE, d MMMM yyyy', 'id').format(dateTime);
  }

  Widget _buildBookingItem(DocumentSnapshot doc, BuildContext context) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    DateTime dateTimeMulai = data['waktuMulai'].toDate();
    DateTime dateTimeSelesai = data['waktuSelesai'].toDate();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    int hourMulai = dateTimeMulai.hour;
    int minuteMulai = dateTimeMulai.minute;
    int hourSelesai = dateTimeSelesai.hour;
    int minuteSelesai = dateTimeSelesai.minute;

    if (formatDate(data['waktuMulai']) ==
        formatDate(Timestamp.fromDate(selectedDate))) {
      return Padding(
        padding: EdgeInsets.only(bottom: screenHeight * 0.01),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: BoxConstraints(
                minWidth: screenWidth * 0.16,
                minHeight: screenHeight * 0.14,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.015),
                  child: Text(
                    '${hourMulai.toString().padLeft(2, '0')}:${minuteMulai.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.025),
            Container(
              constraints: BoxConstraints(
                minWidth: screenWidth * 0.62,
                minHeight: screenHeight * 0.14,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(data['waktuMulai']),
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${hourMulai.toString().padLeft(2, '0')}:${minuteMulai.toString().padLeft(2, '0')}-${hourSelesai.toString().padLeft(2, '0')}:${minuteSelesai.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      data['kodeBooking'],
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}
