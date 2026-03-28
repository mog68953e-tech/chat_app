import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// Firestore data model for UserEntity
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoUrl,
    super.status,
    super.isOnline,
    super.lastSeen,
    super.fcmToken,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      status: data['status'] as String? ?? 'Hey there! I am using ChatApp.',
      isOnline: data['isOnline'] as bool? ?? false,
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
      fcmToken: data['fcmToken'] as String?,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'Hey there! I am using ChatApp.',
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastSeen'] as int)
          : null,
      fcmToken: json['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'status': status,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      status: entity.status,
      isOnline: entity.isOnline,
      lastSeen: entity.lastSeen,
      fcmToken: entity.fcmToken,
    );
  }
}
