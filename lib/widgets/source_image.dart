import 'package:flutter/material.dart';

/// 서버 URL(http...)이면 네트워크, 아니면 앱 에셋 (테스트는 에셋으로 돌림)
ImageProvider imageOf(String src) => src.startsWith('http') ? NetworkImage(src) : AssetImage(src) as ImageProvider;

/// [src] 그림. 못 받으면 빈칸 대신 그림 없음 아이콘
Widget sourceImage(String src, {double? width, double? height, BoxFit? fit, Color iconColor = Colors.black26}) => Image(
      image: imageOf(src),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => SizedBox(
        width: width,
        height: height,
        child: Center(child: Icon(Icons.image_not_supported_rounded, color: iconColor, size: 48)),
      ),
    );

/// 그림들을 미리 받아 둠. 실패는 로그만 남김(화면은 sourceImage 가 아이콘으로 대신 보여 줌)
Future<List<void>> precacheSources(Iterable<String> srcs, BuildContext context) => Future.wait([
      for (final src in srcs)
        precacheImage(imageOf(src), context, onError: (e, _) => debugPrint('그림 받기 실패($src): $e')),
    ]);
