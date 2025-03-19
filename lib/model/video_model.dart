class VideoModel {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  int likes;

  VideoModel({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    this.likes=0
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      videoId: json['id']['videoId'] ?? '',
      title: json['snippet']['title'] ?? '',
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'] ?? '',
      videoUrl: 'https://www.youtube.com/watch?v=${json['id']['videoId']}',
      likes: json['likes'] ?? 0,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'likes': likes,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'likes': likes,
    };
  }

  
}
