import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/firebase_services.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  ProfileCubit({
    required FirestoreService firestoreService,
    required StorageService storageService,
  })  : _firestoreService = firestoreService,
        _storageService = storageService,
        super(ProfileInitial());

  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String status,
    File? newAvatar,
    required String currentPhotoUrl,
  }) async {
    emit(ProfileUpdating());
    try {
      String photoUrl = currentPhotoUrl;
      if (newAvatar != null) {
        photoUrl = await _storageService.uploadAvatar(newAvatar, uid);
      }
      await _firestoreService.updateDocument(
        path: '${AppConstants.usersCollection}/$uid',
        data: {
          'displayName': displayName,
          'status': status,
          'photoUrl': photoUrl,
        },
      );
      emit(ProfileUpdated());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
