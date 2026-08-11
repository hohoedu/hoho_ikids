// 빌드타임에 .env 값을 난독화하여 코드로 생성합니다.
// 값 변경 후에는 반드시 다음을 실행하세요:
//   dart run build_runner build --delete-conflicting-outputs
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
final class Env {
  @EnviedField(varName: 'BOOKI_EBOOK_CONTENT_LIST_URL')
  static final String bookiEbookContentListUrl = _Env.bookiEbookContentListUrl;
  @EnviedField(varName: 'BOOKI_EBOOK_LIST_URL')
  static final String bookiEbookListUrl = _Env.bookiEbookListUrl;
  @EnviedField(varName: 'BOOKI_FIND_DIFF_URL')
  static final String bookiFindDiffUrl = _Env.bookiFindDiffUrl;
  @EnviedField(varName: 'BOOKI_GOLDENBELL_URL')
  static final String bookiGoldenbellUrl = _Env.bookiGoldenbellUrl;
  @EnviedField(varName: 'BOOKI_MATCH_URL')
  static final String bookiMatchUrl = _Env.bookiMatchUrl;
  @EnviedField(varName: 'BOOKI_REPORT_HIGHFIVE_URL')
  static final String bookiReportHighfiveUrl = _Env.bookiReportHighfiveUrl;
  @EnviedField(varName: 'BOOKI_REPORT_HOME_URL')
  static final String bookiReportHomeUrl = _Env.bookiReportHomeUrl;
  @EnviedField(varName: 'BOOKI_REPORT_LEARNING_URL')
  static final String bookiReportLearningUrl = _Env.bookiReportLearningUrl;
  @EnviedField(varName: 'BOOKI_REPORT_TENACITY_URL')
  static final String bookiReportTenacityUrl = _Env.bookiReportTenacityUrl;
  @EnviedField(varName: 'BOOKI_SONG_URL')
  static final String bookiSongUrl = _Env.bookiSongUrl;
  @EnviedField(varName: 'BOOKI_STORY_URL')
  static final String bookiStoryUrl = _Env.bookiStoryUrl;
  @EnviedField(varName: 'BOOKI_STROKE_URL')
  static final String bookiStrokeUrl = _Env.bookiStrokeUrl;
  @EnviedField(varName: 'B_CONTENT_STAR_URL')
  static final String bContentStarUrl = _Env.bContentStarUrl;
  @EnviedField(varName: 'CHARACTER_LIST_URL')
  static final String characterListUrl = _Env.characterListUrl;
  @EnviedField(varName: 'CHARACTER_SELECT_URL')
  static final String characterSelectUrl = _Env.characterSelectUrl;
  @EnviedField(varName: 'CONTENT_STAR_URL')
  static final String contentStarUrl = _Env.contentStarUrl;
  @EnviedField(varName: 'DUPE_URL')
  static final String dupeUrl = _Env.dupeUrl;
  @EnviedField(varName: 'EBOOK_USE_URL')
  static final String ebookUseUrl = _Env.ebookUseUrl;
  @EnviedField(varName: 'FCM_TOKEN_URL')
  static final String fcmTokenUrl = _Env.fcmTokenUrl;
  @EnviedField(varName: 'FIND_STAR_SAVE_URL')
  static final String findStarSaveUrl = _Env.findStarSaveUrl;
  @EnviedField(varName: 'FIND_STAR_STATE_URL')
  static final String findStarStateUrl = _Env.findStarStateUrl;
  @EnviedField(varName: 'HANI_EBOOK_CONTENT_LIST_URL')
  static final String haniEbookContentListUrl = _Env.haniEbookContentListUrl;
  @EnviedField(varName: 'HANI_EBOOK_LIST_URL')
  static final String haniEbookListUrl = _Env.haniEbookListUrl;
  @EnviedField(varName: 'HANI_ERASE_URL')
  static final String haniEraseUrl = _Env.haniEraseUrl;
  @EnviedField(varName: 'HANI_FLIP_URL')
  static final String haniFlipUrl = _Env.haniFlipUrl;
  @EnviedField(varName: 'HANI_GOLDENBELL_G5_URL')
  static final String haniGoldenbellG5Url = _Env.haniGoldenbellG5Url;
  @EnviedField(varName: 'HANI_GOLDENBELL_URL')
  static final String haniGoldenbellUrl = _Env.haniGoldenbellUrl;
  @EnviedField(varName: 'HANI_HANJA_SONG_URL')
  static final String haniHanjaSongUrl = _Env.haniHanjaSongUrl;
  @EnviedField(varName: 'HANI_INSUNG_URL')
  static final String haniInsungUrl = _Env.haniInsungUrl;
  @EnviedField(varName: 'HANI_INSUNG_Y5_URL')
  static final String haniInsungY5Url = _Env.haniInsungY5Url;
  @EnviedField(varName: 'HANI_MAKE_CARD_URL')
  static final String haniMakeCardUrl = _Env.haniMakeCardUrl;
  @EnviedField(varName: 'HANI_PUZZLE_URL')
  static final String haniPuzzleUrl = _Env.haniPuzzleUrl;
  @EnviedField(varName: 'HANI_PUZZLE_Y5_URL')
  static final String haniPuzzleY5Url = _Env.haniPuzzleY5Url;
  @EnviedField(varName: 'HANI_QUIZ_G5_URL')
  static final String haniQuizG5Url = _Env.haniQuizG5Url;
  @EnviedField(varName: 'HANI_QUIZ_Y5_URL')
  static final String haniQuizY5Url = _Env.haniQuizY5Url;
  @EnviedField(varName: 'HANI_REPORT_HIGHFIVE_URL')
  static final String haniReportHighfiveUrl = _Env.haniReportHighfiveUrl;
  @EnviedField(varName: 'HANI_REPORT_HOME_URL')
  static final String haniReportHomeUrl = _Env.haniReportHomeUrl;
  @EnviedField(varName: 'HANI_REPORT_LEARNING_URL')
  static final String haniReportLearningUrl = _Env.haniReportLearningUrl;
  @EnviedField(varName: 'HANI_REPORT_TENACITY_URL')
  static final String haniReportTenacityUrl = _Env.haniReportTenacityUrl;
  @EnviedField(varName: 'HANI_ROTATE_URL')
  static final String haniRotateUrl = _Env.haniRotateUrl;
  @EnviedField(varName: 'HANI_SONG_G5_URL')
  static final String haniSongG5Url = _Env.haniSongG5Url;
  @EnviedField(varName: 'HANI_SONG_LIST_G_URL')
  static final String haniSongListGUrl = _Env.haniSongListGUrl;
  @EnviedField(varName: 'HANI_SONG_LIST_Y_URL')
  static final String haniSongListYUrl = _Env.haniSongListYUrl;
  @EnviedField(varName: 'HANI_SONG_URL')
  static final String haniSongUrl = _Env.haniSongUrl;
  @EnviedField(varName: 'HANI_SONG_Y5_URL')
  static final String haniSongY5Url = _Env.haniSongY5Url;
  @EnviedField(varName: 'HANI_STORY_G5_URL')
  static final String haniStoryG5Url = _Env.haniStoryG5Url;
  @EnviedField(varName: 'HANI_STORY_URL')
  static final String haniStoryUrl = _Env.haniStoryUrl;
  @EnviedField(varName: 'HANI_STROKE_URL')
  static final String haniStrokeUrl = _Env.haniStrokeUrl;
  @EnviedField(varName: 'H_CONTENT_STAR_URL')
  static final String hContentStarUrl = _Env.hContentStarUrl;
  @EnviedField(varName: 'ID_SEARCH_URL')
  static final String idSearchUrl = _Env.idSearchUrl;
  @EnviedField(varName: 'INSERT_2026_URL')
  static final String insert2026Url = _Env.insert2026Url;
  @EnviedField(varName: 'INSERT_CHILD_URL')
  static final String insertChildUrl = _Env.insertChildUrl;
  @EnviedField(varName: 'INSERT_PNAME_URL')
  static final String insertPnameUrl = _Env.insertPnameUrl;
  @EnviedField(varName: 'JOIN_CODE_URL')
  static final String joinCodeUrl = _Env.joinCodeUrl;
  @EnviedField(varName: 'JOIN_URL')
  static final String joinUrl = _Env.joinUrl;
  @EnviedField(varName: 'KEYCODE_URL')
  static final String keycodeUrl = _Env.keycodeUrl;
  @EnviedField(varName: 'KIDOK_BOOKCASE_URL')
  static final String kidokBookcaseUrl = _Env.kidokBookcaseUrl;
  @EnviedField(varName: 'KIDOK_GRAPH_URL')
  static final String kidokGraphUrl = _Env.kidokGraphUrl;
  @EnviedField(varName: 'KIDOK_MAIN_THEME_URL')
  static final String kidokMainThemeUrl = _Env.kidokMainThemeUrl;
  @EnviedField(varName: 'KIDOK_MAIN_URL')
  static final String kidokMainUrl = _Env.kidokMainUrl;
  @EnviedField(varName: 'KIDOK_QUESTION_URL')
  static final String kidokQuestionUrl = _Env.kidokQuestionUrl;
  @EnviedField(varName: 'KIDOK_SAVE_URL')
  static final String kidokSaveUrl = _Env.kidokSaveUrl;
  @EnviedField(varName: 'KIDOK_SUBLIST_URL')
  static final String kidokSublistUrl = _Env.kidokSublistUrl;
  @EnviedField(varName: 'LEGACY_USER_URL')
  static final String legacyUserUrl = _Env.legacyUserUrl;
  @EnviedField(varName: 'LOGIN_2026_URL')
  static final String login2026Url = _Env.login2026Url;
  @EnviedField(varName: 'LOGIN_URL')
  static final String loginUrl = _Env.loginUrl;
  @EnviedField(varName: 'MISSION_CLEAR_URL')
  static final String missionClearUrl = _Env.missionClearUrl;
  @EnviedField(varName: 'MISSION_LIST_URL')
  static final String missionListUrl = _Env.missionListUrl;
  @EnviedField(varName: 'MISSION_SAVE_URL')
  static final String missionSaveUrl = _Env.missionSaveUrl;
  @EnviedField(varName: 'M_BOOKI_EBOOK_LIST_URL')
  static final String mBookiEbookListUrl = _Env.mBookiEbookListUrl;
  @EnviedField(varName: 'M_BOOKI_REPORT_HIGHFIVE_URL')
  static final String mBookiReportHighfiveUrl = _Env.mBookiReportHighfiveUrl;
  @EnviedField(varName: 'M_BOOKI_REPORT_HOME_URL')
  static final String mBookiReportHomeUrl = _Env.mBookiReportHomeUrl;
  @EnviedField(varName: 'M_BOOKI_REPORT_LEARNING_URL')
  static final String mBookiReportLearningUrl = _Env.mBookiReportLearningUrl;
  @EnviedField(varName: 'M_BOOKI_REPORT_TENACITY_URL')
  static final String mBookiReportTenacityUrl = _Env.mBookiReportTenacityUrl;
  @EnviedField(varName: 'M_EBOOK_USE_URL')
  static final String mEbookUseUrl = _Env.mEbookUseUrl;
  @EnviedField(varName: 'M_HANI_EBOOK_LIST_URL')
  static final String mHaniEbookListUrl = _Env.mHaniEbookListUrl;
  @EnviedField(varName: 'M_HANI_REPORT_HIGHFIVE_URL')
  static final String mHaniReportHighfiveUrl = _Env.mHaniReportHighfiveUrl;
  @EnviedField(varName: 'M_HANI_REPORT_HOME_URL')
  static final String mHaniReportHomeUrl = _Env.mHaniReportHomeUrl;
  @EnviedField(varName: 'M_HANI_REPORT_LEARNING_URL')
  static final String mHaniReportLearningUrl = _Env.mHaniReportLearningUrl;
  @EnviedField(varName: 'M_HANI_REPORT_TENACITY_URL')
  static final String mHaniReportTenacityUrl = _Env.mHaniReportTenacityUrl;
  @EnviedField(varName: 'NOTICE_LIST_URL')
  static final String noticeListUrl = _Env.noticeListUrl;
  @EnviedField(varName: 'NOTICE_OTHER_URL')
  static final String noticeOtherUrl = _Env.noticeOtherUrl;
  @EnviedField(varName: 'NOTICE_VIEW_URL')
  static final String noticeViewUrl = _Env.noticeViewUrl;
  @EnviedField(varName: 'PASSWORD_SEARCH_URL')
  static final String passwordSearchUrl = _Env.passwordSearchUrl;
  @EnviedField(varName: 'PASSWORD_UPDATE_URL')
  static final String passwordUpdateUrl = _Env.passwordUpdateUrl;
  @EnviedField(varName: 'RANK_URL')
  static final String rankUrl = _Env.rankUrl;
  @EnviedField(varName: 'RECORD_LIST_URL')
  static final String recordListUrl = _Env.recordListUrl;
  @EnviedField(varName: 'REPORT_READ_URL')
  static final String reportReadUrl = _Env.reportReadUrl;
  @EnviedField(varName: 'REPORT_SEND_URL')
  static final String reportSendUrl = _Env.reportSendUrl;
  @EnviedField(varName: 'SIBLING_URL')
  static final String siblingUrl = _Env.siblingUrl;
  @EnviedField(varName: 'STAR_UPDATE_URL')
  static final String starUpdateUrl = _Env.starUpdateUrl;
  @EnviedField(varName: 'TOTAL_STAR_URL')
  static final String totalStarUrl = _Env.totalStarUrl;
  @EnviedField(varName: 'USER_CODE_DEL_URL')
  static final String userCodeDelUrl = _Env.userCodeDelUrl;
  @EnviedField(varName: 'USER_CODE_URL')
  static final String userCodeUrl = _Env.userCodeUrl;
  @EnviedField(varName: 'USER_COUNT_URL')
  static final String userCountUrl = _Env.userCountUrl;
  @EnviedField(varName: 'VERSION_URL')
  static final String versionUrl = _Env.versionUrl;
  @EnviedField(varName: 'VIMEO_TOKEN')
  static final String vimeoToken = _Env.vimeoToken;
  @EnviedField(varName: 'WITHDRAW_URL')
  static final String withdrawUrl = _Env.withdrawUrl;

