import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/firebase_services.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/user_model.dart';

/// Concrete implementation of IAuthRepository using Firebase
class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirestoreService firestoreService,
    required StorageService storageService,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firestoreService = firestoreService,
        _storageService = storageService;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      try {
        final doc = await _firestoreService.getDocument(
          '${AppConstants.usersCollection}/${fbUser.uid}',
        );
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
        return null;
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await _getUserFromFirestore(credential.user!.uid);
      await _updateOnlineStatus(credential.user!.uid, true);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    File? profileImage,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      // Upload profile image if provided
      String photoUrl = '';
      if (profileImage != null) {
        photoUrl = await _storageService.uploadAvatar(profileImage, uid);
      }

      // Update Firebase Auth profile
      await credential.user!.updateDisplayName(displayName);
      if (photoUrl.isNotEmpty) {
        await credential.user!.updatePhotoURL(photoUrl);
      }

      // Create Firestore user document
      final userModel = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        isOnline: true,
        lastSeen: DateTime.now(),
      );

      await _firestoreService.setDocument(
        path: '${AppConstants.usersCollection}/$uid',
        data: userModel.toFirestore(),
      );

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Left(AuthFailure('Google sign-in cancelled.'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fbCredential = await _firebaseAuth.signInWithCredential(credential);
      final uid = fbCredential.user!.uid;

      // Create or update user document
      final doc = await _firestoreService.getDocument(
        '${AppConstants.usersCollection}/$uid',
      );

      if (!doc.exists) {
        final userModel = UserModel(
          uid: uid,
          email: fbCredential.user!.email ?? '',
          displayName: fbCredential.user!.displayName ?? '',
          photoUrl: fbCredential.user!.photoURL ?? '',
          isOnline: true,
          lastSeen: DateTime.now(),
        );
        await _firestoreService.setDocument(
          path: '${AppConstants.usersCollection}/$uid',
          data: userModel.toFirestore(),
        );
        return Right(userModel);
      }

      await _updateOnlineStatus(uid, true);
      final user = await _getUserFromFirestore(uid);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null) await _updateOnlineStatus(uid, false);
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser == null) return const Right(null);
      final user = await _getUserFromFirestore(fbUser.uid);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOnlineStatus(bool isOnline) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) return const Right(null);
      await _updateOnlineStatus(uid, isOnline);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── Private helpers ──────────────────────────────────────────

  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await _firestoreService.getDocument(
      '${AppConstants.usersCollection}/$uid',
    );
    return UserModel.fromFirestore(doc);
  }

  Future<void> _updateOnlineStatus(String uid, bool isOnline) async {
    await _firestoreService.updateDocument(
      path: '${AppConstants.usersCollection}/$uid',
      data: {
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      },
    );
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
