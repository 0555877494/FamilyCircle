import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/family_user.dart';
import '../models/message.dart';
import '../models/calendar_event.dart';
import '../models/shared_media.dart';

class LocalDatabase {
  static Database? _database;
  static final LocalDatabase instance = LocalDatabase._internal();
  
  LocalDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'family_circle.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        family_id TEXT NOT NULL,
        first_name TEXT NOT NULL,
        avatar_url TEXT,
        role TEXT NOT NULL,
        is_kid_mode INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        family_id TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        sender_name TEXT NOT NULL,
        sender_avatar TEXT,
        group_id TEXT NOT NULL,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        media_url TEXT,
        latitude REAL,
        longitude REAL,
        location_name TEXT,
        status TEXT DEFAULT 'sent',
        created_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE calendar_events (
        id TEXT PRIMARY KEY,
        family_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT,
        created_by TEXT NOT NULL,
        member_ids TEXT NOT NULL,
        location TEXT,
        repeat TEXT DEFAULT 'none',
        is_emergency INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE media (
        id TEXT PRIMARY KEY,
        family_id TEXT NOT NULL,
        uploaded_by TEXT NOT NULL,
        uploader_name TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_url TEXT NOT NULL,
        thumbnail_url TEXT,
        is_image INTEGER DEFAULT 1,
        is_video INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE message_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message_id TEXT NOT NULL,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE families (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_by TEXT NOT NULL,
        invite_code TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_messages_group ON messages(group_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_messages_synced ON messages(is_synced)
    ''');
    await db.execute('''
      CREATE INDEX idx_events_date ON calendar_events(start_time)
    ''');
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {}

  Future<void> insertMessage(Message message) async {
    final db = await database;
    await db.insert(
      'messages',
      {
        'id': message.id,
        'family_id': message.familyId,
        'sender_id': message.senderId,
        'sender_name': message.senderName,
        'sender_avatar': message.senderAvatar,
        'group_id': message.groupId,
        'type': message.type.name,
        'content': message.content,
        'media_url': message.mediaUrl,
        'latitude': message.latitude,
        'longitude': message.longitude,
        'location_name': message.locationName,
        'status': message.status.name,
        'created_at': message.createdAt.toIso8601String(),
        'is_synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Message>> getMessages(String groupId, {int limit = 50}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((map) => _messageFromMap(map)).toList();
  }

  Future<void> markMessageSynced(String messageId) async {
    final db = await database;
    await db.update(
      'messages',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<List<Message>> getUnsyncedMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'is_synced = 0',
    );
    return maps.map((map) => _messageFromMap(map)).toList();
  }

  Message _messageFromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      familyId: map['family_id'] as String,
      senderId: map['sender_id'] as String,
      senderName: map['sender_name'] as String,
      senderAvatar: map['sender_avatar'] as String?,
      groupId: map['group_id'] as String,
      type: MessageType.values.firstWhere((e) => e.name == map['type']),
      content: map['content'] as String,
      mediaUrl: map['media_url'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      locationName: map['location_name'] as String?,
      status: MessageStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Future<void> insertCalendarEvent(CalendarEvent event) async {
    final db = await database;
    await db.insert(
      'calendar_events',
      {
        'id': event.id,
        'family_id': event.familyId,
        'title': event.title,
        'description': event.description,
        'start_time': event.startTime.toIso8601String(),
        'end_time': event.endTime?.toIso8601String(),
        'created_by': event.createdBy,
        'member_ids': event.memberIds.join(','),
        'location': event.location,
        'repeat': event.repeat.name,
        'is_emergency': event.isEmergency ? 1 : 0,
        'created_at': event.createdAt.toIso8601String(),
        'is_synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CalendarEvent>> getCalendarEvents(String familyId, DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'calendar_events',
      where: 'family_id = ? AND start_time >= ? AND start_time < ?',
      whereArgs: [familyId, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'start_time',
    );
    return maps.map((map) => _calendarEventFromMap(map)).toList();
  }

  CalendarEvent _calendarEventFromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'] as String,
      familyId: map['family_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time'] as String) : null,
      createdBy: map['created_by'] as String,
      memberIds: (map['member_ids'] as String).split(','),
      location: map['location'] as String?,
      repeat: EventRepeat.values.firstWhere((e) => e.name == map['repeat']),
      isEmergency: map['is_emergency'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Future<void> insertMedia(SharedMedia media) async {
    final db = await database;
    await db.insert(
      'media',
      {
        'id': media.id,
        'family_id': media.familyId,
        'uploaded_by': media.uploadedBy,
        'uploader_name': media.uploaderName,
        'file_name': media.fileName,
        'file_url': media.fileUrl,
        'thumbnail_url': media.thumbnailUrl,
        'is_image': media.isImage ? 1 : 0,
        'is_video': media.isVideo ? 1 : 0,
        'created_at': media.createdAt.toIso8601String(),
        'is_synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SharedMedia>> getMedia(String familyId, {int limit = 100}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'media',
      where: 'family_id = ?',
      whereArgs: [familyId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((map) => _sharedMediaFromMap(map)).toList();
  }

  SharedMedia _sharedMediaFromMap(Map<String, dynamic> map) {
    return SharedMedia(
      id: map['id'] as String,
      familyId: map['family_id'] as String,
      uploadedBy: map['uploaded_by'] as String,
      uploaderName: map['uploader_name'] as String,
      fileName: map['file_name'] as String,
      fileUrl: map['file_url'] as String,
      thumbnailUrl: map['thumbnail_url'] as String? ?? '',
      isImage: map['is_image'] == 1,
      isVideo: map['is_video'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Future<void> saveUser(FamilyUser user) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'id': user.id,
        'family_id': user.familyId,
        'first_name': user.firstName,
        'avatar_url': user.avatarUrl,
        'role': user.role.name,
        'is_kid_mode': user.isKidMode ? 1 : 0,
        'created_at': user.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<FamilyUser?> getUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (maps.isEmpty) return null;
    return _familyUserFromMap(maps.first);
  }

  FamilyUser _familyUserFromMap(Map<String, dynamic> map) {
    return FamilyUser(
      id: map['id'] as String,
      familyId: map['family_id'] as String,
      firstName: map['first_name'] as String,
      avatarUrl: map['avatar_url'] as String?,
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
      isKidMode: map['is_kid_mode'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('messages');
    await db.delete('calendar_events');
    await db.delete('media');
    await db.delete('message_queue');
  }
}