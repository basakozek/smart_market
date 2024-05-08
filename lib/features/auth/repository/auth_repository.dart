import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_module_1/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firebaseFirestore: FirebaseFirestore.instance));

class AuthRepository {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseAuth auth;
  AuthRepository({
    required this.auth,
    required this.firebaseFirestore,
  });

  Future<void> signInWithEmailandPassword({
    required String email,
    required String password,
  }) async {
    await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmailandPassword({
    required String email,
    required String password,
  }) async {
    await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> storeUserInfoToFirebase(UserModel userModel) async {
    userModel.uid = auth.currentUser!.uid;
    userModel.email =
        auth.currentUser!.email!; // Kullanıcının e-posta adresini ekleyin
    await firebaseFirestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .set(userModel.toMap());
  }
}
