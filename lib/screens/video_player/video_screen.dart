import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/services/video_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';

class VideoScreen extends StatefulWidget {
  final String content;
  final String keyCode;
  final String videoId;

  const VideoScreen({
    super.key,
    required this.videoId,
    required this.keyCode,
    required this.content,
  });

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  InAppWebViewController? _controller;
  String accessToken = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Get.find<BgmController>().pauseBgm();
    _fetchAccessToken();
  }

  Future<void> _fetchAccessToken() async {
    try {
      final token = await fetchVimeoVideoUrl(widget.videoId);
      setState(() {
        accessToken = token;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('토큰 가져오기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || accessToken.isEmpty) {
      return const Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: mBackWhite,
        appBar: MainAppBar(
          title: ' ',
          isContent: false,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: mBackWhite,
      extendBodyBehindAppBar: true,
      appBar: MainAppBar(
        title: ' ',
        isContent: true,
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(accessToken),
          headers: {"Referer": "https://hohoedu.co.kr"},
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
          ),
        ),
        // 콘솔 메시지 확인 (디버그 콘솔에 출력됨)
        onConsoleMessage: (controller, consoleMessage) {
          debugPrint("Console Message: ${consoleMessage.message}");
        },
        onWebViewCreated: (controller) {
          _controller = controller;
          _controller?.addJavaScriptHandler(
            handlerName: 'videoEnded',
            callback: (args) {
              debugPrint("videoEnded 핸들러 호출됨");
              _showResultDialog();
              return;
            },
          );
        },

        onLoadStop: (controller, url) async {
          await controller.evaluateJavascript(
              source: '''function mergeTimeRanges(timeRanges, tolerance = 0.1) {
  let ranges = [];
  for (let i = 0; i < timeRanges.length; i++) {
    ranges.push([timeRanges.start(i), timeRanges.end(i)]);
  }
  ranges.sort((a, b) => a[0] - b[0]);

  let merged = [];
  for (let range of ranges) {
    if (merged.length === 0) {
      merged.push(range);
    } else {
      let last = merged[merged.length - 1];
      if (range[0] - last[1] <= tolerance) {
        last[1] = Math.max(last[1], range[1]);
      } else {
        merged.push(range);
      }
    }
  }
  return merged;
}

function hasPlayedEntireVideo(video, threshold = 0.9, tolerance = 0.1) {
  const played = video.played;
  const mergedRanges = mergeTimeRanges(played, tolerance);

  // 재생된 구간 길이의 합 계산
  const playedSeconds = mergedRanges
    .reduce((sum, r) => sum + (r[1] - r[0]), 0);

  // 90% 이상 재생되었으면 true
  return playedSeconds >= threshold * video.duration;
}

function handleVideo(video) {
  video.addEventListener('loadedmetadata', function() {
    console.log("비디오 길이: " + video.duration);
  });
  
  video.addEventListener('ended', function() {
    if (hasPlayedEntireVideo(video)) {
      console.log("전체 재생 완료 (90% 이상 시청)");
      window.flutter_inappwebview.callHandler('videoEnded');
    } else {
      console.log("재생되지 않은 구간이 있습니다");
    }
  });
}

// 기존에 있는 video 태그 처리
var video = document.querySelector('video');
if (video) {
  handleVideo(video);
}

// 동적으로 추가되는 video 감지
var observer = new MutationObserver(function(mutations) {
  mutations.forEach(function(mutation) {
    mutation.addedNodes.forEach(function(node) {
      if (node.tagName === 'VIDEO') {
        handleVideo(node);
      }
    });
  });
});
observer.observe(document.body, { childList: true, subtree: true });
''');
        },
      ),
    );
  }

  void _showResultDialog() async {
    await starUpdateService(widget.content, widget.keyCode);
    lottieDialog(
      onMain: () {
        Get.back();
        Get.back();
      },
      onReset: () {
        Get.back();
        _controller?.reload();
      },
    );
  }
  @override
  void dispose() {
    Get.find<BgmController>().resumeBgm();
    super.dispose();
  }
}
