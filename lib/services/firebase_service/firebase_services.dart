import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indactech_video_assesment/db_helper/db_helper.dart';
import 'package:indactech_video_assesment/model/video_model.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String collection = 'likes';

  /// ✅ Sync Likes to Firestore when online
  static Future<void> syncLikesToFirebase(VideoModel video) async {
    await _db.collection(collection).doc(video.videoId).set({
      'likes': video.likes,
    });
  }

  /// ✅ Listen to Firestore updates and sync SQLite
  static void listenToLikeChanges() {
    _db.collection(collection).snapshots().listen((querySnapshot) async {
      for (var change in querySnapshot.docChanges) {
        String videoId = change.doc.id;
        int likes = change.doc.data()?['likes'] ?? 0;

        await DBHelper.updateLikes(videoId, likes, 1);
      }
    });
  }

  /// ✅ Get Likes Count from Firestore
  static Future<int?> getLikes(String id) async {
    final doc = await _db.collection(collection).doc(id).get();
    if (doc.exists) {
      return doc.data()?['likes'] as int?;
    }
    return 0;
  }
}
