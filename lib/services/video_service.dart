import 'package:dio/dio.dart';
import 'package:hani_booki/_core/env.dart';
import 'package:logger/logger.dart';

Future<String> fetchVimeoVideoUrl(String videoId) async {
  String accessToken = Env.get('VIMEO_TOKEN');

  final dio = Dio();

  dio.options.headers = {
    'Authorization': 'Bearer $accessToken',
  };

  final response = await dio.get('https://api.vimeo.com/videos/$videoId');

  if (response.statusCode == 200) {
    Logger().d(response.data['player_embed_url']);
    return response.data['player_embed_url'];
  } else {
    throw Exception('Failed to fetch Vimeo video URL');
  }
}
