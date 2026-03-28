import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Contract for the auth repository — implemented in data layer
abstract class IAuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    File? profileImage,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, void>> updateOnlineStatus(bool isOnline);
}
