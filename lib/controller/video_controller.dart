import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:indactech_video_assesment/db_helper/db_helper.dart';
import 'package:indactech_video_assesment/model/video_model.dart';
import 'package:indactech_video_assesment/services/api_service/api_services.dart';
import 'package:indactech_video_assesment/services/firebase_service/firebase_services.dart';

class VideoController extends GetxController {
  List<VideoModel> videoList = [];
  List<String> likedVideos = [];
  bool isOffline = false;
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    FirebaseService.listenToLikeChanges(); // Listen to Firestore changes
    checkInternetAndFetchData();
  }

  /// ✅ Check Internet and Fetch Videos
  Future<void> checkInternetAndFetchData() async {
    var connectivityResult = (await Connectivity().checkConnectivity()).first;

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet) {
      debugPrint("networking");
      await fetchVideosFromAPI(); // Fetch from API when online

      debugPrint("Internet Working");
    } else {
      await fetchVideosFromDB(); // Fetch from SQLite when offline
      debugPrint("Internet Not Working");
    }
  }

  /// ✅ Fetch Videos from API
  Future<void> fetchVideosFromAPI() async {
    try {
      isLoading = true;
      update();
      videoList = await ApiServices.fetchVideos();
      await DBHelper.saveVideos(videoList);
      await checkAndSyncLikes(); // Sync likes
      print("Fetched Videos");
      isLoading = false;
      isOffline = false;
    } catch (e) {
      print('Error fetching videos: $e');
    }
    update();
  }

  /// ✅ Fetch Videos from SQLite if offline
  Future<void> fetchVideosFromDB() async {
    isLoading = true;
    update();
    videoList = await DBHelper.getVideos();
    if (videoList.isEmpty) {
      isOffline = true;
      print('No internet and no videos in DB!');
    } else {
      print('Fetched videos from local DB!');
    }
    isLoading = false;
    update();
  }

  /// ✅ Sync Likes from SQLite and Firestore
  Future<void> checkAndSyncLikes() async {
    for (var video in videoList) {
      int? likesFromFirestore = await FirebaseService.getLikes(video.videoId);
      int localLikes = await DBHelper.totalLikes(video.videoId);

      if (likesFromFirestore != null && likesFromFirestore > localLikes) {
        await DBHelper.updateLikes(video.videoId, likesFromFirestore, 1);
      } else {
        await FirebaseService.syncLikesToFirebase(video);
      }

      bool isLikedLocally = await DBHelper.isVideoLiked(video.videoId);
      if (isLikedLocally) {
        likedVideos.add(video.videoId);
      }
    }
    update();
  }

  /// ✅ Toggle Like
  Future<void> toggleLike(VideoModel video) async {
    if (likedVideos.contains(video.videoId)) {
      likedVideos.remove(video.videoId);
      video.likes = (video.likes > 0) ? video.likes - 1 : 0;
      await DBHelper.updateLikes(video.videoId, video.likes, 0);
    } else {
      likedVideos.add(video.videoId);
      video.likes += 1;
      await DBHelper.updateLikes(video.videoId, video.likes, 1);
    }

    // Sync likes to Firestore if internet is available
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      await FirebaseService.syncLikesToFirebase(video);
    }
    update();
  }
}
