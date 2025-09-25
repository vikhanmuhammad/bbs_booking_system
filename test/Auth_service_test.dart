import 'package:bbs_booking_system/controller/authController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Definisi mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockDocumentReference mockDocumentReference;
  late MockCollectionReference mockCollectionReference;

  setUp(() {
    sqfliteFfiInit(); // Inisialisasi sqflite_ffi untuk pengujian
    databaseFactory = databaseFactoryFfi;

    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockDocumentReference = MockDocumentReference();
    mockCollectionReference = MockCollectionReference();

    // Buat AuthService dengan mocks
    authService = AuthService(auth: mockFirebaseAuth, firestore: mockFirebaseFirestore);

    // Registrasi fallbacks untuk tipe yang tidak dapat di-mock secara langsung
    registerFallbackValue(MockUserCredential());
    registerFallbackValue(MockDocumentReference());
    registerFallbackValue(MockCollectionReference());
  });

  group('AuthService Tests', () {
    test('signInWithEmailAndPassword returns user on success', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('mock-uid');
      when(() => mockUser.email).thenReturn('mock@example.com');

      final user = await authService.signInWithEmailAndPassword('test@example.com', 'password123', false);

      expect(user, equals(mockUser));
    });

    test('signInWithEmailAndPassword returns null on error', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      final user = await authService.signInWithEmailAndPassword('test@example.com', 'wrongpassword', false);

      expect(user, isNull);
    });

    test('signUpUser returns user on success', () async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockFirebaseFirestore.collection('users')).thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.doc('test-uid')).thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.set(any())).thenAnswer((_) async => {});
      when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async => {});

      final user = await authService.signUpUser('newuser@example.com', 'newpassword123', 'New User', false);

      expect(user, equals(mockUser));
      verify(() => mockDocumentReference.set(any())).called(1);
      verify(() => mockUser.updateDisplayName('New User')).called(1);
    });

    test('signUpUser returns null on error', () async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      final user = await authService.signUpUser('existinguser@example.com', 'password123', 'Existing User', false);

      expect(user, isNull);
    });
  });
}
