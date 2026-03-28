import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'core/constants/app_constants.dart';
import 'core/services/firebase_services.dart';
import 'core/theme/theme_cubit.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/i_chat_repository.dart';
import 'features/chat/presentation/cubit/chat_cubit.dart';
import 'features/chat/presentation/cubit/chat_list_cubit.dart';

import 'features/users/data/datasources/users_remote_datasource.dart';
import 'features/users/presentation/cubit/users_cubit.dart';

import 'features/profile/presentation/cubit/profile_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ─── Firebase ────────────────────────────────────────────────
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  sl.registerLazySingleton<Uuid>(() => const Uuid());

  // ─── Core Services ───────────────────────────────────────────
  sl.registerLazySingleton<FirestoreService>(
      () => FirestoreService(sl<FirebaseFirestore>()));
  sl.registerLazySingleton<StorageService>(
      () => StorageService(sl<FirebaseStorage>(), sl<Uuid>()));

  // ─── Local Storage ───────────────────────────────────────────
  sl.registerLazySingleton<ThemeCubit>(
      () => ThemeCubit(Hive.box(AppConstants.settingsBox)));

  // ─── Auth Feature ────────────────────────────────────────────
  // Repository
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(
        firebaseAuth: sl<FirebaseAuth>(),
        googleSignIn: sl<GoogleSignIn>(),
        firestoreService: sl<FirestoreService>(),
        storageService: sl<StorageService>(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl<IAuthRepository>()));
  sl.registerLazySingleton(() => SignUpWithEmailUseCase(sl<IAuthRepository>()));
  sl.registerLazySingleton(
      () => SignInWithGoogleUseCase(sl<IAuthRepository>()));
  sl.registerLazySingleton(() => SignOutUseCase(sl<IAuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<IAuthRepository>()));

  // Cubit (singleton — app-wide)
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(
        signInWithEmail: sl<SignInWithEmailUseCase>(),
        signUpWithEmail: sl<SignUpWithEmailUseCase>(),
        signInWithGoogle: sl<SignInWithGoogleUseCase>(),
        signOut: sl<SignOutUseCase>(),
        getCurrentUser: sl<GetCurrentUserUseCase>(),
      ));

  // ─── Chat Feature ────────────────────────────────────────────
  sl.registerLazySingleton<IChatRepository>(() => ChatRepositoryImpl(
        firestoreService: sl<FirestoreService>(),
        storageService: sl<StorageService>(),
        uuid: sl<Uuid>(),
      ));

  // Cubits (factory — new instance per chat screen)
  sl.registerFactory<ChatCubit>(() => ChatCubit(sl<IChatRepository>()));
  sl.registerFactory<ChatListCubit>(
      () => ChatListCubit(sl<IChatRepository>()));

  // ─── Users Feature ───────────────────────────────────────────
  sl.registerLazySingleton<UsersRemoteDatasource>(
      () => UsersRemoteDatasource(sl<FirebaseFirestore>()));
  sl.registerFactory<UsersCubit>(
      () => UsersCubit(sl<UsersRemoteDatasource>()));

  // ─── Profile Feature ─────────────────────────────────────────
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(
        firestoreService: sl<FirestoreService>(),
        storageService: sl<StorageService>(),
      ));
}
