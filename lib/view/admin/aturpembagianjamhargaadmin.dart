import 'dart:async';

import 'package:bbs_booking_system/controller/clockpriceController.dart';
import 'package:bbs_booking_system/model/clockpriceModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bbs_booking_system/controller/aturtutupController.dart';
import 'package:intl/intl.dart';

class AturPembagianJamHargaAdmin extends StatefulWidget {
  @override
  _AturPembagianJamHargaAdminState createState() =>
      _AturPembagianJamHargaAdminState();
}

class _AturPembagianJamHargaAdminState
    extends State<AturPembagianJamHargaAdmin> {
  final StoreController _storeController = StoreController();
  Map<String, dynamic>? operationalHours;
  bool isActive = true;
  List<String> timeSlots = [];
  List<String> duraSlots = [];
  String? selectedTimeSlot;
  String? selectedStartTime;
  String? selectedEndTime;
  String? selectedPrice;

  @override
  void initState() {
    super.initState();
    _fetchOperationalHours();
  }

  Future<void> _fetchOperationalHours() async {
    operationalHours = await _storeController.getOperationalHours();
    _updateStoreStatusBasedOnTime();
    if (operationalHours != null) {
      _generateTimeSlots();
      _generateDuraSlots();
    }
  }

  void _updateStoreStatusBasedOnTime() async {
    if (operationalHours == null) return;

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
  }

  Future<Map<String, dynamic>> _getOperationalHours() async {
    if (operationalHours == null) {
      await _fetchOperationalHours();
    }
    return operationalHours!;
  }

  void _generateTimeSlots() {
    if (operationalHours == null) return;

    TimeOfDay openingTime = TimeOfDay(
      hour: operationalHours!['opening_time']['hour'],
      minute: operationalHours!['opening_time']['minute'],
    );
    TimeOfDay closingTime = TimeOfDay(
      hour: operationalHours!['closing_time']['hour'],
      minute: operationalHours!['closing_time']['minute'],
    );

    List<String> slots = [];
    TimeOfDay currentTime = openingTime;

    while (_isBeforeOrEqual(currentTime, closingTime)) {
      slots.add(_formatTimeOfDay(currentTime));
      currentTime = _addHour(currentTime);
    }

    setState(() {
      timeSlots = slots;
      selectedTimeSlot = timeSlots.isNotEmpty ? timeSlots[0] : null;
    });
  }

  void _generateDuraSlots() {
    if (operationalHours == null) return;

    TimeOfDay openingTime = TimeOfDay(
      hour: operationalHours!['opening_time']['hour'],
      minute: operationalHours!['opening_time']['minute'],
    );
    TimeOfDay closingTime = TimeOfDay(
      hour: operationalHours!['closing_time']['hour'],
      minute: operationalHours!['closing_time']['minute'],
    );

    List<String> slots = [];
    TimeOfDay currentTime = openingTime;
    int count = 0;

    while (_isBeforeOrEqual(currentTime, closingTime)) {
      count++;
      slots.add(count.toString() + ' Jam');
      currentTime = _addHour(currentTime);
    }

    setState(() {
      duraSlots = slots;
      selectedTimeSlot = timeSlots.isNotEmpty ? timeSlots[0] : null;
    });
  }

  bool _isBeforeOrEqual(TimeOfDay a, TimeOfDay b) {
    return a.hour < b.hour || (a.hour == b.hour && a.minute <= b.minute);
  }

  TimeOfDay _addHour(TimeOfDay time) {
    int newHour = time.hour + 1;
    return TimeOfDay(hour: newHour, minute: time.minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final format = MaterialLocalizations.of(context).formatTimeOfDay(time);
    return format;
  }

  void _showAddCategoryDialog() {
    String? selectedStartTime;
    String? selectedEndTime;
    String categoryName = '';
    String price = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Kategori'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Nama Kategori'),
                  onChanged: (value) {
                    categoryName = value;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedStartTime,
                  hint: Text('Pilih Jam Awal'),
                  items: timeSlots
                      .map((time) => DropdownMenuItem(
                            value: time,
                            child: Text(time),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStartTime = value;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedEndTime,
                  hint: Text('Pilih Durasi'),
                  items: duraSlots
                      .map((time) => DropdownMenuItem(
                            value: time,
                            child: Text(time),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedEndTime = value;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    price = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedStartTime != null &&
                    selectedEndTime != null &&
                    categoryName.isNotEmpty &&
                    price.isNotEmpty) {
                  int idxstart = timeSlots.indexOf(selectedStartTime!);
                  int idxdura = duraSlots.indexOf(selectedEndTime!);
                  DateTime start = DateTime(
                      2000,
                      1,
                      1,
                      operationalHours!['opening_time']['hour'] + idxstart,
                      00,
                      1);
                  DateTime end = DateTime(
                      2000,
                      1,
                      1,
                      operationalHours!['opening_time']['hour'] +
                          idxstart +
                          idxdura +
                          1,
                      00);
                  ClockPrice cp = ClockPrice(
                      nama: categoryName,
                      start: Timestamp.fromDate(start),
                      end: Timestamp.fromDate(end),
                      durasi: idxdura + 1,
                      price: int.parse(price));
                  ClockPriceController cpc = ClockPriceController();

                  // Pass context to the addClockPrice method
                  cpc.addClockPrice(cp, context);
                }
              },
              child: Text('Simpan Kategori'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(ClockPrice cp, String id) {
    String? selectedStartTime = hourFormat(cp.start);
    String? selectedEndTime = hourFormat(cp.end);
    String categoryName = cp.nama;
    String price = cp.price.toString();
    DateTime startDateTime = cp.start.toDate();
    DateTime endDateTime = cp.end.toDate();

    int difference = endDateTime.hour - startDateTime.hour;
    TextEditingController namcon = TextEditingController();
    TextEditingController pricecon = TextEditingController();
    namcon.text = cp.nama;
    pricecon.text = cp.price.toString();

    ClockPrice updated = cp;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Kategori'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Nama Kategori'),
                  controller: namcon,
                  onChanged: (value) {
                    updated.nama = value;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: timeSlots.contains(selectedStartTime)
                      ? selectedStartTime
                      : null, // Ensure selectedStartTime exists in timeSlots
                  hint: Text(hourFormat(cp.start)),
                  items: timeSlots
                      .map((time) => DropdownMenuItem(
                            value: time,
                            child: Text(time),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStartTime = value;
                      int idxstart = timeSlots.indexOf(selectedStartTime!);
                      DateTime start = DateTime(
                          2000,
                          1,
                          1,
                          operationalHours!['opening_time']['hour'] + idxstart,
                          00,
                          1);
                      updated.start = Timestamp.fromDate(start);
                      updated.durasi = difference;
                      DateTime end = DateTime(2000, 1, 1,
                          updated.start.toDate().hour + updated.durasi, 00);
                      updated.end = Timestamp.fromDate(end);
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  value: duraSlots.contains(selectedEndTime)
                      ? selectedEndTime
                      : null, // Ensure selectedEndTime exists in duraSlots
                  hint: Text((difference).toString() + ' Jam'),
                  items: duraSlots
                      .map((time) => DropdownMenuItem(
                            value: time,
                            child: Text(time),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedEndTime = value;
                      int idxdura = duraSlots.indexOf(selectedEndTime!);
                      DateTime end = DateTime(2000, 1, 1,
                          updated.start.toDate().hour + idxdura + 1, 00);
                      updated.end = Timestamp.fromDate(end);
                      updated.durasi = end.hour - updated.start.toDate().hour;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Harga'),
                  keyboardType:
                      TextInputType.number, // Hanya angka yang diperbolehkan
                  controller: pricecon,
                  onChanged: (value) {
                    // Tambahkan logika untuk memvalidasi input jika diperlukan
                    price = value;
                    updated.price = int.parse(value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedStartTime != null &&
                    selectedEndTime != null &&
                    categoryName.isNotEmpty &&
                    price.isNotEmpty) {
                  ClockPriceController cpc = ClockPriceController();
                  cpc.updateClockPrice(
                      id, updated, context); // Pass context here
                }
              },
              child: Text('Simpan'),
            ),
            TextButton(
              onPressed: () {
                ClockPriceController cpc = ClockPriceController();
                cpc.deleteClockPrice(id);
                Navigator.of(context).pop();
              },
              child: Text('Hapus'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _showEditRegPriceDialog(int current) {
    TextEditingController namcon = TextEditingController();
    namcon.text = current.toString();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Harga Reguler'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Harga Reguler',
                  ),
                  keyboardType: TextInputType.number,
                  controller: namcon,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (namcon.text != '') {
                  StoreController sc = StoreController();
                  sc.setRegularPrice(int.parse(namcon.text));
                }
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final Color kuningBBS = Color(0xFFFFB600);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Atur Jam & Harga",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          buildReguler(context),
          Padding(
              padding: EdgeInsets.only(
                  top: screenWidth * 0.355,
                  bottom: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                  left: screenWidth * 0.05),
              child: buildClocklist()),
          Container(
            decoration: BoxDecoration(
              color: kuningBBS,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 38, 38, 38).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder<Map<String, dynamic>>(
                    future: _getOperationalHours(),
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, dynamic>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jam Operasional : $openingTimeStr - $closingTimeStr',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: screenWidth * 0.075,
            right: screenWidth * 0.075,
            child: FloatingActionButton(
              onPressed: _showAddCategoryDialog,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReguler(BuildContext context) {
    StoreController sc = StoreController();
    double screenWidth = MediaQuery.of(context).size.width;
    final Color kuningBBS = Color(0xFFFFB600);
    return FutureBuilder<int?>(
      future: sc.getRegularPrice(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading spinner while waiting for data
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Display error message
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text(
              'No price available'); // Handle case where no data is returned
        }
        // Display the regular price
        int regularPrice = snapshot.data!;
        return Padding(
          padding: EdgeInsets.only(
              top: screenWidth * 0.185,
              bottom: screenWidth * 0.05,
              right: screenWidth * 0.05,
              left: screenWidth * 0.05),
          child: SizedBox(
            width: screenWidth * 0.85,
            child: ElevatedButton(
              onPressed: () {
                _showEditRegPriceDialog(regularPrice);
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
                  Icon(Icons.monetization_on_outlined),
                  SizedBox(
                    width: screenWidth * 0.02,
                  ),
                  Text(
                    'Harga Reguler : Rp' + regularPrice.toString(),
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
        );
      },
    );
  }

  Widget buildClocklist() {
    ClockPriceController cpc = ClockPriceController();
    return StreamBuilder<QuerySnapshot>(
      stream: cpc.getClockPrices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available'));
        }

        final clockPrices = snapshot.data!.docs.map((doc) {
          final clockPrice =
              ClockPrice.fromMap(doc.data() as Map<String, dynamic>);
          final docId = doc.id; // Get the document ID
          return {'clockPrice': clockPrice, 'docId': docId};
        }).toList();

        return ListView.builder(
          itemCount: clockPrices.length,
          itemBuilder: (context, index) {
            final category = clockPrices[index]['clockPrice'] as ClockPrice;
            final docId = clockPrices[index]['docId'] as String;

            return GestureDetector(
              onTap: () {
                _showEditCategoryDialog(category, docId); // Pass the docId
              },
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                child: ListTile(
                  title: Text(category.nama),
                  subtitle: Text(
                      '${hourFormat(category.start)} s.d. ${hourFormat(category.end)} - Rp${category.price}'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String hourFormat(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('HH:mm').format(dateTime);
  }
}
