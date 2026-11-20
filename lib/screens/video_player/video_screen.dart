import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/booki/booki_home_data.dart';
import 'package:hani_booki/_data/hani/hani_home_data.dart';
import 'package:hani_booki/services/booki/booki_content_service.dart';
import 'package:hani_booki/services/hani/hani_content_service.dart';
import 'package:hani_booki/services/mission/mission_clear_service.dart';
import 'package:hani_booki/services/mission/mission_save_service.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/services/video_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/star_event_mixin.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

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

class _VideoScreenState extends State<VideoScreen> with TickerProviderStateMixin, StarEventMixin<VideoScreen> {
  late final WebViewController _controller;
  String accessToken = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
    Get.find<BgmController>().pauseBgm();
    _fetchAccessToken();
    Logger().d('widget.content = ${widget.content}');
    Logger().d('widget.keyCode = ${widget.keyCode}');

    initStarEventFromServer(
      btype: () {
        final first = widget.keyCode.substring(0, 1);
        if (['Y', 'G', 'S'].contains(first)) return 'H';
        if (['K', 'D', 'J'].contains(first)) return 'B';
        return '';
      }(),
      hosu: widget.keyCode.substring(2, 4),
      gb: widget.content,
    );
  }

  WebViewController _buildController() {
    // 사용자 탭 없이 자동재생 허용 (기존 inappwebview mediaPlaybackRequiresUserGesture: false 대응)
    final params = WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{})
        : const PlatformWebViewControllerCreationParams();
    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage((m) => debugPrint("Console Message: ${m.message}"))
      ..addJavaScriptChannel('videoEnded', onMessageReceived: (_) {
        debugPrint("videoEnded 핸들러 호출됨");
        _showResultDialog();
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => _controller.runJavaScript(_injectedJs),
      ));
    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
    return controller;
  }

  Future<void> _fetchAccessToken() async {
    try {
      final token = await fetchVimeoVideoUrl(widget.videoId);
      await _controller.loadRequest(Uri.parse(token), headers: {"Referer": "https://hohoedu.co.kr"});
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
        onTapBackIcon: () async {
          final result = await _controller.runJavaScriptReturningResult(
            "typeof checkVideoWatched === 'function' ? checkVideoWatched() : false",
          );
          // iOS는 bool/1, Android는 문자열 'true'로 돌아옴
          if (result == true || result == 1 || result.toString() == 'true') {
            _showResultDialog();
          } else {
            showBackDialog(false);
          }
        },
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          ...buildStarWidgets(widget.keyCode),
        ],
      ),
    );
  }

  Future<void> _refreshHomeData() async {
    final userData = Get.find<UserDataController>();
    final first = widget.keyCode.substring(0, 1);
    if (['Y', 'G', 'S'].contains(first)) {
      await haniContentService(widget.keyCode, userData.userData!.id, userData.userData!.year);
      // 서버 edate 반영이 늦는 경우가 있어 방금 완료한 시점으로 즉시 덮어써 아이콘이 바로 보이게 함
      Get.find<HaniHomeDataController>().markJustPlayed(widget.content);
    } else {
      await bookiContentService(widget.keyCode, userData.userData!.id, userData.userData!.year);
      Get.find<BookiHomeDataController>().markJustPlayed(widget.content);
    }
  }

  void _showResultDialog() async {
    final starResult = await starUpdateService(widget.content, widget.keyCode);
    final result = await missionSaveService(missionNum: 2, gb: widget.content, keycode: widget.keyCode);

    if (result.success) {
      await showStampDialog(widget.keyCode);
    }

    Logger().d("starResult.result = ${starResult.result}");
    if (starResult.result == '0000') {
      lottieDialog(
        onMain: () {
          Get.back();
          _refreshHomeData();
        },
      );
    } else if (starResult.result == '8888') {
      cooltimeDialog(
        lastTime: starResult.edate ?? '',
        onMain: () {
          Get.back();
          _refreshHomeData();
        },
      );
    }
  }

  @override
  void dispose() {
    Get.find<BgmController>().resumeBgm();
    disposeStarEvent();
    super.dispose();
  }
}

const String _injectedJs = r'''function mergeTimeRanges(timeRanges, tolerance = 0.1) {
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

function checkVideoWatched() {
  var video = document.querySelector('video');
  if (!video) return false;
  return hasPlayedEntireVideo(video);
}

function exitNativeFullscreen(video) {
  // 아이패드는 영상 종료 시 네이티브 전체화면이 자동으로 닫히지 않아 명시적으로 닫아줌
  try {
    if (video.webkitExitFullscreen) {
      video.webkitExitFullscreen();
    } else if (document.webkitExitFullscreen) {
      document.webkitExitFullscreen();
    } else if (document.exitFullscreen) {
      document.exitFullscreen();
    }
  } catch (e) {
    console.log('exitNativeFullscreen error: ' + e);
  }
}

function handleVideo(video) {
  video.addEventListener('loadedmetadata', function() {
    console.log("비디오 길이: " + video.duration);
  });

  video.addEventListener('ended', function() {
    exitNativeFullscreen(video);
    if (hasPlayedEntireVideo(video)) {
      console.log("전체 재생 완료 (90% 이상 시청)");
      videoEnded.postMessage('');
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
''';
