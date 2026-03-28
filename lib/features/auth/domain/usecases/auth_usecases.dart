import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/usecase.dart';
import '../repositories/i_auth_repository.dart';
import '../entities/user_entity.dart';

// ─── Sign In With Email ────────────────────────────────────────
class SignInWithEmailParams {
  final String email;
  final String password;
  SignInWithEmailParams({required this.email, required this.password});
}

class SignInWithEmailUseCase
    implements UseCase<UserEntity, SignInWithEmailParams> {
  final IAuthRepository _repository;
  SignInWithEmailUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithEmailParams params) =>
      _repository.signInWithEmail(
        email: params.email,
        password: params.password,
      );
}

// ─── Sign Up With Email ────────────────────────────────────────

class SignUpWithEmailParams {
  final String email;
  final String password;
  final String displayName;
  final File? profileImage;

  SignUpWithEmailParams({
    required this.email,
    required this.password,
    required this.displayName,
    this.profileImage,
  });
}

class SignUpWithEmailUseCase
    implements UseCase<UserEntity, SignUpWithEmailParams> {
  final IAuthRepository _repository;
  SignUpWithEmailUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpWithEmailParams params) =>
      _repository.signUpWithEmail(
        email: params.email,
        password: params.password,
        displayName: params.displayName,
        profileImage: params.profileImage,
      );
}

// ─── Sign In With Google ───────────────────────────────────────
class SignInWithGoogleUseCase implements UseCase<UserEntity, NoParams> {
  final IAuthRepository _repository;
  SignInWithGoogleUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) =>
      _repository.signInWithGoogle();
}

// ─── Sign Out ─────────────────────────────────────────────────
class SignOutUseCase implements UseCase<void, NoParams> {
  final IAuthRepository _repository;
  SignOutUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    await _repository.updateOnlineStatus(false);
    return _repository.signOut();
  }
}

// ─── Get Current User ──────────────────────────────────────────
class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  final IAuthRepository _repository;
  GetCurrentUserUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) =>
      _repository.getCurrentUser();
}
