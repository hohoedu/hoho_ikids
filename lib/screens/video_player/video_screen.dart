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
  // TimeRanges 객체를 배열로 변환
  let ranges = [];
  for (let i = 0; i < timeRanges.length; i++) {
    ranges.push([timeRanges.start(i), timeRanges.end(i)]);
  }
  
  // 시작 시간 기준 정렬
  ranges.sort((a, b) => a[0] - b[0]);
  
  // 병합된 범위를 담을 배열
  let merged = [];
  for (let range of ranges) {
    if (merged.length === 0) {
      merged.push(range);
    } else {
      let last = merged[merged.length - 1];
      // 겹치거나 오차(tolerance) 이내면 병합
      if (range[0] - last[1] <= tolerance) {
        last[1] = Math.max(last[1], range[1]);
      } else {
        merged.push(range);
      }
    }
  }
  return merged;
}

function hasPlayedEntireVideo(video) {
  let played = video.played;
  let tolerance = 0.1;
  let mergedRanges = mergeTimeRanges(played, tolerance);
  
  // 병합된 범위가 하나여야 하고, 시작이 0에 가깝고 끝이 video.duration에 가깝다면 전체 재생으로 판단
  if (mergedRanges.length === 1) {
    let range = mergedRanges[0];
    return range[0] <= tolerance && (video.duration - range[1]) <= tolerance;
  }
  return false;
}

function handleVideo(video) {
  video.addEventListener('loadedmetadata', function() {
    console.log("비디오 길이: " + video.duration);
  });
  
  video.addEventListener('ended', function() {
    if (hasPlayedEntireVideo(video)) {
      console.log("전체 재생 완료 (건너뛰기 없이)");
      window.flutter_inappwebview.callHandler('videoEnded');
    } else {
      console.log("중간에 건너뛰거나 재생되지 않은 구간이 있음");
    }
  });
}

// 기존에 있는 video 태그 처리
var video = document.querySelector('video');
if (video) {
  handleVideo(video);
}

// MutationObserver를 사용하여 동적으로 추가되는 video 감지
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
