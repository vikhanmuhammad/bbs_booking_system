import 'package:flutter/material.dart';
import 'package:bbs_booking_system/services/token_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'bookingBerhasil.dart';
import 'package:flutter/services.dart';

class GabungMember extends StatefulWidget {
  @override
  _GabungMemberState createState() => _GabungMemberState();
}

class _GabungMemberState extends State<GabungMember> {
  late final MidtransSDK? _midtrans;
  final TokenService _tokenService = TokenService();
  final TextEditingController _phoneController = TextEditingController();
  bool _isMember = false; // Variable to track membership status

  @override
  void initState() {
    super.initState();
    _checkMembershipStatus(); // Check membership status when the widget is initialized
    _initSDK();
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
            result.transactionStatus == TransactionResultStatus.capture) {
          // Mengambil user ID dari user yang sedang login
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Mengupdate status member di Firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'member': true});

            _showToast('Membership updated successfully!', false);

            // Menavigasi ke halaman BookingBerhasil
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => BookingBerhasil()),
              (Route<dynamic> route) => false,
            );
          } else {
            _showToast('User is not logged in', true);
          }
        } else {
          print("Transaksi gagal");
          _showToast('Transaction Failed', true);
        }
      } catch (e) {
        _showToast('An error occurred: $e', true);
      }
    });
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

  void _checkMembershipStatus() async {
    // Mengambil UID dari user yang sedang login
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Mengambil status member dari Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Check if the document exists and contains the 'member' field
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _isMember =
              userData.containsKey('member') ? userData['member'] : false;
        });
      } else {
        setState(() {
          _isMember =
              false; // Set default value if document or field is missing
        });
      }
    }
  }

  void _showPhoneNumberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Masukkan Nomor HP"),
          content: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(14),
              _PhoneNumberFormatter(),
            ],
            decoration: InputDecoration(
              hintText: "Nomor HP",
              errorText: _phoneController.text.length >= 7
                  ? null
                  : 'Nomor harus minimal 7 digit',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Batal"),
              onPressed: () {
                _phoneController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Lanjut"),
              onPressed: () async {
                String phone = _phoneController.text.replaceAll(' ', '');

                // Validasi nomor HP minimal 7 digit
                if (phone.length >= 7) {
                  // Validasi nomor HP tidak kosong
                  if (_phoneController.text.isNotEmpty) {
                    // Menutup dialog
                    Navigator.of(context).pop();

                    // Mendapatkan user yang sedang login
                    User? user = FirebaseAuth.instance.currentUser;

                    if (user != null) {
                      String userId = user.uid;
                      String productName = "Daftar Member";
                      double totalPayment = 50000;
                      String kodeBooking = 'M${userId}';

                      try {
                        // Menyimpan nomor HP ke Firestore pada collection 'no_hp_member'
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .update({
                          'uid': user.uid, // UID pengguna
                          'phone': phone, // Nomor HP
                          'memberSince': FieldValue.serverTimestamp(),
                        });

                        // Mendapatkan token pembayaran dari Midtrans
                        var result = await _tokenService.getToken(
                          productName: productName,
                          totalPayment: totalPayment,
                          id: kodeBooking,
                        );

                        // Menangani hasil dari token service
                        result.fold(
                          (failure) => _showToast(failure.message, true),
                          (tokenModel) {
                            // Memulai alur pembayaran Midtrans
                            _midtrans?.startPaymentUiFlow(
                                token: tokenModel.token);
                          },
                        );
                      } catch (e) {
                        _showToast('Error menyimpan nomor HP: $e', true);
                      }
                    } else {
                      _showToast('User is not logged in', true);
                    }
                  } else {
                    _showToast('Nomor HP harus diisi', true);
                  }
                } else {
                  _showToast('Nomor HP harus minimal 7 digit', true);
                }
              },
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
    final Color kuningBBS = Color(0xFFFFB600);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Member",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: kuningBBS,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        height: screenHeight,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: screenWidth,
                  height: screenWidth - 275,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(200, 30),
                    ),
                    color: kuningBBS,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.02,
                      left: screenWidth * 0.06,
                      right: screenWidth * 0.03),
                  child: Text(
                    "Membership 50k permanen!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.06,
                      left: screenWidth * 0.06,
                      right: screenWidth * 0.06),
                  child: Text(
                    "Hanya dengan 50k, anda bisa mendapatkan banyak keuntungan!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.2,
                      left: screenWidth * 0.06,
                      right: screenWidth * 0.06),
                  child: Text(
                    "Cukup cantumkan nomor HP dan bayar 50k, bisa langsung nikmatin keuntungan khusus.",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.3,
                      left: screenWidth * 0.06,
                      right: screenWidth * 0.03),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: Colors.red,
                            size: 45,
                          ),
                          SizedBox(width: screenWidth * 0.07),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Diskon 50%",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              SizedBox(
                                width: screenWidth * 0.7,
                                child: Text(
                                  "Dapatkan diskon 50%  untuk jam main saat happy hour.",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: screenHeight * 0.05,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.control_point_duplicate,
                            color: Colors.green,
                            size: 45,
                          ),
                          SizedBox(width: screenWidth * 0.07),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Gratis main atau F&B",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              SizedBox(
                                width: screenWidth * 0.7,
                                child: Text(
                                  "Kumpulkan poin yang didapat ketika bermain di luar happy hour untuk mendapatkan voucher gratis main atau F&B.",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: !_isMember,
                  child: SizedBox(
                    height: screenHeight * 0.897,
                  ),
                ),
                Visibility(
                  visible: !_isMember,
                  child: Positioned(
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
                ),
                Visibility(
                  visible: !_isMember,
                  child: Positioned(
                    bottom: screenWidth * 0.33,
                    left: screenWidth * 0.085,
                    child: Text(
                      'Harga',
                      style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey),
                    ),
                  ),
                ),
                Visibility(
                  visible: !_isMember,
                  child: Positioned(
                    bottom: screenWidth * 0.25,
                    left: screenWidth * 0.085,
                    child: Text(
                      'Rp50.000',
                      style: TextStyle(
                          fontSize: screenWidth * 0.053,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Visibility(
                  visible: !_isMember,
                  child: Positioned(
                    bottom: screenWidth * 0.08,
                    left: screenWidth * 0.08,
                    right: screenWidth * 0.08,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFFB600),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.04),
                        ),
                        elevation: 4.0,
                        padding:
                            EdgeInsets.symmetric(vertical: screenWidth * 0.025),
                      ),
                      onPressed: _showPhoneNumberDialog,
                      child: Text(
                        'Gabung',
                        style: TextStyle(
                            fontSize: screenWidth * 0.053,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(' ', ''); // Menghapus semua spasi
    String formattedText = '';

    for (int i = 0; i < newText.length; i++) {
      if (i % 4 == 0 && i != 0) {
        formattedText += ' ';
      }
      formattedText += newText[i];
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
