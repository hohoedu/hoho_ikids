import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';

final Dio dio = Dio(
  BaseOptions(
    baseUrl: "https://hohoschool.com/hohoeduAPI",
    contentType: "application/json; charset=utf-8",
  ),
);

/// 서버 인증서가 2026년 갱신되면서 신형 루트(Sectigo Root R46)로 체인이 바뀌었는데,
/// R46이 신뢰 저장소에 없는 구형 안드로이드 기기에서 CERTIFICATE_VERIFY_FAILED 로
/// 핸드셰이크가 실패한다. 번들된 R46 루트를 신뢰 목록에 추가해 해결한다.
/// (withTrustedRoots: true 로 기본 시스템 루트는 그대로 유지)
Future<void> setupDioCertificates() async {
  try {
    final certData = await rootBundle.load('assets/certs/sectigo_r46_root.pem');
    final context = SecurityContext(withTrustedRoots: true);
    try {
      context.setTrustedCertificatesBytes(certData.buffer.asUint8List());
    } on TlsException catch (e) {
      // 이미 신뢰 목록에 존재하면(최신 기기) 무시
      Logger().d('R46 cert already trusted: $e');
    }
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => HttpClient(context: context),
    );
    Logger().d('Dio SecurityContext configured with Sectigo Root R46');
  } catch (e) {
    // 설정 실패해도 앱 구동은 계속 (기본 어댑터 사용)
    Logger().e('setupDioCertificates error = $e');
  }
}
