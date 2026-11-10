import 'dart:math';

/// 특수 블록 종류.
enum Special { none, laserH, laserV, blackHole }

/// 보드 위의 블록 하나. [id]는 화면 컴포넌트와 연결할 때 쓰는 고유 번호다.
class Tile {
  Tile(this.id, this.color, [this.special = Special.none]);

  final int id;
  final int color;
  Special special;

  bool get isSpecial => special != Special.none;
}

class Pos {
  const Pos(this.row, this.col);

  final int row;
  final int col;

  bool isAdjacent(Pos other) => (row - other.row).abs() + (col - other.col).abs() == 1;

  @override
  bool operator ==(Object other) => other is Pos && other.row == row && other.col == col;

  @override
  int get hashCode => row * 1000 + col;

  @override
  String toString() => '($row,$col)';
}

class ClearedTile {
  const ClearedTile(this.pos, this.tile);

  final Pos pos;
  final Tile tile;
}

class TriggeredSpecial {
  const TriggeredSpecial(this.pos, this.type, this.color);

  final Pos pos;
  final Special type;
  final int color;
}

class CreatedSpecial {
  const CreatedSpecial(this.pos, this.tile, this.type);

  final Pos pos;
  final Tile tile;
  final Special type;
}

/// 블록 낙하 한 건. 새로 생긴 블록은 [fromRow]가 음수(보드 위쪽)다.
class Fall {
  const Fall(this.tile, this.col, this.fromRow, this.toRow);

  final Tile tile;
  final int col;
  final int fromRow;
  final int toRow;

  bool get isNew => fromRow < 0;
}

/// 연쇄 한 단계: 제거 → 특수 블록 생성 → 낙하·리필.
class CascadeStep {
  const CascadeStep({
    required this.combo,
    required this.cleared,
    required this.triggered,
    required this.created,
    required this.falls,
    required this.damage,
  });

  /// 0부터 시작하는 연쇄 순번.
  final int combo;
  final List<ClearedTile> cleared;
  final List<TriggeredSpecial> triggered;
  final List<CreatedSpecial> created;
  final List<Fall> falls;
  final int damage;
}

class MoveResult {
  const MoveResult({
    required this.valid,
    this.steps = const [],
    this.shuffled = false,
  });

  static const invalid = MoveResult(valid: false);

  final bool valid;
  final List<CascadeStep> steps;

  /// 움직일 수 있는 수가 없어서 보드를 섞었는지.
  final bool shuffled;

  int get totalDamage => steps.fold(0, (sum, s) => sum + s.damage);
}

/// 블록 1개당 기본 데미지.
const int baseDamage = 10;

/// 연쇄 순번에 따른 데미지 배율. 연쇄가 이어질 때마다 0.5배씩 오른다.
double comboMultiplier(int combo) => 1 + combo * 0.5;

class _Run {
  _Run(this.horizontal, this.cells);

  final bool horizontal;
  final List<Pos> cells;
}

class _Group {
  final Set<Pos> cells = {};
  final List<_Run> runs = [];
  late final int color;

  Special get specialType {
    if (cells.length >= 5) return Special.blackHole;
    for (final run in runs) {
      if (run.cells.length == 4) {
        return run.horizontal ? Special.laserH : Special.laserV;
      }
    }
    return Special.none;
  }

  /// 가로 줄과 세로 줄이 겹치는 칸(L·T자 모양의 꼭짓점).
  Set<Pos> get intersections {
    final h = runs.where((r) => r.horizontal).expand((r) => r.cells).toSet();
    final v = runs.where((r) => !r.horizontal).expand((r) => r.cells).toSet();
    return h.intersection(v);
  }
}

class Board {
  Board({this.rows = 8, this.cols = 8, this.colorCount = 6, Random? random})
      : _random = random ?? Random(),
        _grid = List.generate(rows, (_) => List<Tile?>.filled(cols, null)) {
    fill();
  }

