import 'package:bbs_booking_system/controller/bookingController.dart';
import 'package:bbs_booking_system/controller/clockpriceController.dart';
import 'package:bbs_booking_system/controller/notification_service.dart';
import 'package:bbs_booking_system/controller/userController.dart';
import 'package:bbs_booking_system/model/bookingModel.dart';
import 'package:bbs_booking_system/model/clockpriceModel.dart';
import 'package:bbs_booking_system/services/token_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'bookingBerhasil.dart'; // Import the bookingBerhasil page

class DetailBooking extends StatefulWidget {
  final BookingModel bookingModel;
  final String selectedPackageName;
  final String selectedPackagePrice;
  final String selectedPackageHours;


  const DetailBooking({
    Key? key,
    required this.selectedPackageName,
    required this.bookingModel,
    required this.selectedPackagePrice,
    required this.selectedPackageHours
    // Add other required parameters here
  }) : super(key: key);

  @override
  _DetailBookingState createState() => _DetailBookingState();
}

class _DetailBookingState extends State<DetailBooking> {
  late final MidtransSDK? _midtrans;
  final TokenService _tokenService = TokenService();
  final ClockPriceController _clockPriceController = ClockPriceController();

  bool isMember = false;
  List<Map<String, dynamic>> paymentDetails = [];
  double totalPayment = 0.0;

  @override
  void initState() {
    super.initState();
    _initSDK();
    _checkMembershipStatus(); // Check if the user is a member
    _loadPaymentDetails(); // Call the new method to load payment details
  }

  void _loadPaymentDetails() async {
    var paymentData = await _calculateTotalPayment();

    setState(() {
      paymentDetails = paymentData['details'] as List<Map<String, dynamic>>;
      totalPayment = paymentData['totalPayment'] as double;
    });
  }

