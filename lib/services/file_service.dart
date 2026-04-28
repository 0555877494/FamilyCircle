import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

enum FileType { image, video, document, audio, other }

class UploadedFile {
  final String id;
  final String familyId;
  final String name;
  final String url;
  final FileType type;
  final String? localPath;
  final int sizeBytes;
  final String uploadedById;
  final DateTime uploadedAt;

  UploadedFile({
    required this.id,
    required this.familyId,
    required this.name,
    required this.url,
    required this.type,
    this.localPath,
    required this.sizeBytes,
    required this.uploadedById,
    required this.uploadedAt,
  });
}

class FileService {
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();
  FirebaseStorage? _storage;

  FirebaseStorage get storage {
    _storage ??= FirebaseStorage.instance;
    return _storage!;
  }

  Future<UploadedFile?> pickAndUploadImage(
    String familyId,
    String userId,
    String userName,
  ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image == null) return null;
      return await _handleUpload(familyId, userId, userName, FileType.image, image);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<UploadedFile?> captureAndUploadImage(
    String familyId,
    String userId,
    String userName,
  ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image == null) return null;
      return await _handleUpload(familyId, userId, userName, FileType.image, image);
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  Future<UploadedFile?> pickAndUploadVideo(
    String familyId,
    String userId,
    String userName,
  ) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );
      if (video == null) return null;
      return await _handleUpload(familyId, userId, userName, FileType.video, video);
    } catch (e) {
      debugPrint('Error picking video: $e');
      return null;
    }
  }

  Future<UploadedFile?> captureAndUploadVideo(
    String familyId,
    String userId,
    String userName,
  ) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      if (video == null) return null;
      return await _handleUpload(familyId, userId, userName, FileType.video, video);
    } catch (e) {
      debugPrint('Error capturing video: $e');
      return null;
    }
  }

  Future<UploadedFile?> pickAndUploadDocument(
    String familyId,
    String userId,
    String userName,
  ) async {
    try {
      final XFile? doc = await _picker.pickMedia();
      if (doc == null) return null;
      final type = doc.name.toLowerCase().endsWith('.pdf') ? FileType.document : FileType.image;
      return await _handleUpload(familyId, userId, userName, type, doc);
    } catch (e) {
      debugPrint('Error picking document: $e');
      return null;
    }
  }

  Future<UploadedFile?> _handleUpload(
    String familyId,
    String userId,
    String userName,
    FileType type,
    XFile file,
  ) async {
    final fileId = _uuid.v4();
    final fileName = file.name;
    final ext = fileName.split('.').last;
    final storagePath = 'families/$familyId/files/$fileId.$ext';

    try {
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        final metadata = SettableMetadata(contentType: _getContentType(ext));
        await storage.ref(storagePath).putData(
          bytes,
          metadata,
        );
      } else if (Platform.isIOS || Platform.isAndroid) {
        await storage.ref(storagePath).putFile(File(file.path));
      }

      final url = await storage.ref(storagePath).getDownloadURL();
      
      return UploadedFile(
        id: fileId,
        familyId: familyId,
        name: fileName,
        url: url,
        type: type,
        localPath: file.path,
        sizeBytes: 0,
        uploadedById: userId,
        uploadedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error uploading: $e');
      return _createLocalFallback(familyId, userId, fileName, type, file.path);
    }
  }

  String _getContentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'doc':
      case 'docx':
        return 'application/msword';
      default:
        return 'application/octet-stream';
    }
  }

  UploadedFile _createLocalFallback(
    String familyId,
    String userId,
    String fileName,
    FileType type,
    String localPath,
  ) {
    return UploadedFile(
      id: _uuid.v4(),
      familyId: familyId,
      name: fileName,
      url: localPath,
      type: type,
      localPath: localPath,
      sizeBytes: 0,
      uploadedById: userId,
      uploadedAt: DateTime.now(),
    );
  }

  Future<List<UploadedFile>> getFamilyFiles(String familyId) async {
    try {
      await storage.ref('families/$familyId/files').listAll();
      return [];
    } catch (e) {
      debugPrint('Error listing files: $e');
      return [];
    }
  }

  Future<void> deleteFile(String familyId, String fileId) async {
    try {
      await storage.ref('families/$familyId/files/$fileId').delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  Future<String?> saveToLocal(String familyId, String fileName, List<int> bytes) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileDir = Directory('${dir.path}/families/$familyId');
      if (!await fileDir.exists()) {
        await fileDir.create(recursive: true);
      }
      final file = File('${fileDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('Error saving locally: $e');
      return null;
    }
  }
}