import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../../../core/errors/usecase.dart';

part 'auth_state.dart';

/// AuthCubit manages authentication state throughout the app.
/// GoRouter listens to its stream to redirect based on auth status.
class AuthCubit extends Cubit<AuthState> {
  final SignInWithEmailUseCase _signInWithEmail;
  final SignUpWithEmailUseCase _signUpWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOut;
  final GetCurrentUserUseCase _getCurrentUser;

  AuthCubit({
    required SignInWithEmailUseCase signInWithEmail,
    required SignUpWithEmailUseCase signUpWithEmail,
    required SignInWithGoogleUseCase signInWithGoogle,
    required SignOutUseCase signOut,
    required GetCurrentUserUseCase getCurrentUser,
  })  : _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        super(AuthInitial());

  /// Check if a user is already signed in (called on splash screen)
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final result = await _getCurrentUser(NoParams());
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());
    final result = await _signInWithEmail(
      SignInWithEmailParams(email: email, password: password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    dynamic profileImage,
  }) async {
    emit(AuthLoading());
    final result = await _signUpWithEmail(
      SignUpWithEmailParams(
        email: email,
        password: password,
        displayName: displayName,
        profileImage: profileImage,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    final result = await _signInWithGoogle(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    final result = await _signOut(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  UserEntity? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;
}
