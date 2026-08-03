class GlobalTicker {
  static final Stream<int> stream = Stream.periodic(
    const Duration(seconds: 1),
        (count) => count,
  ).asBroadcastStream();
}

// 트래픽 부담이 큰 영상 시청 콘텐츠 - 쿨타임 중에는 아예 진입을 막음
const Set<String> videoBlockedCooltimeTypes = {'song', 'story', 'han', 'insung'};