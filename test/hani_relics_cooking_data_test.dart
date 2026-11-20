import 'package:flutter_test/flutter_test.dart';
import 'package:hani_booki/_data/hani/hani_cooking_data.dart';
import 'package:hani_booki/_data/hani/hani_relics_data.dart';

// 서버 응답 list 항목 그대로 (2026-11 받은 S 과정 샘플)
void main() {
  test('유물찾기 응답 항목을 읽는다', () {
    final d = HaniRelicsData.fromJson({
      'gamok': 'S',
      'ilno': 1,
      'seek_img': 'https://hohoeduimg.speedgabia.com/hohoeduapp/seek/seek-s01.png',
      'answer_img': 'https://hohoeduimg.speedgabia.com/hohoeduapp/seek/a-s01.png',
      'wrong_img': 'https://hohoeduimg.speedgabia.com/hohoeduapp/seek/a-s10.png',
    });
    expect(d.ilno, 1);
    expect(d.seekImg, endsWith('seek-s01.png'));
    expect(d.answerImg, endsWith('a-s01.png'));
    expect(d.wrongImg, endsWith('a-s10.png'));
  });

  test('요리 응답 항목을 정답 4장·오답 2장으로 묶고 주제 공백을 지운다', () {
    const base = 'https://hohoeduimg.speedgabia.com/hohoeduapp/bowl/bowl_img';
    final d = HaniCookingData.fromJson({
      'gamok': 'S',
      'ilno': 4,
      'munje': '가족 ',
      'ans1': '祖父', 'ans1_img': '$base/s04_1.png',
      'ans2': '四寸', 'ans2_img': '$base/s04_2.png',
      'ans3': '祖母', 'ans3_img': '$base/s04_3.png',
      'ans4': '父母', 'ans4_img': '$base/s04_4.png',
      'wrong1': '自전車', 'wrong1_img': '$base/s03_1.png',
      'wrong2': '기車', 'wrong2_img': '$base/s03_2.png',
    });
    expect(d.ilno, 4);
    expect(d.topic, '가족');
    expect(d.answers.map((c) => c.word), ['祖父', '四寸', '祖母', '父母']);
    expect(d.answers.last.img, '$base/s04_4.png');
    expect(d.wrongs.map((c) => c.word), ['自전車', '기車']);
    expect(d.wrongs.first.img, '$base/s03_1.png');
  });
}
