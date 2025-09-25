import 'package:bbs_booking_system/model/bookingModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingService {
  final FirebaseFirestore _firestore;

  BookingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  //create
  static Future<void> addToFirestore(
      BuildContext context, BookingModel bookingModel, int meja) async {
    try {
      await FirebaseFirestore.instance
          .collection("booking")
          .doc('meja_$meja')
          .collection('books')
          .add(bookingModel.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking data has been made.')));
    } catch (error) {
      // Show error message to the user
    }
  }

  Stream<QuerySnapshot> getBooking({bool includeMetadataChanges = false}) {
    return _firestore
        .collection('booking')
        .snapshots(includeMetadataChanges: includeMetadataChanges);
  }

  Stream<QuerySnapshot> getBookingPerMeja(int meja,
      {bool includeMetadataChanges = false}) {
    return _firestore
        .collection('booking')
        .doc('meja_$meja')
        .collection('books')
        .orderBy('waktuMulai',
            descending:
                false) // Urutkan berdasarkan waktuMulai secara ascending
        .snapshots(includeMetadataChanges: includeMetadataChanges);
  }

  //update
  static Future<BookingModel> updateBooking(
      BuildContext context, karirPost, String id) async {
    await FirebaseFirestore.instance
        .collection('booking')
        .doc(id)
        .update(karirPost.toMap());
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Career post updated successfully!')));
    Navigator.pop(context); // Assuming this is in a new screen
    return karirPost;
  }

  //delete
  static Future<void> deleteBooking(String id, int meja) async {
    await FirebaseFirestore.instance
        .collection("booking")
        .doc('meja_$meja')
        .collection('books')
        .doc(id)
        .delete();
  }

  Future<bool> checkBookingCollision(BookingModel newBooking) async {
    QuerySnapshot existingBookingsSnapshot = await _firestore
        .collection('booking')
        .doc('meja_${newBooking.meja}')
        .collection('books')
        .get();

    for (var doc in existingBookingsSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      BookingModel existingBooking = BookingModel(
        kodeBooking: data['kodeBooking'],
        userBook: data['userBook'],
        userBookUID: data['userBookUID'] ?? '',
        meja: data['meja'],
        lantai: data['lantai'],
        waktuMulai: data['waktuMulai'],
        waktuSelesai: data['waktuSelesai'],
        statusBayar: data['statusBayar'],
        metodeBayar: data['metodeBayar'],
        paket: '',
      );

      if ((newBooking.waktuMulai.seconds <
                  existingBooking.waktuSelesai.seconds &&
              newBooking.waktuMulai.seconds >=
                  existingBooking.waktuMulai.seconds) ||
          (newBooking.waktuSelesai.seconds >
                  existingBooking.waktuMulai.seconds &&
              newBooking.waktuSelesai.seconds <=
                  existingBooking.waktuSelesai.seconds) ||
          (newBooking.waktuMulai.seconds ==
                  existingBooking.waktuMulai.seconds ||
              newBooking.waktuSelesai.seconds ==
                  existingBooking.waktuSelesai.seconds)) {
        return true; // Collision detected
      }
    }
    return false; // No collision detected
  }
}
