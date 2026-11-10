const _characterNameMap = {
  'H': 'hani',
  'B': 'booki',
  'T': 'tiger',
  'R': 'rabbit',
  'U': 'bear',
  'S': 'squirrel',
};

/// character_key(H1/B1/T1/R1/U1/S1 등) → lottie 에셋 경로 매핑
String characterLottieAsset(String characterKey) {
  if (characterKey.isEmpty) return '';
  final name = _characterNameMap[characterKey[0].toUpperCase()];
  return name == null ? '' : 'assets/lottie/$name.json';
}

/// 랭킹 단상용 캐릭터 lottie 에셋 경로 매핑
/// rank: 'first' / 'second' / 'third', characterKey: H1/B1 등
String characterRankLottieAsset(String rank, String characterKey) {
  if (characterKey.isEmpty) return '';
  final name = _characterNameMap[characterKey[0].toUpperCase()];
  return name == null ? '' : 'assets/lottie/${rank}_$name.json';
}
