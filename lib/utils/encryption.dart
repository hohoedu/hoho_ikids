import 'dart:convert';
import 'package:crypto/crypto.dart';

//sha256 암호화
String sha256_convertHash(String password) {
  final bytes = utf8.encode(password);
  final hash = sha256.convert(bytes);
  return hash.toString();
}

// md5 암호화
String md5_convertHash(String password) {
  final bytes = utf8.encode(password);
  final hash = md5.convert(bytes);
  return hash.toString();
}