  void _initSDK() async {
    await dot_env.dotenv.load();
    _midtrans = await MidtransSDK.init(
      config: MidtransConfig(
        clientKey: dot_env.dotenv.env['MIDTRANS_CLIENT_KEY'] ?? "",
        merchantBaseUrl: dot_env.dotenv.env['BASE_URL'] ?? "",
        colorTheme: ColorTheme(
          colorPrimary: Colors.blue,
          colorPrimaryDark: Colors.blue,
          colorSecondary: Colors.blue,
        ),
      ),
    );
    _midtrans?.setUIKitCustomSetting(skipCustomerDetailsPages: true);
    _midtrans?.setTransactionFinishedCallback((result) async {
      try {
        if (result.transactionStatus == TransactionResultStatus.settlement ||
            result.transactionStatus == TransactionResultStatus.capture ||
            result.transactionStatus == TransactionResultStatus.expire) {
          User? user = FirebaseAuth.instance.currentUser;
          String fullname = user?.displayName ?? 'User';
          widget.bookingModel.userBook = fullname;

          // Set payment status and method
          widget.bookingModel.statusBayar = result.transactionStatus != TransactionResultStatus.expire;
          widget.bookingModel.metodeBayar = result.paymentType ?? 'Unknown';

          // Save the booking to Firestore
          await BookingService.addToFirestore(
              context, widget.bookingModel, widget.bookingModel.meja);

          ProfileService.addBookDataToUserData(
              context, widget.bookingModel, widget.bookingModel.meja);

          DateTime waktuMulai = widget.bookingModel.waktuMulai.toDate();
          DateTime waktuSelesai = widget.bookingModel.waktuSelesai.toDate();

          // Schedule notification 5 minutes before the booking start time
          NotificationService.scheduleNotification(
            1,
            'Booking Reminder',
            'Meja anda sebentar lagi siap, mohon ke meja resepsionis',
            waktuMulai.subtract(Duration(minutes: 5)),
          );

          // Schedule notification 5 minutes before the booking end time
          NotificationService.scheduleNotification(
            2,
            'Booking Reminder',
            'Waktu main anda hanya tersisa 5 menit.',
            waktuSelesai.subtract(Duration(minutes: 5)),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BookingBerhasil()),
            (Route<dynamic> route) => false,
          );
        } else {
          print("Transaksi Failed, pembayaran belum di lakukan");
          _showToast('Transaksi gagal, mohon lengkapi pembayaran', true);
        }
      } catch (e) {
        _showToast('An error occurred: $e', true);
      }
    });
  }


  void _checkMembershipStatus() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

      setState(() {
        if (userData.exists && userData.data() != null) {
          Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
          isMember = data.containsKey('isMember') ? data['isMember'] : true;
        } else {
          isMember = false; // Default to false if the field doesn't exist
        }
      });
    }
  }
  
  void _showToast(String msg, bool isError) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: isError ? Colors.red : Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  void dispose() {
    _midtrans?.removeTransactionFinishedCallback();
    super.dispose();
  }

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('EEEE, d MMMM yyyy', 'id').format(dateTime);
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'id');
    return formatter.format(amount);
  }

  Future<Map<String, dynamic>> _calculateTotalPayment() async {
  DateTime start = widget.bookingModel.waktuMulai.toDate();
  DateTime end = widget.bookingModel.waktuSelesai.toDate();

  double totalPayment = 0.0;
  List<Map<String, dynamic>> details = [];

  // Check if a package has been selected
  if (widget.selectedPackageName.isNotEmpty) {
    // Directly use the package price
    totalPayment = double.parse(widget.selectedPackagePrice);

    // Add package details to the list
    details.add({
      'category': widget.selectedPackageName,
      'duration': widget.selectedPackageHours,
      'price': totalPayment,
    });
  } else {
    // Get the clock prices and regular price if no package is selected
    List<ClockPrice> clockPrices = await _clockPriceController.getClockPricesList();
    int regularPrice = await _clockPriceController.getRegularPrice();

    // Loop through the booking time and calculate the total payment
    for (DateTime current = start;
        current.isBefore(end);
        current = current.add(Duration(hours: 1))) {
      ClockPrice? applicablePrice = clockPrices.firstWhere(
        (cp) {
          DateTime cpStart = cp.start.toDate();
          DateTime cpEnd = cp.end.toDate();
          return current.hour >= cpStart.hour && current.hour < cpEnd.hour;
        },
        orElse: () => ClockPrice(
          nama: 'Regular',
          start: Timestamp.now(),
          end: Timestamp.now(),
          durasi: 1,
          price: regularPrice,
        ),
      );

      double price = applicablePrice.price.toDouble();

      if (applicablePrice.nama == 'Happy Hour' && isMember) {
        price *= 0.5; // 50% discount for members during Happy Hour
      }

      totalPayment += price;

      int idx = -1;
      int adayangsama = 0;
      for (Map<String, dynamic> masuk in details) {
        if (masuk['category'] == applicablePrice.nama) {
          idx = adayangsama;
        }
        adayangsama++;
      }

      if (idx == -1) {
        details.add({
          'category': applicablePrice.nama,
          'duration': 1, // Duration in hours
          'price': price,
        });
      } else {
        details[idx]['duration']++;
      }
    }
  }

  return {
    'details': details,
    'totalPayment': totalPayment,
  };
}


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    DateTime dateTimeMulai = widget.bookingModel.waktuMulai.toDate();
    DateTime dateTimeSelesai = widget.bookingModel.waktuSelesai.toDate();

    int tanggal = dateTimeMulai.day;
    int bulan = dateTimeMulai.month;
    int tahun = dateTimeMulai.year;
    int hourMulai = dateTimeMulai.hour;
    int minuteMulai = dateTimeMulai.minute;
    int hourSelesai = dateTimeSelesai.hour;
    int minuteSelesai = dateTimeSelesai.minute;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        iconSize: screenWidth * 0.08,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(width: screenWidth * 0.15),
                      Text(
                        'Detail Booking',
                        style: TextStyle(fontSize: screenWidth * 0.053, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            child: Container(
                              width: screenWidth,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: screenWidth * 0.085,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Text(
                                          'Tanggal',
                                          style: TextStyle(fontSize: screenWidth * 0.04, color: Color(0xff969696)),
                                        ),
                                        SizedBox(width: screenWidth * 0.16),
                                        Container(
                                          width: screenWidth * 0.25,
                                          child: Text(
                                            formatDate(widget.bookingModel.waktuMulai),
                                            style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.black),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenWidth * 0.0375),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.table_restaurant_outlined,
                                          size: screenWidth * 0.085,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: screenWidth * 0.03),
                                        Text(
                                          'Meja',
                                          style: TextStyle(fontSize: screenWidth * 0.04, color: Color(0xff969696)),
                                        ),
                                        SizedBox(width: screenWidth * 0.2),
                                        Text(
                                          'Meja ${widget.bookingModel.meja}, lantai ${widget.bookingModel.lantai}',
                                          style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.black),
                                          textAlign: TextAlign.end,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenWidth * 0.0375),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: screenWidth * 0.085,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: screenWidth * 0.06),
                                        Text(
                                          'Waktu',
                                          style: TextStyle(fontSize: screenWidth * 0.04, color: Color(0xff969696)),
                                        ),
                                        Expanded(child: SizedBox(width: screenWidth * 0.262)),
                                        Text(
                                          '${hourMulai.toString().padLeft(2, '0')}:${minuteMulai.toString().padLeft(2, '0')}-${hourSelesai.toString().padLeft(2, '0')}:${minuteSelesai.toString().padLeft(2, '0')}',
                                          style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.black),
                                          textAlign: TextAlign.end,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: _calculateTotalPayment(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else if (snapshot.hasData) {
                                var paymentData = snapshot.data!;
                                var paymentDetails = paymentData['details'] as List<Map<String, dynamic>>;
                                double totalPayment = paymentData['totalPayment'] as double;
                                return Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.04),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: screenWidth,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(screenWidth * 0.04),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Ringkasan Pembayaran',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: screenWidth * 0.02),
                                              if (widget.selectedPackageName.isNotEmpty)
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Paket',
                                                        style: TextStyle(
                                                          fontSize: screenWidth * 0.035,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        '${widget.selectedPackageName} - ${widget.selectedPackageHours} jam - Rp${formatCurrency(double.parse(widget.selectedPackagePrice))}',
                                                        textAlign: TextAlign.end,
                                                        style: TextStyle(
                                                          fontSize: screenWidth * 0.035,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              SizedBox(height: screenWidth * 0.02),
                                              if (widget.selectedPackageName.isEmpty)
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: NeverScrollableScrollPhysics(),
                                                  itemCount: paymentDetails.length,
                                                  itemBuilder: (context, index) {
                                                    final detail = paymentDetails[index];
                                                    return Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            detail['category'],
                                                            style: TextStyle(
                                                              fontSize: screenWidth * 0.035,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            '${detail['duration']} jam x Rp${formatCurrency(detail['price'])}',
                                                            textAlign: TextAlign.end,
                                                            style: TextStyle(
                                                              fontSize: screenWidth * 0.035,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              SizedBox(height: screenWidth * 0.125),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'Total Pembayaran',
                                                    style: TextStyle(
                                                      fontSize: screenWidth * 0.035,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  widget.selectedPackageName.isNotEmpty
                                                      ? Text(
                                                          'Rp${formatCurrency(double.parse(widget.selectedPackagePrice))}',
                                                          style: TextStyle(
                                                            fontSize: screenWidth * 0.035,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.black,
                                                          ),
                                                        )
                                                      : Text(
                                                          'Rp${formatCurrency(totalPayment)}',
                                                          style: TextStyle(
                                                            fontSize: screenWidth * 0.035,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Spacer(),  // Menambahkan Spacer untuk mengisi ruang yang tersedia dan mendorong tombol ke bawah
                                    ],
                                  ),
                                );
                              }
                              return Center(child: Text('Tidak ada data.'));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: screenWidth * 0.425,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
            Stack(
              children: [
                Positioned(
                  bottom: screenWidth * 0.33,
                  left: screenWidth * 0.085,
                  child: Text(
                    'Harga',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Positioned(
                  bottom: screenWidth * 0.25,
                  left: screenWidth * 0.085,
                  child: Text(
                    widget.selectedPackageName.isNotEmpty
                        ? 'Rp${formatCurrency(double.parse(widget.selectedPackagePrice))}'
                        : 'Rp${formatCurrency(totalPayment)}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.053,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: screenWidth * 0.08,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFFB600),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  elevation: 4.0,
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.025),
                ),
                onPressed: () async {
                  widget.bookingModel.kodeBooking = 'M${widget.bookingModel.meja}L${widget.bookingModel.lantai}W${hourMulai.toString().padLeft(2, '0')}T${tanggal.toString().padLeft(2, '0')}${bulan.toString().padLeft(2, '0')}${tahun.toString().substring(2)}';
                  var result = await _tokenService.getToken(productName: "Booking Meja",totalPayment: totalPayment, id: widget.bookingModel.kodeBooking);
                  result.fold(
                    (failure) => _showToast(failure.message, true),
                    (tokenModel) {
                      _midtrans?.startPaymentUiFlow(token: tokenModel.token);
                    },
                  );
                },
                child: Text(
                  'Pilih Pembayaran',
                  style: TextStyle(fontSize: screenWidth * 0.053, fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}