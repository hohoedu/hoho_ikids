import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hani_booki/screens/hani/hani_pang/hani_pang_board.dart';

/// 0~2는 테스트에서 직접 배치하는 색이고, '.'은 줄이 생기지 않는
/// 3~5 패턴으로 채운다.
List<String> layout(List<String> rows) => [
  for (var r = 0; r < rows.length; r++)
    String.fromCharCodes([
      for (var c = 0; c < rows[r].length; c++)
        rows[r][c] == '.'
            ? '${3 + (r + c) % 3}'.codeUnitAt(0)
            : rows[r].codeUnitAt(c),
    ]),
];

Set<Pos> clearedPositions(CascadeStep step) =>
    step.cleared.map((c) => c.pos).toSet();

void main() {
  group('fill', () {
    test('처음 보드에는 터지는 줄이 없고 움직일 수가 있다', () {
      for (var seed = 0; seed < 50; seed++) {
        final board = Board(random: Random(seed));
        expect(board.findHint(), isNotNull, reason: 'seed $seed');
        for (final (p, _) in board.tiles) {
          // 아무 칸이나 같은 색 3개가 이어지면 안 된다.
          final color = board.tileAt(p)!.color;
          final right = [
            1,
            2,
          ].every((d) => board.tileAt(Pos(p.row, p.col + d))?.color == color);
          final down = [
            1,
            2,
          ].every((d) => board.tileAt(Pos(p.row + d, p.col))?.color == color);
          expect(right || down, isFalse, reason: 'seed $seed at $p');
        }
      }
    });
  });

  group('swap', () {
    test('인접하지 않은 칸끼리는 바꿀 수 없다', () {
      final board = Board(random: Random(1));
      expect(board.swap(const Pos(0, 0), const Pos(0, 2)).valid, isFalse);
      expect(board.swap(const Pos(0, 0), const Pos(1, 1)).valid, isFalse);
    });

    test('줄이 안 생기는 스왑은 무효이고 보드가 그대로다', () {
      final board = Board.fromLayout(layout(List.filled(8, '........')));
      final before = board.tileAt(const Pos(0, 0))!.id;
      final result = board.swap(const Pos(0, 0), const Pos(0, 1));
      expect(result.valid, isFalse);
      expect(board.tileAt(const Pos(0, 0))!.id, before);
    });

    test('가로 3개를 맞추면 3칸이 지워진다', () {
      final board = Board.fromLayout(
        layout(['00.0....', ...List.filled(7, '........')]),
      );
      final result = board.swap(const Pos(0, 2), const Pos(0, 3));
      expect(result.valid, isTrue);
      final step = result.steps.first;
      expect(clearedPositions(step), {
        const Pos(0, 0),
        const Pos(0, 1),
        const Pos(0, 2),
      });
      expect(step.created, isEmpty);
      expect(step.damage, 3 * baseDamage);
    });

    test('가로 4개를 맞추면 옮긴 칸에 가로 레이저가 생긴다', () {
      final board = Board.fromLayout(
        layout(['00.0....', '..0.....', ...List.filled(6, '........')]),
      );
      final moved = board.tileAt(const Pos(1, 2))!;
      final result = board.swap(const Pos(1, 2), const Pos(0, 2));
      final step = result.steps.first;
      expect(step.created, hasLength(1));
      expect(step.created.first.pos, const Pos(0, 2));
      expect(step.created.first.type, Special.laserH);
      expect(moved.special, Special.laserH);
      expect(clearedPositions(step), {
        const Pos(0, 0),
        const Pos(0, 1),
        const Pos(0, 3),
      });
    });

    test('세로 4개를 맞추면 세로 레이저가 생긴다', () {
      final board = Board.fromLayout(
        layout([
          '0.......',
          '0.......',
          '.0......',
          '0.......',
          ...List.filled(4, '........'),
        ]),
      );
      final result = board.swap(const Pos(2, 1), const Pos(2, 0));
      final step = result.steps.first;
      expect(step.created.single.type, Special.laserV);
      expect(step.created.single.pos, const Pos(2, 0));
    });

    test('L자 5개를 맞추면 블랙홀이 생긴다', () {
      final board = Board.fromLayout(
        layout([
          '.0......',
          '.0......',
          '0.00....',
          ...List.filled(5, '........'),
        ]),
      );
      final result = board.swap(const Pos(2, 0), const Pos(2, 1));
      final step = result.steps.first;
      expect(step.created.single.type, Special.blackHole);
      expect(step.created.single.pos, const Pos(2, 1));
      expect(clearedPositions(step), {
        const Pos(0, 1),
        const Pos(1, 1),
        const Pos(2, 2),
        const Pos(2, 3),
      });
    });
  });

  group('special', () {
    test('가로 레이저가 터지면 그 줄 전체가 지워진다', () {
      final board = Board.fromLayout(
        layout([
          '........',
          '........',
          '00.0....',
          ...List.filled(5, '........'),
        ]),
        specials: {const Pos(2, 0): Special.laserH},
      );
      final step = board.swap(const Pos(2, 2), const Pos(2, 3)).steps.first;
      expect(step.triggered.single.type, Special.laserH);
      expect(clearedPositions(step), {for (var c = 0; c < 8; c++) Pos(2, c)});
    });

    test('블랙홀이 터지면 주변 3x3이 지워진다', () {
      final board = Board.fromLayout(
        layout([
          '........',
          '........',
          '........',
          '.00.0...',
          ...List.filled(4, '........'),
        ]),
        specials: {const Pos(3, 2): Special.blackHole},
      );
      final step = board.swap(const Pos(3, 3), const Pos(3, 4)).steps.first;
      expect(step.triggered.single.type, Special.blackHole);
      expect(clearedPositions(step), {
        for (var r = 2; r <= 4; r++)
          for (var c = 1; c <= 3; c++) Pos(r, c),
      });
    });

    test('레이저가 다른 특수 블록을 지나가면 연쇄로 발동한다', () {
      final board = Board.fromLayout(
        layout([
          '........',
          '........',
          '00.0....',
          ...List.filled(5, '........'),
        ]),
        specials: {
          const Pos(2, 0): Special.laserH,
          const Pos(2, 6): Special.laserV,
        },
      );
      final step = board.swap(const Pos(2, 2), const Pos(2, 3)).steps.first;
      expect(step.triggered.map((t) => t.type).toSet(), {
        Special.laserH,
        Special.laserV,
      });
      final cleared = clearedPositions(step);
      expect(cleared, containsAll([for (var r = 0; r < 8; r++) Pos(r, 6)]));
      expect(cleared, containsAll([for (var c = 0; c < 8; c++) Pos(2, c)]));
    });

    test('특수 블록끼리 바꾸면 줄이 없어도 둘 다 발동한다', () {
      final board = Board.fromLayout(
        layout(List.filled(8, '........')),
        specials: {
          const Pos(4, 4): Special.laserH,
          const Pos(4, 5): Special.laserV,
        },
      );
      final result = board.swap(const Pos(4, 4), const Pos(4, 5));
      expect(result.valid, isTrue);
      final cleared = clearedPositions(result.steps.first);
      expect(cleared, containsAll([for (var c = 0; c < 8; c++) Pos(4, c)]));
      expect(cleared, containsAll([for (var r = 0; r < 8; r++) Pos(r, 4)]));
    });
  });

  group('gravity', () {
    test('지워진 자리 위의 블록이 내려오고 새 블록이 위에서 채워진다', () {
      final board = Board.fromLayout(
        layout(['00.0....', ...List.filled(7, '........')]),
      );
      final step = board.swap(const Pos(0, 2), const Pos(0, 3)).steps.first;
      // 0행에서 지워졌으므로 내려올 기존 블록은 없고 새 블록 3개가 생긴다.
      final news = step.falls.where((f) => f.isNew).toList();
      expect(news, hasLength(3));
      expect(news.every((f) => f.fromRow == -1 && f.toRow == 0), isTrue);
      for (final (p, _) in board.tiles) {
        expect(board.tileAt(p), isNotNull);
      }
    });

    test('세로로 지워지면 위 블록이 그만큼 떨어진다', () {
      final board = Board.fromLayout(
        layout([
          '........',
          '0.......',
          '0.......',
          '.0......',
          ...List.filled(4, '........'),
        ]),
      );
      final top = board.tileAt(const Pos(0, 0))!;
      final step = board.swap(const Pos(3, 1), const Pos(3, 0)).steps.first;
      final fall = step.falls.firstWhere((f) => f.tile.id == top.id);
      expect(fall.fromRow, 0);
      expect(fall.toRow, 3);
      expect(step.falls.where((f) => f.isNew && f.col == 0), hasLength(3));
    });

    test('모든 스왑 후에도 보드는 가득 차 있고 움직일 수가 남아 있다', () {
      final board = Board(random: Random(7));
      for (var i = 0; i < 300; i++) {
        final hint = board.findHint()!;
        final result = board.swap(hint.$1, hint.$2);
        expect(result.valid, isTrue);
        expect(board.tiles.length, 64);
        expect(board.findHint(), isNotNull);
        for (final step in result.steps) {
          expect(step.combo, result.steps.indexOf(step));
        }
      }
    });
  });

  test('연쇄가 이어질수록 데미지 배율이 오른다', () {
    expect(comboMultiplier(0), 1);
    expect(comboMultiplier(1), 1.5);
    expect(comboMultiplier(3), 2.5);
  });
}
