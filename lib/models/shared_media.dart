class SharedMedia {
  final String id;
  final String familyId;
  final String uploadedBy;
  final String uploaderName;
  final String fileName;
  final String fileUrl;
  final String thumbnailUrl;
  final bool isImage;
  final bool isVideo;
  final DateTime createdAt;

  SharedMedia({
    required this.id,
    required this.familyId,
    required this.uploadedBy,
    required this.uploaderName,
    required this.fileName,
    required this.fileUrl,
    this.thumbnailUrl = '',
    this.isImage = true,
    this.isVideo = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'isImage': isImage,
      'isVideo': isVideo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SharedMedia.fromMap(Map<String, dynamic> map) {
    return SharedMedia(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      uploadedBy: map['uploadedBy'] as String,
      uploaderName: map['uploaderName'] as String,
      fileName: map['fileName'] as String,
      fileUrl: map['fileUrl'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String? ?? '',
      isImage: map['isImage'] as bool? ?? true,
      isVideo: map['isVideo'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}