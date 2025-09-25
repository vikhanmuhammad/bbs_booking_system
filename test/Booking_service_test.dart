import 'package:bbs_booking_system/controller/bookingController.dart';
import 'package:bbs_booking_system/model/bookingModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Definisi mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}
class MockBuildContext extends Mock implements BuildContext {}
void main() {
  late MockFirebaseFirestore mockFirestore;
  late BookingModel bookingModel;
  late BookingService bookingService;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockBuildContext mockContext;
  

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockContext = MockBuildContext();

    bookingService = BookingService(firestore: mockFirestore);

    // Registrasi fallbacks untuk tipe yang tidak dapat di-mock secara langsung
    registerFallbackValue(MockCollectionReference());
    registerFallbackValue(MockDocumentReference());

    bookingModel = BookingModel(
      kodeBooking: 'kodeBooking',
      userBook: 'userBook',
      userBookUID: 'userBookUID',
      meja: 1,
      lantai: 1,
      waktuMulai: Timestamp.now(),
      waktuSelesai: Timestamp.now(),
      statusBayar: true,
      metodeBayar: 'metodeBayar',
      paket: 'paket',
    );
  });

  test('toMap() returns correct map', () {
    final map = bookingModel.toMap();
    expect(map, {
      'kodeBooking': 'kodeBooking',
      'userBook': 'userBook',
      'userBookUID': 'userBookUID',
      'meja': 1,
      'lantai': 1,
      'waktuMulai': isA<Timestamp>(),
      'waktuSelesai': isA<Timestamp>(),
      'statusBayar': true,
      'metodeBayar': 'metodeBayar',
      'paket': 'paket',
    });
  });
test('getBooking returns a stream of bookings', () {
      when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
      when(() => mockCollection.snapshots(includeMetadataChanges: any(named: 'includeMetadataChanges')))
          .thenAnswer((_) => Stream.value(mockQuerySnapshot));

      final stream = bookingService.getBooking();

      expect(stream, isA<Stream<QuerySnapshot>>());
    });

    test('checkBookingCollision returns true when collision is detected', () async {
      final newBooking = BookingModel(
        kodeBooking: '123',
        userBook: 'John Doe',
        userBookUID: 'uid_123',
        meja: 1,
        lantai: 2,
        waktuMulai: Timestamp.fromDate(DateTime.now().add(Duration(minutes: 10))),
        waktuSelesai: Timestamp.fromDate(DateTime.now().add(Duration(hours: 1))),
        statusBayar: true,
        metodeBayar: 'Credit Card',
        paket: 'Paket A',
      );

      final existingBookingData = {
        'kodeBooking': '123',
        'userBook': 'Jane Doe',
        'userBookUID': 'uid_456',
        'meja': 1,
        'lantai': 2,
        'waktuMulai': Timestamp.fromDate(DateTime.now()),
        'waktuSelesai': Timestamp.fromDate(DateTime.now().add(Duration(minutes: 30))),
        'statusBayar': true,
        'metodeBayar': 'Cash',
        'paket': 'Paket B',
      };

      final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
      when(() => mockQueryDocumentSnapshot.data()).thenReturn(existingBookingData);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

      when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenReturn(mockDocument);
      when(() => mockDocument.collection(any())).thenReturn(mockCollection);
      when(() => mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);

      final result = await bookingService.checkBookingCollision(newBooking);

      expect(result, isTrue);
    });

    test('checkBookingCollision returns false when no collision is detected', () async {
      final newBooking = BookingModel(
        kodeBooking: '123',
        userBook: 'John Doe',
        userBookUID: 'uid_123',
        meja: 1,
        lantai: 2,
        waktuMulai: Timestamp.fromDate(DateTime.now().add(Duration(hours: 2))),
        waktuSelesai: Timestamp.fromDate(DateTime.now().add(Duration(hours: 3))),
        statusBayar: true,
        metodeBayar: 'Credit Card',
        paket: 'Paket A',
      );

      when(() => mockQuerySnapshot.docs).thenReturn([]);
      when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenReturn(mockDocument);
      when(() => mockDocument.collection(any())).thenReturn(mockCollection);
      when(() => mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);

      final result = await bookingService.checkBookingCollision(newBooking);

      expect(result, isFalse);
    });
  }
