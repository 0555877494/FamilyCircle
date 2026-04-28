import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/shared_media.dart';
import 'package:uuid/uuid.dart';

class MediaService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  Future<SharedMedia?> pickAndUploadImage(String familyId, String userId, String userName) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;
      
      return await _uploadMedia(
        familyId: familyId,
        userId: userId,
        userName: userName,
        file: File(image.path),
        isImage: true,
      );
    } catch (e) {
      return null;
    }
  }

  Future<SharedMedia?> pickAndUploadVideo(String familyId, String userId, String userName) async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video == null) return null;
      
      return await _uploadMedia(
        familyId: familyId,
        userId: userId,
        userName: userName,
        file: File(video.path),
        isImage: false,
        isVideo: true,
      );
    } catch (e) {
      return null;
    }
  }

  Future<SharedMedia?> captureAndUploadImage(String familyId, String userId, String userName) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return null;
      
      return await _uploadMedia(
        familyId: familyId,
        userId: userId,
        userName: userName,
        file: File(image.path),
        isImage: true,
      );
    } catch (e) {
      return null;
    }
  }

  Future<SharedMedia?> _uploadMedia({
    required String familyId,
    required String userId,
    required String userName,
    required File file,
    required bool isImage,
    bool isVideo = false,
  }) async {
    final mediaId = _uuid.v4();
    final extension = isImage ? 'jpg' : 'mp4';
    final path = 'media/$familyId/$mediaId.$extension';
    
    try {
      final uploadTask = _storage.ref().child(path).putFile(
        file,
        isVideo 
            ? SettableMetadata(contentType: 'video/mp4')
            : SettableMetadata(contentType: 'image/jpeg'),
      );
      
      await uploadTask;
      final url = await _storage.ref().child(path).getDownloadURL();
      
      final media = SharedMedia(
        id: mediaId,
        familyId: familyId,
        uploadedBy: userId,
        uploaderName: userName,
        fileName: path.split('/').last,
        fileUrl: url,
        isImage: isImage,
        isVideo: isVideo,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('media').doc(mediaId).set(media.toMap());
      return media;
    } catch (e) {
      return null;
    }
  }

  Stream<List<SharedMedia>> getMediaStream(String familyId) {
    return _firestore.collection('media')
        .where('familyId', isEqualTo: familyId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SharedMedia.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> deleteMedia(String mediaId) async {
    await _firestore.collection('media').doc(mediaId).delete();
  }
}