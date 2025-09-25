import 'package:bbs_booking_system/controller/clockpriceController.dart';
import 'package:bbs_booking_system/model/clockpriceModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group('ClockPriceController', () {
    late ClockPriceController _controller;
    late MockBuildContext mockContext;

    setUp(() {
      _controller = ClockPriceController();
      mockContext = MockBuildContext();
    });

    test('addClockPrice - Success', () async {
      // Mock data
      final clockPrice = ClockPrice(
        nama: 'Test',
        start: Timestamp.now(),
        end: Timestamp.now(),
        durasi: 1,
        price: 100,
      );

      // Mock Firestore
      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore.collection('clockprice');
      final docRef = collectionRef.doc();

      // Stub context and Firestore interactions
      when(() => mockContext).thenReturn(mockContext);
      when(() => collectionRef.add(clockPrice.toMap()))
          .thenAnswer((_) async => Future.value(docRef));

      // Call addClockPrice
      await _controller.addClockPrice(clockPrice, mockContext);

      // Verify interaction with Firestore
      verify(() => collectionRef.add(clockPrice.toMap())).called(1);
    });

    test('updateClockPrice - Success', () async {
      // Mock data
      final clockPrice = ClockPrice(
        nama: 'Test Updated',
        start: Timestamp.now(),
        end: Timestamp.now(),
        durasi: 1,
        price: 200,
      );

      // Mock Firestore
      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore.collection('clockprice');
      final docRef = collectionRef.doc('docId');

      // Stub Firestore interactions
      when(() => mockContext).thenReturn(mockContext);
      when(() => docRef.update(clockPrice.toMap()))
          .thenAnswer((_) async => Future.value());

      // Call updateClockPrice
      await _controller.updateClockPrice('docId', clockPrice, mockContext);

      // Verify Firestore update was called
      verify(() => docRef.update(clockPrice.toMap())).called(1);
    });
  });
}