  /// 테스트용: 문자열 배치로 보드를 만든다. 각 문자는 색 번호(0~9)다.
  /// [specials]로 특정 칸을 특수 블록으로 지정할 수 있다.
  Board.fromLayout(
    List<String> layout, {
    this.colorCount = 6,
    Map<Pos, Special> specials = const {},
    Random? random,
  })  : rows = layout.length,
        cols = layout.first.length,
        _random = random ?? Random(0),
        _grid = List.generate(
          layout.length,
          (_) => List<Tile?>.filled(layout.first.length, null),
        ) {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final color = int.parse(layout[r][c]);
        _grid[r][c] = _newTile(color, specials[Pos(r, c)] ?? Special.none);
      }
    }
  }

  final int rows;
  final int cols;
  final int colorCount;
  final Random _random;
  final List<List<Tile?>> _grid;
  int _nextId = 0;

  Tile? tileAt(Pos p) => inBounds(p) ? _grid[p.row][p.col] : null;

  bool inBounds(Pos p) => p.row >= 0 && p.row < rows && p.col >= 0 && p.col < cols;

  Iterable<(Pos, Tile)> get tiles sync* {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final t = _grid[r][c];
        if (t != null) yield (Pos(r, c), t);
      }
    }
  }

  Tile _newTile(int color, [Special special = Special.none]) => Tile(_nextId++, color, special);

  /// 바로 터지는 줄이 없고, 움직일 수 있는 수가 하나 이상 있는 보드로 채운다.
  void fill() {
    do {
      for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
          _grid[r][c] = _newTile(_safeColor(r, c));
        }
      }
    } while (findHint() == null);
  }

  /// 왼쪽 두 칸이나 위쪽 두 칸과 같은 색이 되지 않는 색을 고른다.
  int _safeColor(int r, int c) {
    final banned = <int>{};
    if (c >= 2 && _grid[r][c - 1]!.color == _grid[r][c - 2]!.color) {
      banned.add(_grid[r][c - 1]!.color);
    }
    if (r >= 2 && _grid[r - 1][c]!.color == _grid[r - 2][c]!.color) {
      banned.add(_grid[r - 1][c]!.color);
    }
    final options = [
      for (var i = 0; i < colorCount; i++)
        if (!banned.contains(i)) i,
    ];
    return options[_random.nextInt(options.length)];
  }

  void _swapCells(Pos a, Pos b) {
    final t = _grid[a.row][a.col];
    _grid[a.row][a.col] = _grid[b.row][b.col];
    _grid[b.row][b.col] = t;
  }

  /// 두 칸을 바꾸고, 터지는 줄이 있으면 연쇄가 끝날 때까지 처리한다.
  /// 줄이 안 생기면 보드를 되돌리고 [MoveResult.invalid]를 돌려준다.
  /// 특수 블록끼리 바꾸면 줄이 없어도 둘 다 발동한다.
  MoveResult swap(Pos a, Pos b) {
    if (!inBounds(a) || !inBounds(b) || !a.isAdjacent(b)) {
      return MoveResult.invalid;
    }
    if (tileAt(a) == null || tileAt(b) == null) return MoveResult.invalid;

    _swapCells(a, b);
    final bothSpecial = tileAt(a)!.isSpecial && tileAt(b)!.isSpecial;
    if (!bothSpecial && _findGroups().isEmpty) {
      _swapCells(a, b);
      return MoveResult.invalid;
    }

    final steps = _resolve(swapped: {a, b}, forced: bothSpecial ? {a, b} : {});
    var shuffled = false;
    if (findHint() == null) {
      shuffle();
      shuffled = true;
    }
    return MoveResult(valid: true, steps: steps, shuffled: shuffled);
  }

  List<CascadeStep> _resolve({
    required Set<Pos> swapped,
    required Set<Pos> forced,
  }) {
    final steps = <CascadeStep>[];
    var combo = 0;
    var forcedNow = forced;

    while (true) {
      final groups = _findGroups();
      if (groups.isEmpty && forcedNow.isEmpty) break;

      final toClear = <Pos>{...forcedNow};
      final protected = <Pos>{};
      final created = <CreatedSpecial>[];

      for (final g in groups) {
        toClear.addAll(g.cells);
        final type = g.specialType;
        if (type == Special.none) continue;
        final spot = _creationSpot(g, combo == 0 ? swapped : const {});
        if (spot == null) continue;
        protected.add(spot);
        created.add(CreatedSpecial(spot, tileAt(spot)!, type));
      }

      // 지워질 칸에 있는 특수 블록을 연쇄적으로 발동시킨다.
      final triggered = <TriggeredSpecial>[];
      final queue = toClear.where((p) => tileAt(p)!.isSpecial && !protected.contains(p)).toList();
      final fired = <Pos>{};
      while (queue.isNotEmpty) {
        final p = queue.removeLast();
        if (!fired.add(p)) continue;
        final tile = tileAt(p)!;
        triggered.add(TriggeredSpecial(p, tile.special, tile.color));
        for (final q in _blastArea(p, tile.special)) {
          if (protected.contains(q)) continue;
          if (toClear.add(q) && tileAt(q)!.isSpecial) queue.add(q);
        }
      }

      toClear.removeAll(protected);
      final cleared = [for (final p in toClear) ClearedTile(p, tileAt(p)!)];
      for (final p in toClear) {
        _grid[p.row][p.col] = null;
      }
      for (final c in created) {
        c.tile.special = c.type;
      }

      final hitCount = cleared.length + created.length;
      final damage = (hitCount * baseDamage * comboMultiplier(combo)).round();

      steps.add(
        CascadeStep(
          combo: combo,
          cleared: cleared,
          triggered: triggered,
          created: created,
          falls: _collapseAndRefill(),
          damage: damage,
        ),
      );
      combo++;
      forcedNow = const {};
    }
    return steps;
  }

  /// 특수 블록이 생길 칸: 방금 옮긴 칸 → L·T자 꼭짓점 → 줄의 두 번째 칸 순.
  /// 이미 특수 블록인 칸에는 만들지 않는다.
  Pos? _creationSpot(_Group g, Set<Pos> swapped) {
    bool free(Pos p) => !tileAt(p)!.isSpecial;
    for (final p in swapped) {
      if (g.cells.contains(p) && free(p)) return p;
    }
    for (final p in g.intersections) {
      if (free(p)) return p;
    }
    final longest = g.runs.reduce(
      (a, b) => a.cells.length >= b.cells.length ? a : b,
    );
    for (final p in [...longest.cells.skip(1), longest.cells.first]) {
      if (free(p)) return p;
    }
    for (final p in g.cells) {
      if (free(p)) return p;
    }
    return null;
  }

  Iterable<Pos> _blastArea(Pos p, Special type) sync* {
    switch (type) {
      case Special.laserH:
        for (var c = 0; c < cols; c++) {
          yield Pos(p.row, c);
        }
      case Special.laserV:
        for (var r = 0; r < rows; r++) {
          yield Pos(r, p.col);
        }
      case Special.blackHole:
        for (var r = p.row - 1; r <= p.row + 1; r++) {
          for (var c = p.col - 1; c <= p.col + 1; c++) {
            final q = Pos(r, c);
            if (inBounds(q)) yield q;
          }
        }
      case Special.none:
        break;
    }
  }

  List<_Group> _findGroups() {
    final runs = <_Run>[];
    for (var r = 0; r < rows; r++) {
      var c = 0;
      while (c < cols) {
        final color = _grid[r][c]?.color;
        var end = c + 1;
        while (color != null && end < cols && _grid[r][end]?.color == color) {
          end++;
        }
        if (color != null && end - c >= 3) {
          runs.add(_Run(true, [for (var i = c; i < end; i++) Pos(r, i)]));
        }
        c = end;
      }
    }
    for (var c = 0; c < cols; c++) {
      var r = 0;
      while (r < rows) {
        final color = _grid[r][c]?.color;
        var end = r + 1;
        while (color != null && end < rows && _grid[end][c]?.color == color) {
          end++;
        }
        if (color != null && end - r >= 3) {
          runs.add(_Run(false, [for (var i = r; i < end; i++) Pos(i, c)]));
        }
        r = end;
      }
    }

    // 칸을 공유하는 줄끼리 하나의 그룹으로 묶는다(L·T자 판정).
    final groups = <_Group>[];
    for (final run in runs) {
      final touching = groups.where((g) => run.cells.any(g.cells.contains)).toList();
      final target = touching.isEmpty ? (_Group()..color = tileAt(run.cells.first)!.color) : touching.first;
      if (touching.isEmpty) groups.add(target);
      for (final other in touching.skip(1)) {
        target.cells.addAll(other.cells);
        target.runs.addAll(other.runs);
        groups.remove(other);
      }
      target.cells.addAll(run.cells);
      target.runs.add(run);
    }
    return groups;
  }

  List<Fall> _collapseAndRefill() {
    final falls = <Fall>[];
    for (var c = 0; c < cols; c++) {
      var write = rows - 1;
      for (var r = rows - 1; r >= 0; r--) {
        final t = _grid[r][c];
        if (t == null) continue;
        if (r != write) {
          _grid[write][c] = t;
          _grid[r][c] = null;
          falls.add(Fall(t, c, r, write));
        }
        write--;
      }
      final empty = write + 1;
      for (var r = write; r >= 0; r--) {
        final t = _newTile(_random.nextInt(colorCount));
        _grid[r][c] = t;
        falls.add(Fall(t, c, r - empty, r));
      }
    }
    return falls;
  }

  bool _hasMatchAt(Pos p) {
    final color = tileAt(p)?.color;
    if (color == null) return false;
    int count(int dr, int dc) {
      var n = 0;
      var q = Pos(p.row + dr, p.col + dc);
      while (tileAt(q)?.color == color) {
        n++;
        q = Pos(q.row + dr, q.col + dc);
      }
      return n;
    }

    return count(0, 1) + count(0, -1) >= 2 || count(1, 0) + count(-1, 0) >= 2;
  }

  /// 줄을 만들 수 있는 스왑 하나를 찾는다. 없으면 null.
  (Pos, Pos)? findHint() {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final a = Pos(r, c);
        for (final b in [Pos(r, c + 1), Pos(r + 1, c)]) {
          if (!inBounds(b)) continue;
          if (tileAt(a)!.isSpecial && tileAt(b)!.isSpecial) return (a, b);
          _swapCells(a, b);
          final ok = _hasMatchAt(a) || _hasMatchAt(b);
          _swapCells(a, b);
          if (ok) return (a, b);
        }
      }
    }
    return null;
  }

  /// 블록 위치를 섞어서, 바로 터지는 줄은 없고 움직일 수는 있는 상태로 만든다.
  void shuffle() {
    final all = [for (final (_, t) in tiles) t];
    for (var attempt = 0; attempt < 200; attempt++) {
      all.shuffle(_random);
      var i = 0;
      for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
          _grid[r][c] = all[i++];
        }
      }
      if (_findGroups().isEmpty && findHint() != null) return;
    }
    // 섞기만으로 안 되면(색 분포가 극단적일 때) 새로 채운다.
    fill();
  }
}
