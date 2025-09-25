import 'package:bbs_booking_system/controller/bookingController.dart';
import 'package:bbs_booking_system/controller/paketController.dart';
import 'package:bbs_booking_system/controller/userController.dart';
import 'package:bbs_booking_system/model/bookingModel.dart';
import 'package:bbs_booking_system/controller/aturtutupController.dart';
import 'package:bbs_booking_system/model/paketModel.dart';
import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bbs_booking_system/view/admin/bookingberhasiladmin.dart';

class FormBookingAdmin extends StatefulWidget {
  final BookingModel bookingModel;

  const FormBookingAdmin({
    super.key,
    required this.bookingModel,
  });

  @override
  _FormBookingState createState() => _FormBookingState();
}

class _FormBookingState extends State<FormBookingAdmin> {
  int selectedButtonIndex = 0;

  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  int selectedIndex = -1;
  int? selectedDuration;
  late TextEditingController _clientController = TextEditingController();

  Map<String, dynamic>? operationalHours;
  final StoreController _storeController = StoreController();
  DateTime? closedDate; // Added this line

  @override
  void initState() {
    super.initState();
    _fetchOperationalHours();
    _fetchClosedDate(); // Added this line
  }

  Widget buildPaket(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Instance of PaketController
    PaketController paketController = PaketController();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: paketController.getPaketsWithDocID(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No packages available'));
        }

        List<Map<String, dynamic>> paketList = snapshot.data!;
        if (selectedStartTime == null) {
          return Container();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: paketList.length,
          itemBuilder: (context, index) {
            final packageData = paketList[index]['data'] as Paket;
            final docID = paketList[index]['docID'] as String;
            if (selectedStartTime!.hour + packageData.durasiPaket <=
                operationalHours!['closing_time']['hour']) {
              return ListTile(
                onTap: () {
                  showPackageDialog({
                    'image': packageData.urlImage,
                    'namaPaket': packageData.namaPaket,
                    'durasiPaket': packageData.durasiPaket,
                    'detailPaket': packageData.rincianPaket,
                    'hargaPaket': packageData.hargaPaket,
                    'docID': docID, // Include docID if needed
                  });
                },
                contentPadding: EdgeInsets.all(screenWidth * 0.02),
                leading: Container(
                  width: screenWidth * 0.1,
                  height: screenWidth * 0.1,
                  child: Image.network(packageData.urlImage),
                ),
                title: Text(
                    '${packageData.namaPaket} - ${packageData.durasiPaket} Jam'),
                subtitle: Text(packageData.rincianPaket),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${packageData.hargaPaket}'),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        );
      },
    );
  }

  Future<void> _fetchOperationalHours() async {
    try {
      operationalHours = await _storeController.getOperationalHours();
      setState(() {});
    } catch (e) {
      print('Error fetching operational hours: $e');
    }
  }

  Future<void> _fetchClosedDate() async {
    try {
      closedDate = await _storeController.getClosedDate(); // Added this line
      setState(() {});
    } catch (e) {
      print('Error fetching closed date: $e');
    }
  }

  List<TimeOfDay> _generateTimeList() {
    if (operationalHours == null) return [];

    int openingHour = operationalHours!['opening_time']['hour'];
    int closingHour = operationalHours!['closing_time']['hour'];

    List<TimeOfDay> times = [];
    for (int hour = openingHour; hour < closingHour; hour++) {
      times.add(TimeOfDay(hour: hour, minute: 0));
    }
    return times;
  }

  Timestamp timeOfDayToTimestamp(TimeOfDay time, DateTime date) {
    DateTime dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    return Timestamp.fromDate(dateTime);
  }

  TimeOfDay addHoursToTimeOfDay(TimeOfDay time, int hoursToAdd) {
    int totalMinutes = time.hour * 60 + time.minute + hoursToAdd * 60;
    int newHour = (totalMinutes ~/ 60) % 24;
    int newMinute = totalMinutes % 60;
    return TimeOfDay(hour: newHour, minute: newMinute);
  }

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('d MMMM', 'id').format(dateTime);
  }

  void showPackageDialog(Map<String, dynamic> package) {
    double screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text('${package['namaPaket']} - ${package['durasiPaket']} Jam'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(package['image']),
              SizedBox(height: screenWidth * 0.01),
              Text(package['detailPaket']),
              SizedBox(height: screenWidth * 0.01),
              Text('Harga: ${package['hargaPaket']}'),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffFFB600),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                ),
                elevation: 4.0,
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.025),
                minimumSize: Size(screenWidth * 0.2, screenWidth * 0.05),
              ),
              onPressed: () async {
                if (selectedIndex == -1 || selectedStartTime == null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 10),
                            Text(
                              'Lengkapi Form Booking!',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        content: Text(
                          'Mohon lengkapi form booking!',
                        ),
                        backgroundColor: Color.fromARGB(255, 255, 255, 255),
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
                } else {
                  List<DateTime> dateTimes = [
                    DateTime.now(),
                    DateTime.now().add(Duration(days: 1)),
                    DateTime.now().add(Duration(days: 2))
                  ];
                  DateTime dateTimeMulai =
                      widget.bookingModel.waktuMulai.toDate();
                  int tanggal = dateTimeMulai.day;
                  int bulan = dateTimeMulai.month;
                  int hourMulai = dateTimeMulai.hour;
                  int minuteMulai = dateTimeMulai.minute;
                  widget.bookingModel.waktuMulai = timeOfDayToTimestamp(
                      selectedStartTime!, dateTimes[selectedIndex]);
                  widget.bookingModel.waktuSelesai = timeOfDayToTimestamp(
                    addHoursToTimeOfDay(
                        selectedStartTime!, package['durasiPaket']),
                    dateTimes[selectedIndex],
                  );
                  widget.bookingModel.paket = package['namaPaket'];
                  widget.bookingModel.kodeBooking =
                      'ADMW${hourMulai.toString().padLeft(2, '0')}${minuteMulai.toString().padLeft(2, '0')}${tanggal.toString().padLeft(2, '0')}${bulan.toString().padLeft(2, '0')}';
                  widget.bookingModel.userBook = _clientController.text;
                  BookingService.addToFirestore(
                      context, widget.bookingModel, widget.bookingModel.meja);
                  ProfileService.addBookDataToUserData(
                      context, widget.bookingModel, widget.bookingModel.meja);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => BookingBerhasilAdmin()),
                  );
                }
              },
              child: Text(
                'Pesan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
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

    List<DateTime> dateTimes = [
      DateTime.now(),
      DateTime.now().add(Duration(days: 1)),
      DateTime.now().add(Duration(days: 2))
    ];

    List<String> dates = [
      formatDate(Timestamp.fromDate(dateTimes[0])),
      formatDate(Timestamp.fromDate(dateTimes[1])),
      formatDate(Timestamp.fromDate(dateTimes[2])),
    ];
    final Color kuningBBS = Color(0xFFFFB600);

    List<TimeOfDay> availableTimes = _generateTimeList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  iconSize: screenWidth * 0.08,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(height: screenWidth * 0.03),
                Center(
                  child: Text(
                    'Isi tanggal dan\nwaktu booking',
                    style: TextStyle(
                        fontSize: screenWidth * 0.053,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: screenWidth * 0.05),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.04),
                  child: Text(
                    'Nama client',
                    style: TextStyle(
                        fontSize: screenWidth * 0.042, color: Colors.black),
                  ),
                ),
                SizedBox(height: screenWidth * 0.025),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: TextField(
                    controller: _clientController,
                  ),
                ),
                SizedBox(height: screenWidth * 0.1),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.04),
                  child: Text(
                    'Pilih Tanggal',
                    style: TextStyle(
                        fontSize: screenWidth * 0.042, color: Colors.black),
                  ),
                ),
                SizedBox(height: screenWidth * 0.025),
                Container(
                  height: screenWidth * 0.15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      dates.length,
                      (index) {
                        bool isClosed = closedDate != null &&
                            closedDate!.year == dateTimes[index].year &&
                            closedDate!.month == dateTimes[index].month &&
                            closedDate!.day == dateTimes[index].day;

                        return GestureDetector(
                          onTap: () {
                            if (isClosed) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(Icons.warning, color: Colors.red),
                                        SizedBox(width: 10),
                                        Text(
                                          'Cafe Tutup',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    content: Text(
                                      'Mohon pilih tanggal lain!',
                                    ),
                                    backgroundColor:
                                        Color.fromARGB(255, 255, 255, 255),
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
                            } else {
                              setState(() {
                                selectedIndex = index;
                              });
                            }
                          },
                          child: Container(
                            width: screenWidth * 0.18,
                            margin: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.06),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.03),
                              color: selectedIndex == index
                                  ? kuningBBS
                                  : isClosed
                                      ? Colors.red
                                      : Colors.black,
                            ),
                            child: Center(
                              child: Text(
                                dates[index],
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.1),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.04),
                  child: Text(
                    'Pilih Waktu Mulai',
                    style: TextStyle(
                        fontSize: screenWidth * 0.042, color: Colors.black),
                  ),
                ),
                SizedBox(height: screenWidth * 0.025),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: DropdownButtonFormField<TimeOfDay>(
                    value: selectedStartTime,
                    hint: Text('Pilih Waktu Mulai'),
                    isExpanded: true,
                    items: availableTimes.map((TimeOfDay time) {
                      return DropdownMenuItem<TimeOfDay>(
                        value: time,
                        child: Text(time.format(context)),
                      );
                    }).toList(),
                    onChanged: (TimeOfDay? newTime) {
                      setState(() {
                        selectedStartTime = newTime;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        borderSide: BorderSide(color: kuningBBS, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        borderSide: BorderSide(color: kuningBBS, width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.05),
                Center(
                  child: ToggleButtons(
                    isSelected: [
                      selectedButtonIndex == 0,
                      selectedButtonIndex == 1,
                    ],
                    onPressed: (index) {
                      setState(() {
                        selectedButtonIndex = index;
                      });
                    },
                    children: [
                      Container(
                        width: screenWidth * 0.28,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.01),
                        child: Center(
                          child: Text(
                            'Reguler',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: screenWidth * 0.05,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: screenWidth * 0.28,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.01),
                        child: Center(
                          child: Text(
                            'Paket',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: screenWidth * 0.05,
                            ),
                          ),
                        ),
                      ),
                    ],
                    selectedColor: Colors.white,
                    color: Colors.black,
                    fillColor: kuningBBS,
                    borderRadius: BorderRadius.circular(20),
                    borderWidth: 2,
                    borderColor: Colors.transparent,
                  ),
                ),
                selectedButtonIndex == 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenWidth * 0.05),
                          Padding(
                            padding: EdgeInsets.only(left: screenWidth * 0.04),
                            child: Text(
                              'Durasi (Jam)',
                              style: TextStyle(
                                  fontSize: screenWidth * 0.042,
                                  color: Colors.black),
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.025),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04),
                            child: DropdownButtonFormField<int>(
                              value: selectedDuration,
                              hint: Text('Pilih Durasi'),
                              isExpanded: true,
                              items: List.generate(5, (index) => index + 1)
                                  .map((int duration) {
                                return DropdownMenuItem<int>(
                                  value: duration,
                                  child: Text('$duration jam'),
                                );
                              }).toList(),
                              onChanged: (int? newDuration) {
                                setState(() {
                                  selectedDuration = newDuration;
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.03),
                                  borderSide:
                                      BorderSide(color: kuningBBS, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.03),
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.03),
                                  borderSide:
                                      BorderSide(color: kuningBBS, width: 2),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.1),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenWidth * 0.04),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xffFFB600),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.04),
                                ),
                                elevation: 4.0,
                                padding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.025),
                                minimumSize: Size(
                                    screenWidth - (screenWidth * 0.08),
                                    screenWidth * 0.125),
                              ),
                              onPressed: () {
                                if (selectedIndex == -1 ||
                                    selectedStartTime == null ||
                                    selectedDuration == null) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Row(
                                          children: [
                                            Icon(Icons.warning,
                                                color: Colors.red),
                                            SizedBox(width: 10),
                                            Text(
                                              'Lengkapi Form Booking!',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                        content: Text(
                                          'Mohon lengkapi form booking!',
                                        ),
                                        backgroundColor:
                                            Color.fromARGB(255, 255, 255, 255),
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
                                } else {
                                  DateTime dateTimeMulai =
                                      widget.bookingModel.waktuMulai.toDate();
                                  int tanggal = dateTimeMulai.day;
                                  int bulan = dateTimeMulai.month;
                                  int hourMulai = dateTimeMulai.hour;
                                  int minuteMulai = dateTimeMulai.minute;
                                  widget.bookingModel.waktuMulai =
                                      timeOfDayToTimestamp(selectedStartTime!,
                                          dateTimes[selectedIndex]);
                                  widget.bookingModel.waktuSelesai =
                                      timeOfDayToTimestamp(
                                    addHoursToTimeOfDay(
                                        selectedStartTime!, selectedDuration!),
                                    dateTimes[selectedIndex],
                                  );
                                  widget.bookingModel.kodeBooking =
                                      'ADMW${hourMulai.toString().padLeft(2, '0')}${minuteMulai.toString().padLeft(2, '0')}${tanggal.toString().padLeft(2, '0')}${bulan.toString().padLeft(2, '0')}';
                                  widget.bookingModel.userBook =
                                      _clientController.text;
                                  BookingService.addToFirestore(
                                      context,
                                      widget.bookingModel,
                                      widget.bookingModel.meja);
                                  ProfileService.addBookDataToUserData(
                                      context,
                                      widget.bookingModel,
                                      widget.bookingModel.meja);
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BookingBerhasilAdmin()),
                                  );
                                }
                              },
                              child: Center(
                                child: Text(
                                  'Pesan',
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.053,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : buildPaket(context)
                // ListView.builder(
                //     shrinkWrap: true,
                //     physics: NeverScrollableScrollPhysics(),
                //     itemCount: packages.length,
                //     itemBuilder: (context, index) {
                //       final package = packages[index];
                //       return ListTile(
                //         onTap: () {
                //           showPackageDialog(package);
                //         },
                //         contentPadding: EdgeInsets.all(screenWidth * 0.02),
                //         leading: Container(
                //           width: screenWidth * 0.1,
                //           height: screenWidth * 0.1,
                //           child: Image.network(package['image']),
                //         ),
                //         title: Text(
                //             '${package['namaPaket']} - ${package['durasiPaket']} Jam'),
                //         subtitle: Text(package['detailPaket']),
                //         trailing: Row(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             Text(package['hargaPaket']),
                //             Icon(Icons.arrow_forward_ios),
                //           ],
                //         ),
                //       );
                //     },
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
