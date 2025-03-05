import 'package:flutter/material.dart';

Color parseRGB(String rgbString) {
  try {
    final cleaned = rgbString.replaceAll(RegExp(r'[^0-9,]'), '');
    final rgbValues = cleaned.split(',').map((e) => int.parse(e)).toList();

    return Color.fromARGB(255, rgbValues[0], rgbValues[1], rgbValues[2]);
  } catch (e) {
    return Colors.transparent;
  }
}
