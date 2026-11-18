import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hani_booki/screens/hani/hari_run/hani_run_data.dart';
import 'package:hani_booki/screens/hani/hari_run/hani_run_logic.dart';

void main() {
  test('과정별 동전 목록: 번호·훈음이 안 겹치고, 동전 이미지가 모두 있음', () {
    for (final (list, prefix, count) in [(runHanjaY, 'y', 64), (runHanjaS, 's', 60)]) {
      expect(list, hasLength(count));
      expect(list.map((h) => h.no).toSet(), hasLength(count));
      expect(list.map((h) => h.text).toSet(), hasLength(count));
      for (var i = 0; i < count; i++) {
        expect(list[i].no, '$prefix${(i + 1).toString().padLeft(2, '0')}');
        expect(File('assets/images/hani/run/coin-${list[i].no}.png').existsSync(), isTrue, reason: list[i].no);
      }
    }
    expect(runHanjaY.first.text, '달 월');
    expect(runHanjaFor('S011'), same(runHanjaS));
    expect(runHanjaFor('Y011'), same(runHanjaY));
    expect(runHanjaFor('G011'), same(runHanjaY)); // G는 세트가 없어 y
  });

  group('HanjaQuiz', () {
    test('첫 문제를 고정할 수 있다', () {
      final first = HanjaQuestion(runHanjaY[0], runHanjaY[1], Side.left);
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
    test('빨라질수록 점수가 10점에서 20점까지 오르고, 틀려도 속도 점수는 유지', () {
      final run = HanjaRun();
      expect(run.onCorrect(), 10);
      final second = run.onCorrect();
      expect(second, inInclusiveRange(10, 11));
      run.onMistake(runHanjaY[0]);
      expect(run.streak, 0);
      expect(run.onCorrect(), greaterThanOrEqualTo(second));
      for (var i = 0; i < 30; i++) {
        run.onCorrect();
      }
      expect(run.onCorrect(), 20);
    });

    test('점수 구간별 별 개수', () {
      final run = HanjaRun();
      expect(run.stars, 0);
      for (final (score, stars) in [(49, 0), (50, 1), (119, 1), (120, 2), (200, 3), (300, 4), (499, 4), (500, 5), (2000, 5)]) {
        run.score = score;
        expect(run.stars, stars, reason: '$score점');
      }
    });

    test('하트 3개를 잃으면 끝나고, 틀린 한자는 한 번씩만 기록된다', () {
      final run = HanjaRun();
      run.onMistake(runHanjaY[0]);
      run.onMistake(runHanjaY[0]);
      expect(run.isOver, isFalse);
      run.onMistake(runHanjaY[1]);
      expect(run.isOver, isTrue);
      expect(run.hearts, 0);
      run.onMistake(runHanjaY[2]);
      expect(run.hearts, 0);
      expect(run.mistakes, [runHanjaY[0], runHanjaY[1]]);
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
