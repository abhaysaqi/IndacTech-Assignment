import 'package:flutter/material.dart';
import 'package:indactech_video_assesment/model/video_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;
  static const String dbName = 'videos.db';
  static const String table = 'videos';

  /// Initialize DB
  static Future<Database> get db async {
    _db ??= await initDB();
    return _db!;
  }

  /// Create Table for Videos
  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $table (
            videoId TEXT PRIMARY KEY,
            title TEXT,
            thumbnailUrl TEXT,
            videoUrl TEXT,
            likes INTEGER,
            isLiked INTEGER
          )
        ''');
      },
    );
  }

  /// Save Videos in SQLite
  static Future<void> saveVideos(List<VideoModel> videos) async {
    final dbClient = await db;
    await dbClient.delete(table); // Clear old data before insert
    for (var video in videos) {
      await dbClient.insert(table, video.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Fetch Videos from SQLite
  static Future<List<VideoModel>> getVideos() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(table);
    if (maps.isEmpty) {
      debugPrint("EMPTY TABLE DATA");
      return [];
    }
    return List.generate(maps.length, (i) => VideoModel.fromJson(maps[i]));
  }

  /// Check if Video is Liked
  static Future<bool> isVideoLiked(String id) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps =
        await dbClient.query(table, where: 'videoId = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return maps.first['isLiked'] == 1;
    }
    return false;
  }

  /// Get Total Likes
  static Future<int> totalLikes(String id) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps =
        await dbClient.query(table, where: 'videoId = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return maps.first['likes'] as int? ?? 0;
    }
    return 0;
  }

  /// Update Likes in SQLite
  static Future<void> updateLikes(String id, int likes, int isLiked) async {
    final dbClient = await db;
    await dbClient.update(
      table,
      {'likes': likes, 'isLiked': isLiked},
      where: 'videoId = ?',
      whereArgs: [id],
    );
  }
}
