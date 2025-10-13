import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<FirebaseAuth>(),
  MockSpec<FirebaseFirestore>(),
  MockSpec<FlutterSecureStorage>(),
  MockSpec<DocumentReference<Map<String, dynamic>>>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
  MockSpec<PhoneAuthCredential>(),
  MockSpec<User>(),
  MockSpec<UserCredential>(),
  MockSpec<UserInfo>(),
])
void main() {}
