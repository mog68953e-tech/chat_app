import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';

/// Wrapper around Firebase Storage for uploading media files
class StorageService {
  final FirebaseStorage _storage;
  final Uuid _uuid;

  StorageService(this._storage, this._uuid);

  /// Upload a file and return its download URL
  Future<String> uploadFile({
    required File file,
    required String storagePath,
  }) async {
    final ext = path.extension(file.path);
    final fileName = '${_uuid.v4()}$ext';
    final ref = _storage.ref().child(storagePath).child(fileName);
    final uploadTask = await ref.putFile(file);
    return uploadTask.ref.getDownloadURL();
  }

  /// Upload avatar image for a user
  Future<String> uploadAvatar(File file, String uid) async {
    final ext = path.extension(file.path);
    final ref = _storage
        .ref()
        .child(AppConstants.avatarsStoragePath)
        .child('$uid$ext');
    final uploadTask = await ref.putFile(file);
    return uploadTask.ref.getDownloadURL();
  }

  /// Upload a chat image and return download URL
  Future<String> uploadChatImage(File file, String conversationId) async {
    return uploadFile(
      file: file,
      storagePath:
          '${AppConstants.imagesStoragePath}/$conversationId',
    );
  }

  /// Upload a voice message and return download URL
  Future<String> uploadVoiceMessage(
      File file, String conversationId) async {
    return uploadFile(
      file: file,
      storagePath:
          '${AppConstants.voiceStoragePath}/$conversationId',
    );
  }
}

/// Wrapper for common Firestore operations
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  FirebaseFirestore get instance => _firestore;

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _firestore.collection(path);

  DocumentReference<Map<String, dynamic>> document(String path) =>
      _firestore.doc(path);

  /// Set document with merge option
  Future<void> setDocument({
    required String path,
    required Map<String, dynamic> data,
    bool merge = true,
  }) =>
      _firestore.doc(path).set(data, SetOptions(merge: merge));

  /// Update specific fields in a document
  Future<void> updateDocument({
    required String path,
    required Map<String, dynamic> data,
  }) =>
      _firestore.doc(path).update(data);

  /// Delete a document
  Future<void> deleteDocument(String path) =>
      _firestore.doc(path).delete();

  /// Get a document snapshot once
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
          String path) =>
      _firestore.doc(path).get();

  /// Listen to a document stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> documentStream(
          String path) =>
      _firestore.doc(path).snapshots();

  /// Listen to a collection stream with optional query
  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream({
    required String path,
    List<List<dynamic>>? conditions,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(path);
    if (conditions != null) {
      for (final c in conditions) {
        query = query.where(c[0] as String,
            isEqualTo: c.length == 2 ? c[1] : null);
      }
    }
    if (orderBy != null) query = query.orderBy(orderBy, descending: descending);
    if (limit != null) query = query.limit(limit);
    return query.snapshots();
  }

  FieldValue get serverTimestamp => FieldValue.serverTimestamp();
  FieldValue increment(num value) => FieldValue.increment(value);
  FieldValue arrayUnion(List<dynamic> elements) =>
      FieldValue.arrayUnion(elements);
  FieldValue arrayRemove(List<dynamic> elements) =>
      FieldValue.arrayRemove(elements);
}
