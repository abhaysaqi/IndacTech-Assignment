import 'dart:convert';

import 'package:indactech_video_assesment/model/video_model.dart';
import 'package:http/http.dart' as http;
import 'package:indactech_video_assesment/utils/constants.dart';

class ApiServices {
  static Future<List<VideoModel>> fetchVideos() async {
    final String youtubeSearch = "flutter development small videos";
    try {
      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$youtubeSearch&type=video&maxResults=${Constants.perPage}&key=${Constants.youtubeApiKey}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> items = data['items'];
        List<VideoModel> videos = items
            .where((item) => item['id']['kind'] == 'youtube#video')
            .map((item) => VideoModel.fromJson(item))
            .toList();
        for (var video in videos) {
          print('Video ID: ${video.videoId}');
          print('Title: ${video.title}');
          print('Thumbnail: ${video.thumbnailUrl}');
          print('Video URL: ${video.videoUrl}');
          print('-------------');
        }

        return videos;
      } else {
        throw Exception('Failed to load videos');
      }
    } on Exception catch (e) {
      throw Exception(e);
    }
  }
}
