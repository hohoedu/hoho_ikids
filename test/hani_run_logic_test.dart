import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hani_booki/screens/hani/hari_run/hani_run_data.dart';
import 'package:hani_booki/screens/hani/hari_run/hani_run_logic.dart';

void main() {
  test('8급 한자 50자가 겹치지 않는다', () {
    expect(hanja8, hasLength(50));
    expect(hanja8.map((h) => h.char).toSet(), hasLength(50));
    expect(hanja8.first.reading, '불 화');
  });

  group('HanjaQuiz', () {
    test('첫 문제를 고정할 수 있다', () {
      final first = HanjaQuestion(hanja8[0], hanja8[1], Side.left);
      final quiz = HanjaQuiz(firstQuestion: first, random: Random(1));
      expect(quiz.next(), same(first));
      expect(quiz.next(), isNot(same(first)));
    });

    test('정답과 오답은 항상 다르고, 방금 나온 한자는 바로 다시 안 나온다', () {
      final quiz = HanjaQuiz(random: Random(2));
      final targets = <Hanja>[];
      final sides = <Side>{};
      for (var i = 0; i < 500; i++) {
        final q = quiz.next();
        expect(q.decoy, isNot(same(q.target)));
        expect(q.at(q.targetSide), same(q.target));
        sides.add(q.targetSide);
        targets.add(q.target);
      }
      for (var i = 1; i < targets.length; i++) {
        expect(targets[i], isNot(same(targets[i - 1])), reason: 'at $i');
        if (i >= 2) expect(targets[i], isNot(same(targets[i - 2])));
      }
      expect(sides, {Side.left, Side.right});
    });

    test('틀린 한자는 두 문제 뒤에 다시 나온다', () {
      for (var seed = 0; seed < 30; seed++) {
        final quiz = HanjaQuiz(random: Random(seed));
        final missed = quiz.next().target;
        quiz.markMistake(missed);
        final after = [for (var i = 0; i < 3; i++) quiz.next().target];
        expect(after[0], isNot(same(missed)));
        expect(after[1], isNot(same(missed)));
        expect(after[2], same(missed), reason: 'seed $seed');
      }
    });
  });

  group('HanjaRun', () {
    test('연속으로 맞힐수록 점수를 더 받고, 틀리면 연속이 끊긴다', () {
      final run = HanjaRun();
      expect(run.onCorrect(), 10);
      expect(run.onCorrect(), 12);
      expect(run.onCorrect(), 14);
      expect(run.score, 36);
      run.onMistake(hanja8[0]);
      expect(run.streak, 0);
      expect(run.onCorrect(), 10);
    });

    test('연속 보너스는 30점에서 멈춘다', () {
      final run = HanjaRun();
      for (var i = 0; i < 20; i++) {
        run.onCorrect();
      }
      expect(run.onCorrect(), 30);
    });

    test('하트 3개를 잃으면 끝나고, 틀린 한자는 한 번씩만 기록된다', () {
      final run = HanjaRun();
      run.onMistake(hanja8[0]);
      run.onMistake(hanja8[0]);
      expect(run.isOver, isFalse);
      run.onMistake(hanja8[1]);
      expect(run.isOver, isTrue);
      expect(run.hearts, 0);
      run.onMistake(hanja8[2]);
      expect(run.hearts, 0);
      expect(run.mistakes, [hanja8[0], hanja8[1]]);
    });

    test('장애물에 부딪히면 하트만 잃고 복습 목록엔 안 들어간다', () {
      final run = HanjaRun()..onCorrect();
      run.onCrash();
      expect(run.hearts, HanjaRun.maxHearts - 1);
      expect(run.streak, 0);
      expect(run.mistakes, isEmpty);
    });

    test('맞힐수록 빨라지다가 최고 속도에서 멈춘다', () {
      final run = HanjaRun();
      final start = run.fallSpeed;
      expect(start, HanjaRun.baseSpeed);
      run.onCorrect();
      expect(run.fallSpeed, greaterThan(start));
      for (var i = 0; i < 100; i++) {
        run.onCorrect();
      }
      expect(run.fallSpeed, HanjaRun.maxSpeed);
    });
  });
}
