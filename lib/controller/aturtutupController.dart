import 'package:cloud_firestore/cloud_firestore.dart';

class StoreController {
  final FirebaseFirestore _firestore;

  StoreController({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> setStoreClosedDate(DateTime date) async {
    await _firestore.collection('store').doc('closed_date').set({
      'closed_date': Timestamp.fromDate(date),
    });
  }

  Future<DateTime?> getClosedDate() async {
    DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('store').doc('closed_date').get();
    if (doc.exists && doc.data() != null) {
      Timestamp timestamp = doc.data()!['closed_date'];
      return timestamp.toDate();
    }
    return null;
  }

  Future<bool> isStoreClosedToday() async {
    DateTime? closedDate = await getClosedDate();
    if (closedDate != null) {
      DateTime today = DateTime.now();
      return closedDate.year == today.year &&
          closedDate.month == today.month &&
          closedDate.day == today.day;
    }
    return false;
  }

  Future<Map<String, dynamic>> getOperationalHours() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('store').doc('operational_hours').get();

    if (snapshot.exists && snapshot.data() != null) {
      return snapshot.data()!;
    } else {
      throw Exception('Operational hours not found');
    }
  }

  Future<int?> getRegularPrice() async {
    DocumentSnapshot doc =
        await _firestore.collection('store').doc('regular_price').get();
    if (doc.exists) {
      int price = doc['price'];
      return price;
    }
    return null;
  }

  Future<void> setRegularPrice(int price) async {
    await _firestore.collection('store').doc('regular_price').set({
      'price': price,
    });
  }
}
