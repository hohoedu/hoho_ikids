import 'dart:async';

import 'package:get/get.dart';

class RankItem {
  final int rank;
  final String id;
  final String kinderClass;
  final String name;
  final int point;
  final String characterNum;

  RankItem({
    required this.rank,
    required this.id,
    required this.kinderClass,
    required this.name,
    required this.point,
    required this.characterNum,
  });

  factory RankItem.fromJson(Map<String, dynamic> json) => RankItem(
    rank: json['ranking'],
    id: json['id'],
    kinderClass: json['sclassname'] ?? '',
    name: json['name'],
    point: json['total_score'],
    characterNum: json['character_key'],
  );
}

class RankDataController extends GetxController {
  RxList<RankItem> currentList = <RankItem>[].obs;
  RxMap<int, List<RankItem>> rankGroups = <int, List<RankItem>>{}.obs;
  RxList<int> sortedRanks = <int>[].obs;

  RxBool isNotOpenYet = false.obs;
  RxString remainingTime = ''.obs;

  Timer? _timer;
  DateTime? _openDateTime;

  void setCurrentList(List<RankItem> list) {
    isNotOpenYet.value = false;
    _stopTimer();
    currentList.value = list;
    _groupByRank(list);
  }

  void setOpenDate(String? rawDate) {
    isNotOpenYet.value = true;
    currentList.value = [];
    rankGroups.value = {};
    sortedRanks.value = [];

    _openDateTime = _parseOpenDate(rawDate);
    if (_openDateTime == null) {
      remainingTime.value = '집계 준비 중';
      return;
    }
    _updateRemaining();
    _startTimer();
  }

  // rawDate가 null이거나 형식이 다를 경우 null 반환
  DateTime? _parseOpenDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final parts = raw.split('.');
      if (parts.length < 3) return null;
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);
      return DateTime(y, m, d, 9, 0, 0);
    } catch (_) {
      return null;
    }
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining()); // minutes → seconds
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _updateRemaining() {
    if (_openDateTime == null) return;

    final now = DateTime.now();
    final diff = _openDateTime!.difference(now);

    if (diff.isNegative || diff.inSeconds == 0) {
      remainingTime.value = '곧 오픈됩니다';
      _stopTimer();
      return;
    }

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    final parts = <String>[];
    if (days > 0) parts.add('$days일');
    if (hours > 0) parts.add('$hours시간');
    if (minutes > 0) parts.add('$minutes분');

    if (days == 0 && hours == 0 && minutes == 0) {
      parts.add('$seconds초');
    }

    remainingTime.value = '${parts.join(' ')} 후 오픈';
  }

  void _groupByRank(List<RankItem> list) {
    final Map<int, List<RankItem>> groups = {};
    for (final item in list) {
      groups.putIfAbsent(item.rank, () => []).add(item);
    }
    rankGroups.value = groups;
    sortedRanks.value = groups.keys.toList()..sort();
  }

  List<RankItem>? getGroup(int podiumPosition) {
    if (sortedRanks.length < podiumPosition) return null;
    final rank = sortedRanks[podiumPosition - 1];
    return rankGroups[rank];
  }

  RankItem? getRepresentative(int podiumPosition, String myId) {
    final group = getGroup(podiumPosition);
    if (group == null) return null;
    return group.firstWhereOrNull((e) => e.id == myId) ?? group.first;
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }
}