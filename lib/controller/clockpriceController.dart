import 'package:bbs_booking_system/controller/aturtutupController.dart';
import 'package:bbs_booking_system/model/clockpriceModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClockPriceController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'clockprice';
    final StoreController _storeController = StoreController();

  // Create a new ClockPrice in Firestore
  Future<void> addClockPrice(
      ClockPrice clockPrice, BuildContext context) async {
    try {
      bool hasCollision = await checkCollision(clockPrice);
      if (hasCollision) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data harga jam bertabrakan')));
      } else {
        await _firestore.collection(collectionPath).add(clockPrice.toMap());
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error adding clock price: $e');
    }
  }

  // Function to check for collision when adding a new ClockPrice
  Future<bool> checkCollision(ClockPrice clockPrice) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionPath)
          .where('start', isLessThanOrEqualTo: clockPrice.end)
          .where('end', isGreaterThanOrEqualTo: clockPrice.start)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return true;
      }
    } catch (e) {
      print('Error checking collision: $e');
    }
    return false;
  }

  // Function to check for collision when updating a ClockPrice
  Future<bool> checkCollisionForUpdate(String id, ClockPrice clockPrice) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionPath)
          .where('start', isLessThanOrEqualTo: clockPrice.end)
          .where('end', isGreaterThanOrEqualTo: clockPrice.start)
          .where(FieldPath.documentId,
              isNotEqualTo: id) // Exclude the current document
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return true;
      }
    } catch (e) {
      print('Error checking collision for update: $e');
    }
    return false;
  }

  // Get all ClockPrices from Firestore
  Stream<QuerySnapshot> getClockPrices({bool includeMetadataChanges = false}) {
    return _firestore
        .collection(collectionPath)
        .orderBy('start', descending: false)
        .snapshots(includeMetadataChanges: includeMetadataChanges);
  }

  // Get a specific ClockPrice by document ID
  Future<ClockPrice?> getClockPriceById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(collectionPath).doc(id).get();
      if (doc.exists) {
        return ClockPrice(
          nama: doc['nama'],
          start: doc['start'],
          end: doc['end'],
          durasi: doc['durasi'],
          price: doc['price'],
        );
      }
    } catch (e) {
      print('Error fetching clock price: $e');
    }
    return null;
  }

  // Update a ClockPrice in Firestore with specified collision check
  Future<void> updateClockPrice(
      String id, ClockPrice clockPrice, BuildContext context) async {
    try {
      bool hasCollision = await checkCollisionForUpdate(id, clockPrice);
      if (hasCollision) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data harga jam bertabrakan')));
      } else {
        await _firestore
            .collection(collectionPath)
            .doc(id)
            .update(clockPrice.toMap());
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error updating clock price: $e');
    }
  }

  // Delete a ClockPrice from Firestore
  Future<void> deleteClockPrice(String id) async {
    try {
      await _firestore.collection(collectionPath).doc(id).delete();
    } catch (e) {
      print('Error deleting clock price: $e');
    }
  }

  // Get all ClockPrices as a List
  Future<List<ClockPrice>> getClockPricesList() async {
  try {
    QuerySnapshot snapshot = await _firestore.collection(collectionPath).get();
    List<ClockPrice> clockPrices = snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return ClockPrice.fromMap(data);
    }).toList();
    return clockPrices;
  } catch (e) {
    print('Error fetching clock prices: $e');
    return [];
  }
}


 Future<int> getRegularPrice() async {
    return await _storeController .getRegularPrice() ?? 0;
  }

}
