import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/constants/app_constants.dart';

/// Remote data source for fetching user documents
class UsersRemoteDatasource {
  final FirebaseFirestore _firestore;

  UsersRemoteDatasource(this._firestore);

  Stream<List<UserModel>> getAllUsersStream(String excludeUid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UserModel.fromFirestore(d))
            .where((u) => u.uid != excludeUid)
            .toList());
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (_) {
      return null;
    }
  }

  Future<List<UserModel>> searchUsers(String query, String excludeUid) async {
    final snap = await _firestore
        .collection(AppConstants.usersCollection)
        .get();
    return snap.docs
        .map((d) => UserModel.fromFirestore(d))
        .where((u) =>
            u.uid != excludeUid &&
            (u.displayName.toLowerCase().contains(query.toLowerCase()) ||
                u.email.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }
}
