import 'dart:math';

import 'package:hani_booki/screens/hani/hari_run/hani_run_data.dart';

enum Side { left, right }

/// 문제 하나: 팻말에 보일 정답 한자와, 반대쪽에 떨어질 오답 한자.
class HanjaQuestion {
  const HanjaQuestion(this.target, this.decoy, this.targetSide);

  final Hanja target;
  final Hanja decoy;
  final Side targetSide;

  Hanja at(Side side) => side == targetSide ? target : decoy;
}

/// 문제를 차례로 낸다. 방금 나온 한자는 바로 다시 내지 않고,
/// 틀린 한자는 두 문제 뒤에 다시 낸다.
class HanjaQuiz {
  HanjaQuiz({List<Hanja> pool = hanja8, Random? random, this.firstQuestion})
      : assert(pool.length >= 4),
        _pool = pool,
        _random = random ?? Random();

  /// 첫 문제를 고정하고 싶을 때(예: 火 / 水).
  final HanjaQuestion? firstQuestion;

  final List<Hanja> _pool;
  final Random _random;
  final _recent = <Hanja>[];
  final _review = <(Hanja, int)>[];
  int _asked = 0;

  /// 지금까지 낸 문제 수
  int get asked => _asked;

  static const _recentSize = 2;
  static const _reviewGap = 2;

  /// 틀린 한자를 복습 목록에 넣는다.
  void markMistake(Hanja hanja) {
    if (_review.any((r) => identical(r.$1, hanja))) return;
    _review.add((hanja, _asked + _reviewGap));
  }

  HanjaQuestion next() {
    final question = _asked == 0 && firstQuestion != null ? firstQuestion! : _makeQuestion();
    _asked++;
    _recent.add(question.target);
    if (_recent.length > _recentSize) _recent.removeAt(0);
    _review.removeWhere((r) => identical(r.$1, question.target));
    return question;
  }

  HanjaQuestion _makeQuestion() {
    final due = _review.where((r) => r.$2 <= _asked && !_recent.contains(r.$1)).map((r) => r.$1);
    final Hanja target;
    if (due.isNotEmpty) {
      target = due.first;
    } else {
      final options = _pool.where((h) => !_recent.contains(h)).toList();
      target = options[_random.nextInt(options.length)];
    }
    Hanja decoy;
    do {
      decoy = _pool[_random.nextInt(_pool.length)];
    } while (identical(decoy, target));
    final side = _random.nextBool() ? Side.left : Side.right;
    return HanjaQuestion(target, decoy, side);
  }
}

/// 한 판의 진행 상태: 하트, 점수, 연속 정답, 떨어지는 속도.
class HanjaRun {
  static const maxHearts = 3;
  static const baseSpeed = 260.0;
  static const maxSpeed = 720.0;

  int hearts = maxHearts;
  int score = 0;
  int streak = 0;
  int correctCount = 0;

  /// 틀리거나 놓친 한자(게임이 끝나면 복습용으로 보여 준다).
  final List<Hanja> mistakes = [];

  bool get isOver => hearts <= 0;

  /// 맞힐 때마다 6%씩 빨라지고 [maxSpeed]에서 멈춘다.
  double get fallSpeed => min(baseSpeed * pow(1.06, correctCount), maxSpeed).toDouble();

  /// 정답 처리 후 얻은 점수를 돌려준다. 연속으로 맞힐수록 더 받는다.
  int onCorrect() {
    streak++;
    correctCount++;
    final gained = 10 + 2 * min<int>(streak - 1, 10);
    score += gained;
    return gained;
  }

  /// 장애물(돌·쓰레기통)에 부딪힘: 하트 하나를 잃고 연속 정답이 끊긴다. 복습 목록엔 안 넣음.
  void onCrash() {
    if (isOver) return;
    hearts--;
    streak = 0;
  }

  /// 오답이나 놓침: 하트 하나를 잃고 연속 정답이 끊긴다.
  void onMistake(Hanja target) {
    if (isOver) return;
    hearts--;
    streak = 0;
    if (!mistakes.contains(target)) mistakes.add(target);
  }
}