  // 기존 조회 방식(문자열 키)과의 호환을 위한 조회 헬퍼
  static final Map<String, String> _map = {
    'BOOKI_EBOOK_CONTENT_LIST_URL': bookiEbookContentListUrl,
    'BOOKI_EBOOK_LIST_URL': bookiEbookListUrl,
    'BOOKI_FIND_DIFF_URL': bookiFindDiffUrl,
    'BOOKI_GOLDENBELL_URL': bookiGoldenbellUrl,
    'BOOKI_MATCH_URL': bookiMatchUrl,
    'BOOKI_REPORT_HIGHFIVE_URL': bookiReportHighfiveUrl,
    'BOOKI_REPORT_HOME_URL': bookiReportHomeUrl,
    'BOOKI_REPORT_LEARNING_URL': bookiReportLearningUrl,
    'BOOKI_REPORT_TENACITY_URL': bookiReportTenacityUrl,
    'BOOKI_SONG_URL': bookiSongUrl,
    'BOOKI_STORY_URL': bookiStoryUrl,
    'BOOKI_STROKE_URL': bookiStrokeUrl,
    'B_CONTENT_STAR_URL': bContentStarUrl,
    'CHARACTER_LIST_URL': characterListUrl,
    'CHARACTER_SELECT_URL': characterSelectUrl,
    'CONTENT_STAR_URL': contentStarUrl,
    'DUPE_URL': dupeUrl,
    'EBOOK_USE_URL': ebookUseUrl,
    'FCM_TOKEN_URL': fcmTokenUrl,
    'FIND_STAR_SAVE_URL': findStarSaveUrl,
    'FIND_STAR_STATE_URL': findStarStateUrl,
    'HANI_EBOOK_CONTENT_LIST_URL': haniEbookContentListUrl,
    'HANI_EBOOK_LIST_URL': haniEbookListUrl,
    'HANI_ERASE_URL': haniEraseUrl,
    'HANI_FLIP_URL': haniFlipUrl,
    'HANI_GOLDENBELL_G5_URL': haniGoldenbellG5Url,
    'HANI_GOLDENBELL_URL': haniGoldenbellUrl,
    'HANI_HANJA_SONG_URL': haniHanjaSongUrl,
    'HANI_INSUNG_URL': haniInsungUrl,
    'HANI_INSUNG_Y5_URL': haniInsungY5Url,
    'HANI_MAKE_CARD_URL': haniMakeCardUrl,
    'HANI_PUZZLE_URL': haniPuzzleUrl,
    'HANI_PUZZLE_Y5_URL': haniPuzzleY5Url,
    'HANI_QUIZ_G5_URL': haniQuizG5Url,
    'HANI_QUIZ_Y5_URL': haniQuizY5Url,
    'HANI_REPORT_HIGHFIVE_URL': haniReportHighfiveUrl,
    'HANI_REPORT_HOME_URL': haniReportHomeUrl,
    'HANI_REPORT_LEARNING_URL': haniReportLearningUrl,
    'HANI_REPORT_TENACITY_URL': haniReportTenacityUrl,
    'HANI_ROTATE_URL': haniRotateUrl,
    'HANI_SONG_G5_URL': haniSongG5Url,
    'HANI_SONG_LIST_G_URL': haniSongListGUrl,
    'HANI_SONG_LIST_Y_URL': haniSongListYUrl,
    'HANI_SONG_URL': haniSongUrl,
    'HANI_SONG_Y5_URL': haniSongY5Url,
    'HANI_STORY_G5_URL': haniStoryG5Url,
    'HANI_STORY_URL': haniStoryUrl,
    'HANI_STROKE_URL': haniStrokeUrl,
    'H_CONTENT_STAR_URL': hContentStarUrl,
    'ID_SEARCH_URL': idSearchUrl,
    'INSERT_2026_URL': insert2026Url,
    'INSERT_CHILD_URL': insertChildUrl,
    'INSERT_PNAME_URL': insertPnameUrl,
    'JOIN_CODE_URL': joinCodeUrl,
    'JOIN_URL': joinUrl,
    'KEYCODE_URL': keycodeUrl,
    'KIDOK_BOOKCASE_URL': kidokBookcaseUrl,
    'KIDOK_GRAPH_URL': kidokGraphUrl,
    'KIDOK_MAIN_THEME_URL': kidokMainThemeUrl,
    'KIDOK_MAIN_URL': kidokMainUrl,
    'KIDOK_QUESTION_URL': kidokQuestionUrl,
    'KIDOK_SAVE_URL': kidokSaveUrl,
    'KIDOK_SUBLIST_URL': kidokSublistUrl,
    'LEGACY_USER_URL': legacyUserUrl,
    'LOGIN_2026_URL': login2026Url,
    'LOGIN_URL': loginUrl,
    'MISSION_CLEAR_URL': missionClearUrl,
    'MISSION_LIST_URL': missionListUrl,
    'MISSION_SAVE_URL': missionSaveUrl,
    'M_BOOKI_EBOOK_LIST_URL': mBookiEbookListUrl,
    'M_BOOKI_REPORT_HIGHFIVE_URL': mBookiReportHighfiveUrl,
    'M_BOOKI_REPORT_HOME_URL': mBookiReportHomeUrl,
    'M_BOOKI_REPORT_LEARNING_URL': mBookiReportLearningUrl,
    'M_BOOKI_REPORT_TENACITY_URL': mBookiReportTenacityUrl,
    'M_EBOOK_USE_URL': mEbookUseUrl,
    'M_HANI_EBOOK_LIST_URL': mHaniEbookListUrl,
    'M_HANI_REPORT_HIGHFIVE_URL': mHaniReportHighfiveUrl,
    'M_HANI_REPORT_HOME_URL': mHaniReportHomeUrl,
    'M_HANI_REPORT_LEARNING_URL': mHaniReportLearningUrl,
    'M_HANI_REPORT_TENACITY_URL': mHaniReportTenacityUrl,
    'NOTICE_LIST_URL': noticeListUrl,
    'NOTICE_OTHER_URL': noticeOtherUrl,
    'NOTICE_VIEW_URL': noticeViewUrl,
    'PASSWORD_SEARCH_URL': passwordSearchUrl,
    'PASSWORD_UPDATE_URL': passwordUpdateUrl,
    'RANK_URL': rankUrl,
    'RECORD_LIST_URL': recordListUrl,
    'REPORT_READ_URL': reportReadUrl,
    'REPORT_SEND_URL': reportSendUrl,
    'SIBLING_URL': siblingUrl,
    'STAR_UPDATE_URL': starUpdateUrl,
    'TOTAL_STAR_URL': totalStarUrl,
    'USER_CODE_DEL_URL': userCodeDelUrl,
    'USER_CODE_URL': userCodeUrl,
    'USER_COUNT_URL': userCountUrl,
    'VERSION_URL': versionUrl,
    'VIMEO_TOKEN': vimeoToken,
    'WITHDRAW_URL': withdrawUrl,
  };

  static String get(String key) {
    final value = _map[key];
    if (value == null) {
      throw ArgumentError('환경변수를 찾을 수 없습니다: $key');
    }
    return value;
  }
}
