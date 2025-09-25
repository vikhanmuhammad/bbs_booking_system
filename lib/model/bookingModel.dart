import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  String kodeBooking;
  String userBook;
  String userBookUID;
  int meja;
  int lantai;
  Timestamp waktuMulai;
  Timestamp waktuSelesai;
  bool statusBayar;
  String metodeBayar;
  String paket;

  BookingModel(
      {required this.kodeBooking,
      required this.userBook,
      required this.userBookUID,
      required this.meja,
      required this.lantai,
      required this.waktuMulai,
      required this.waktuSelesai,
      required this.statusBayar,
      required this.metodeBayar,
      required this.paket});

  Map<String, dynamic> toMap() => {
        'kodeBooking': kodeBooking,
        'userBook': userBook,
        'userBookUID': userBookUID,
        'meja': meja,
        'lantai': lantai,
        'waktuMulai': waktuMulai,
        'waktuSelesai': waktuSelesai,
        'statusBayar': statusBayar,
        'metodeBayar': metodeBayar,
        'paket': paket
      };
}
