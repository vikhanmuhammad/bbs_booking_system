import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bbs_booking_system/model/paketModel.dart';

class PaketController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new Paket to the collection
  Future<void> addPaket(Paket paket) async {
    try {
      await _firestore.collection('paket').add(paket.toMap());
      print("Paket added successfully");
    } catch (e) {
      print("Failed to add Paket: $e");
      throw Exception("Failed to add Paket: $e");
    }
  }

  // Get all Pakets from the collection
  Stream<List<Map<String, dynamic>>> getPaketsWithDocID() {
    return _firestore
        .collection('paket')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'docID': doc.id,
          'data': Paket(
            namaPaket: doc['namaPaket'],
            rincianPaket: doc['rincianPaket'],
            hargaPaket: doc['hargaPaket'],
            urlImage: doc['urlImage'],
            durasiPaket: doc['durasiPaket'],
            createdAt: doc['createdAt'],
          )
        };
      }).toList();
    });
  }

  // Update an existing Paket
  Future<void> updatePaket(String paketId, Paket updatedPaket) async {
    try {
      await _firestore
          .collection('paket')
          .doc(paketId)
          .update(updatedPaket.toMap());
      print("Paket updated successfully");
    } catch (e) {
      print("Failed to update Paket: $e");
      throw Exception("Failed to update Paket: $e");
    }
  }

  // Delete a Paket
  Future<void> deletePaket(String paketId) async {
    try {
      await _firestore.collection('paket').doc(paketId).delete();
      print("Paket deleted successfully");
    } catch (e) {
      print("Failed to delete Paket: $e");
      throw Exception("Failed to delete Paket: $e");
    }
  }

  Future<List<String>> getPaketDocumentIds() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('paket')
          .orderBy('createdAt', descending: true)
          .get();
      List<String> documentIds =
          querySnapshot.docs.map((doc) => doc.id).toList();
      return documentIds;
    } catch (e) {
      print('Error getting document IDs: $e');
      return [];
    }
  }
}
