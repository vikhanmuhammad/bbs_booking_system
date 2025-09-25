import 'package:bbs_booking_system/model/bookingModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileService {
  final FirebaseFirestore _firestore;

  ProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<User?> getLoggedInUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      return user;
    } catch (e) {
      print('Error getting logged in user: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    User? user = await getLoggedInUser();
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(user.uid).get();
      return snapshot.data();
    }
    return null;
  }

  //create
  static Future<void> addBookDataToUserData(
      BuildContext context, BookingModel bookingModel, int meja) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String loggeduid = user?.uid ?? 'unloggedin';
      await FirebaseFirestore.instance
          .collection("users")
          .doc('$loggeduid')
          .collection('books')
          .add(bookingModel.toMap());
      // Show success message or navigate to another screen
    } catch (error) {
      // Show error message to the user
    }
  }

  Future<void> deleteBookDataFromUserData(
      String userId, String kodeBooking) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('books')
          .where('kodeBooking', isEqualTo: kodeBooking)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting booking data: $e');
    }
  }

  Future<BookingModel?> getLatestBookingData() async {
    try {
      User? user = await getLoggedInUser();
      if (user != null) {
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('books')
            .orderBy('waktuMulai', descending: true)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          Map<String, dynamic> bookingData = querySnapshot.docs.first.data();
          return BookingModel(
            kodeBooking: bookingData['kodeBooking'],
            userBook: bookingData['userBook'],
            userBookUID: bookingData['userBookUID'],
            meja: bookingData['meja'],
            lantai: bookingData['lantai'],
            waktuMulai: bookingData['waktuMulai'],
            waktuSelesai: bookingData['waktuSelesai'],
            statusBayar: bookingData['statusBayar'],
            metodeBayar: bookingData['metodeBayar'],
            paket: bookingData['paket'],
          );
        }
      }
    } catch (e) {
      print('Error getting latest booking data: $e');
    }
    return null;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getLatest7Booking() async {
    User? user = FirebaseAuth.instance.currentUser;
    String loggeduid = user?.uid ?? 'unloggedin';
    return _firestore
        .collection('users')
        .doc(loggeduid)
        .collection('books')
        .orderBy('waktuMulai', descending: true)
        .limit(7)
        .get();
  }
}
