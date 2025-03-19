import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:indactech_video_assesment/controller/video_controller.dart';
import 'package:indactech_video_assesment/model/video_model.dart';

class VideoTile extends StatelessWidget {
  final VideoModel video;
  const VideoTile({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final VideoController con = Get.find();
    bool isLiked = con.likedVideos.contains(video.videoId);
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: con.isOffline
                  ? Image.asset(video.thumbnailUrl)
                  : CachedNetworkImage(imageUrl: video.thumbnailUrl)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    video.title,
                    style: const TextStyle(fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked
                              ? Colors.red
                              : Colors.grey.withValues(alpha: 0.5)),
                      onPressed: () {
                        con.toggleLike(video);
                      },
                    ),
                    Text('${video.likes} Likes',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
