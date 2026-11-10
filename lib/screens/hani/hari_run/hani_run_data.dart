/// 한자 한 글자와 훈음(뜻과 소리).
class Hanja {
  const Hanja(this.char, this.meaning, this.sound);

  final String char;

  /// 훈(뜻). 예: 불
  final String meaning;

  /// 음(소리). 예: 화
  final String sound;

  /// 팻말에 쓰는 훈음. 예: 불 화
  String get reading => '$meaning $sound';

  @override
  String toString() => '$char($reading)';
}

/// 한자능력검정시험 8급 배정 한자 50자.
const hanja8 = <Hanja>[
  Hanja('火', '불', '화'),
  Hanja('水', '물', '수'),
  Hanja('木', '나무', '목'),
  Hanja('金', '쇠', '금'),
  Hanja('土', '흙', '토'),
  Hanja('日', '날', '일'),
  Hanja('月', '달', '월'),
  Hanja('山', '메', '산'),
  Hanja('一', '한', '일'),
  Hanja('二', '두', '이'),
  Hanja('三', '석', '삼'),
  Hanja('四', '넉', '사'),
  Hanja('五', '다섯', '오'),
  Hanja('六', '여섯', '륙'),
  Hanja('七', '일곱', '칠'),
  Hanja('八', '여덟', '팔'),
  Hanja('九', '아홉', '구'),
  Hanja('十', '열', '십'),
  Hanja('萬', '일만', '만'),
  Hanja('人', '사람', '인'),
  Hanja('女', '여자', '녀'),
  Hanja('父', '아비', '부'),
  Hanja('母', '어미', '모'),
  Hanja('兄', '형', '형'),
  Hanja('弟', '아우', '제'),
  Hanja('王', '임금', '왕'),
  Hanja('民', '백성', '민'),
  Hanja('軍', '군사', '군'),
  Hanja('先', '먼저', '선'),
  Hanja('生', '날', '생'),
  Hanja('學', '배울', '학'),
  Hanja('校', '학교', '교'),
  Hanja('敎', '가르칠', '교'),
  Hanja('室', '집', '실'),
  Hanja('門', '문', '문'),
  Hanja('國', '나라', '국'),
  Hanja('韓', '한국', '한'),
  Hanja('東', '동녘', '동'),
  Hanja('西', '서녘', '서'),
  Hanja('南', '남녘', '남'),
  Hanja('北', '북녘', '북'),
  Hanja('中', '가운데', '중'),
  Hanja('外', '바깥', '외'),
  Hanja('大', '큰', '대'),
  Hanja('小', '작을', '소'),
  Hanja('長', '긴', '장'),
  Hanja('寸', '마디', '촌'),
  Hanja('年', '해', '년'),
  Hanja('白', '흰', '백'),
  Hanja('靑', '푸를', '청'),
];
