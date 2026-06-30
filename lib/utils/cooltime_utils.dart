class GlobalTicker {
  static final Stream<int> stream = Stream.periodic(
    const Duration(seconds: 1),
        (count) => count,
  ).asBroadcastStream();
}