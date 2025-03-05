import 'package:xml/xml.dart';

class SvgPathParser {
  // 서버에서 전달받은 SVG 데이터를 사용하여 특정 클래스의 path들을 가져오는 메서드
  static List<String> getPathsByClassFromData(
      String svgData, String className) {
    final document = XmlDocument.parse(svgData);

    return document
        .findAllElements('path')
        .where((element) => element.getAttribute('class') == className)
        .map((element) => element.getAttribute('d') ?? '')
        .toList();
  }

  // 서버에서 전달받은 SVG 데이터를 사용하여 모든 요소를 가져오는 메서드
  static List<Map<String, String>> getAllElementsFromData(String svgData) {
    final document = XmlDocument.parse(svgData);

    final pathElements = document
        .findAllElements('path')
        .map((element) {
          final elementClass = element.getAttribute('class') ?? '';
          if (elementClass != 'st0') {
            return {
              'type': 'path',
              'd': element.getAttribute('d') ?? '',
              'class': elementClass
            };
          }
          return null;
        })
        .whereType<Map<String, String>>()
        .toList();

    final lineElements = document
        .findAllElements('line')
        .map((element) {
          final elementClass = element.getAttribute('class') ?? '';
          if (elementClass != 'st3' && elementClass != 'st0') {
            return {
              'type': 'line',
              'x1': element.getAttribute('x1') ?? '0',
              'y1': element.getAttribute('y1') ?? '0',
              'x2': element.getAttribute('x2') ?? '0',
              'y2': element.getAttribute('y2') ?? '0',
              'class': elementClass,
            };
          }
          return null;
        })
        .whereType<Map<String, String>>()
        .toList();

    return [...pathElements, ...lineElements];
  }
}
