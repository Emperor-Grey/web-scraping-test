import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:scrap_web/util/dood_extractor.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum MyDataSourceType {
  assets,
  network,
  file,
  webview,
}

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView(
      {super.key, required this.url, required this.dataSourceType});

  final String url;
  final MyDataSourceType dataSourceType;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController? _videoPlayerController; // Making it nullable
  late ChewieController _chewieController;
  late final WebViewController _webViewController;
  bool showWebview = false;

  Future<void> checkAndLoadVideo(String url) async {
    final doodExtractor = DoodExtractor();
    final videoDetails = await doodExtractor.videoFromUrl(url);

    if ((videoDetails.containsKey("error")) ||
        videoDetails.containsKey('cloudflare')) {
      // Cloudflare or CAPTCHA detected, show web view
      setState(() {
        showWebview = true;
      });
    } else {
      // No CAPTCHA, proceed with video loading
      final videoUrl = videoDetails['videoUrl'];
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoPlayerController?.initialize(); // Initialize if not null
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setBackgroundColor(const Color(0x00000000))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            if (url.contains("captcha") || url.contains("cloudflare")) {
              // we can display a message to the user to solve the CAPTCHA
              // or handle the Cloudflare protection here.
            } else {
              // Load the video link
              await checkAndLoadVideo(url);
            }
          },
        ),
      );

    switch (widget.dataSourceType) {
      case MyDataSourceType.assets:
        _videoPlayerController = VideoPlayerController.asset(widget.url);
        break;
      case MyDataSourceType.network:
        // Loading the initial URL in the web view
        showWebview = true;
        _webViewController.loadRequest(Uri.parse(widget.url));
        break;
      case MyDataSourceType.file:
        _videoPlayerController = VideoPlayerController.file(File(widget.url));
        break;
      case MyDataSourceType.webview:
        // Loading the page in the web view
        showWebview = true;
        _webViewController.loadRequest(Uri.parse(widget.url));
        break;
    }

    _videoPlayerController?.addListener(() {
      if (_videoPlayerController != null &&
          _videoPlayerController!.value.hasError) {
        debugPrint(
          "VideoPlayerController Error: ${_videoPlayerController!.value.errorDescription}",
        );
      }
    });

    _chewieController = ChewieController(
      allowFullScreen: true,
      fullScreenByDefault: true,
      videoPlayerController: _videoPlayerController!, // Using nullable controller
      aspectRatio: 16 / 9,
      autoPlay: true,
      allowMuting: true,
      zoomAndPan: true,
      showControls: true,
      useRootNavigator: true,
      autoInitialize: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose(); // Dispose if not null
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (showWebview)
              Expanded(
                child: WebViewWidget(
                  controller: _webViewController,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Chewie(
                    controller: _chewieController,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
