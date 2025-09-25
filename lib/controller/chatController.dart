import 'package:bbs_booking_system/model/chatModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ChatService extends ChangeNotifier {
  final firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<void> sendMessage(
      String receiverId, String message, String type) async {
    try {
      final String currentUserInfo = firebaseAuth.currentUser!.uid;
      final String currentUserDisplayName =
          firebaseAuth.currentUser!.displayName!;
      final Timestamp timestamp = Timestamp.now();

      // Create new message
      Message newMessage = Message(
          senderId: currentUserInfo,
          senderName: currentUserDisplayName,
          message: message,
          receiverId: receiverId,
          timestamp: timestamp,
          type: type);

      // Construct chat room id from current user id and receiver id (sorted to ensure consistency)
      List<String> ids = [currentUserInfo, receiverId];
      ids.sort();
      String chatRoomId = ids.join('_');

      await _fireStore
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());
    } catch (e) {
      // Handle the error here
      print('Error sending message: $e');
    }
  }

  Future<void> sendImage(String receiverId, File imageFile) async {
    try {
      final String currentUserInfo = firebaseAuth.currentUser!.uid;
      final String currentUserDisplayName =
          firebaseAuth.currentUser!.displayName!;
      final Timestamp timestamp = Timestamp.now();

      // Upload image to Firebase Storage
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = _firebaseStorage
          .ref()
          .child('chat_images/$currentUserInfo/$fileName')
          .putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Create new image message
      Message newMessage = Message(
          senderId: currentUserInfo,
          senderName: currentUserDisplayName,
          message: imageUrl,
          receiverId: receiverId,
          timestamp: timestamp,
          type: 'image');

      // Construct chat room id from current user id and receiver id (sorted to ensure consistency)
      List<String> ids = [currentUserInfo, receiverId];
      ids.sort();
      String chatRoomId = ids.join('_');

      await _fireStore
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());
    } catch (e) {
      // Handle the error here
      print('Error sending image: $e');
    }
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _fireStore
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
