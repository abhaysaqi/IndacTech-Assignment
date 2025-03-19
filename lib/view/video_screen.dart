import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indactech_video_assesment/controller/video_controller.dart';
import 'package:indactech_video_assesment/utils/responsive.dart';
import 'package:indactech_video_assesment/widgets/video_tile.dart';

class VideoScreen extends StatelessWidget {
  final VideoController con = Get.put(VideoController());

  VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Playlist')),
      body: _pageCotent(context),
    );
  }

  Widget _pageCotent(BuildContext context) {
    return GetBuilder<VideoController>(
      builder: (con) {
        if (con.isOffline && con.videoList.isEmpty) {
          return const Center(
            child: Text(
              'No Internet Connection!\nPlease connect to the internet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          );
        }
        return con.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              )
            : Responsive.isMobile(context)
                ? ListView.builder(
                    itemCount: con.videoList.length,
                    itemBuilder: (context, index) {
                      return VideoTile(video: con.videoList[index]);
                    },
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: con.videoList.length,
                    itemBuilder: (context, index) {
                      return VideoTile(video: con.videoList[index]);
                    },
                  );
      },
    );
  }
}
