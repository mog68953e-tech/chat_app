import 'package:equatable/equatable.dart';

/// Core user entity for the domain layer
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String status;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? fcmToken;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.status = 'Hey there! I am using ChatApp.',
    this.isOnline = false,
    this.lastSeen,
    this.fcmToken,
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? status,
    bool? isOnline,
    DateTime? lastSeen,
    String? fcmToken,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, status];
}
