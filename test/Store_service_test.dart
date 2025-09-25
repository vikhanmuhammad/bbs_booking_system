import 'package:bbs_booking_system/controller/aturtutupController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late StoreController storeController;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;
  late MockDocumentSnapshot mockDocumentSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();

    storeController = StoreController(firestore: mockFirestore);
  });

  group('Store Controller Tests', () {
    // Test case 1: setStoreClosedDate
    test('setStoreClosedDate sets the closed date in Firestore', () async {
      final date = DateTime.now();

      when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenReturn(mockDocument);
      when(() => mockDocument.set(any())).thenAnswer((_) async {});

      await storeController.setStoreClosedDate(date);

      verify(() => mockFirestore.collection('store')).called(1);
      verify(() => mockCollection.doc('closed_date')).called(1);
      verify(() => mockDocument.set({'closed_date': Timestamp.fromDate(date)})).called(1);
    });

    // Test case 2: getClosedDate
    test('getClosedDate returns the closed date from Firestore', () async {
      final date = DateTime.now();

      when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenReturn(mockDocument);
      when(() => mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(() => mockDocumentSnapshot.exists).thenReturn(true);
      when(() => mockDocumentSnapshot.data()).thenReturn({'closed_date': Timestamp.fromDate(date)});

      final result = await storeController.getClosedDate();

      expect(result, date);
    });

    // Test case 3: isStoreClosedToday
    test('isStoreClosedToday returns true if the store is closed today', () async {
      final date = DateTime.now();

      when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenReturn(mockDocument);
      when(() => mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(() => mockDocumentSnapshot.exists).thenReturn(true);
      when(() => mockDocumentSnapshot.data()).thenReturn({'closed_date': Timestamp.fromDate(date)});

      final result = await storeController.isStoreClosedToday();

      expect(result, true);
    });

    // Test case 4: getOperationalHours
    test('getOperationalHours returns the operational hours from Firestore', () async {
      final operationalHours = {'open': '09:00', 'close': '21:00'};

      when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenReturn(mockDocument);
      when(() => mockDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(() => mockDocumentSnapshot.exists).thenReturn(true);
      when(() => mockDocumentSnapshot.data()).thenReturn(operationalHours);

      final result = await storeController.getOperationalHours();

      expect(result, operationalHours);
    });
  });
}
