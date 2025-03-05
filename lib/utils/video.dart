// import 'package:hani_booki/services/video_service.dart';
//
// Future<void> initializeVideo() async {
//   try {
//     final url = await fetchVimeoVideoUrl(widget.videoId);
//
//     final autoplayUrl = '$url&autoplay=1';
//     Logger().d('autoplayUrl = $autoplayUrl');
//     if (mounted) {
//       setState(() {
//         _videoUrl = autoplayUrl;
//         _controller = WebViewController()
//           ..setJavaScriptMode(JavaScriptMode.unrestricted)
//           ..loadRequest(
//             Uri.parse(url),
//             headers: {"Referer": "https://hohoedu.co.kr"},
//           );
//       });
//     }
//   } catch (e) {
//     Logger().e('failed $e');
//   }
// }