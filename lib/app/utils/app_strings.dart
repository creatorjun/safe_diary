// lib/app/utils/app_strings.dart

class AppStrings {
  AppStrings._();

  // Common
  static const String appName = 'Safe Diary';
  static const String confirm = '확인';
  static const String cancel = '취소';
  static const String error = '오류';
  static const String notification = '알림';
  static const String loading = '로딩 중...';
  static const String save = '저장';
  static const String edit = '수정';
  static const String delete = '삭제';
  static const String add = '추가';
  static const String success = '성공';

  // Login Screen
  static const String naverLogin = '네이버 로그인';
  static const String kakaoLogin = '카카오 로그인';
  static const String logout = '로그아웃';
  static String welcomeMessage(String nickname) => '$nickname님, 환영합니다!';
  static String loginPlatform(String platform) => '로그인 플랫폼: $platform';
  static const String logoutSuccess = '성공적으로 로그아웃되었습니다.';

  // Home Screen & Tabs
  static String homeTitle(String nickname, String tabTitle) =>
      '$nickname님 - $tabTitle';
  static const String more = '더보기';
  static const String profile = '개인정보';
  static const String tabCalendar = '일정';
  static const String tabWeather = '날씨';
  static const String tabLuck = '운세';

  // Calendar View
  static const String addEvent = '일정 추가';
  static const String noEventsOnSelectedDate = '선택된 날짜에 일정이 없습니다.';
  static const String eventNotSynced = '이벤트가 아직 동기화되지 않았습니다.';
  static const String deleteEventConfirmationTitle = '일정 삭제';
  static String deleteEventConfirmationContent(String title) =>
      "'$title' 일정을 삭제하시겠습니까?";

  // Weather View
  static const String selectRegion = "지역 선택";
  static const String weatherInfoError = '날씨 정보를 불러오는 데 실패했습니다.';
  static const String tryAgain = '다시 시도';
  static const String currentTemp = '현재 온도';
  static const String apparentTemp = '체감 온도';
  static const String maxTemp = '최고';
  static const String minTemp = '최저';
  static const String windSpeed = '풍속';
  static const String uvIndex = '자외선';
  static const String humidity = '습도';
  static const String hourlyForecastSummary = "시간별 예보 요약";

  // Luck View
  static const String selectZodiac = "띠 선택";
  static const String luckInfoError = '운세 정보를 불러오는 데 실패했습니다.';
  static const String noLuckInfo = '오늘의 운세 정보가 아직 없습니다.';
  static String zodiacLuckTitle(String zodiac) => '$zodiac 띠별 운세';
  static const String overallLuck = '✨ 총운';
  static const String financialLuck = '💰 재물운';
  static const String loveLuck = '💕 애정운';
  static const String healthLuck = '💪 건강운';
  static const String luckyNumber = '🍀 행운의 숫자';
  static const String luckyColor = '🎨 행운의 색상';
  static const String advice = '💡 조언';

  // Profile & Auth
  static const String profileAuthTitle = '개인정보 접근 인증';
  static const String profileAuthPrompt = '접근 비밀번호 입력';
  static const String profileAuthDescription =
      '개인정보를 보호하기 위해 설정하신 비밀번호를 입력해주세요.';
  static const String password = '비밀번호';
  static const String passwordIncorrect = '비밀번호가 일치하지 않습니다.';
  static const String passwordRequired = '비밀번호를 입력해주세요.';
  static const String securityLogoutWarning =
      '비밀번호를 여러 번 잘못 입력하여 로그아웃됩니다.';
  static const String profileAndSettings = '프로필 및 계정 설정';
  static const String editProfile = '프로필 변경';
  static const String nickname = '닉네임';
  static const String newNicknameHint = '새 닉네임을 입력하세요';
  static const String setAppPassword = '앱 비밀번호 설정';
  static const String changeAppPassword = '앱 비밀번호 변경';
  static const String newPassword = '새 비밀번호';
  static const String newPasswordHint = '새 비밀번호 (4자 이상)';
  static const String newPasswordConfirm = '새 비밀번호 확인';
  static const String newPasswordConfirmHint = '새 비밀번호 다시 입력';
  static const String newPasswordMinLengthError = '새 비밀번호는 4자 이상이어야 합니다.';
  static const String newPasswordMismatchError =
      '새 비밀번호와 확인 비밀번호가 일치하지 않습니다.';
  static const String saveChanges = '변경 내용 저장';
  static const String noChanges = '변경된 내용이 없습니다.';
  static const String saveSuccess = '변경 내용이 성공적으로 저장되었습니다.';
  static const String saveFailed = '변경 내용 저장에 실패했습니다.';
  static const String removeAppPassword = '앱 비밀번호 해제';
  static const String removePasswordPromptTitle = '비밀번호 해제';
  static const String removePasswordPromptContent =
      '비밀번호를 해제하려면 현재 비밀번호를 입력해주세요.';
  static const String currentPassword = '현재 비밀번호';
  static const String currentPasswordRequired = '현재 비밀번호를 입력해주세요.';
  static const String partnerConnection = '파트너 연결';
  static const String unfriendConfirmationTitle = "파트너 연결 끊기";
  static const String unfriendConfirmationContent =
      "파트너와의 연결을 끊고 모든 대화 내역을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.";
  static const String unfriendButton = "연결 끊기";
  static const String accountInfo = '계정 정보';
  static const String accountDeletion = '회원 탈퇴';
  static const String accountDeletionConfirmationTitle = '회원 탈퇴';
  static const String accountDeletionConfirmationContent =
      '회원 탈퇴 즉시 사용자의 모든 정보가 파기되며 복구할 수 없습니다. 정말로 탈퇴하시겠습니까?';
  static const String proceedWithDeletion = '탈퇴 진행';

  // Partner
  static const String alreadyConnectedError = '이미 파트너와 연결되어 있어 초대 코드를 생성할 수 없습니다.';
  static const String createInvitationCodeSuccess = '파트너 초대 코드가 생성되었습니다.';
  static const String createInvitationCodeError = '초대 코드 생성 중 오류가 발생했습니다.';
  static const String invitationCodeRequired = '초대 코드를 입력해주세요.';
  static const String acceptInvitationSuccess = '파트너 초대를 수락했습니다!';
  static String partnerConnectedMessage(String nickname) =>
      "이제부터 '$nickname'님과 연결됩니다.";
  static const String acceptInvitationError = '파트너 초대 수락 중 오류가 발생했습니다.';
  static const String unfriendSuccess = '파트너 관계가 해제되고 대화 내역이 삭제되었습니다.';
  static const String unfriendError = '파트너 관계 해제 중 오류가 발생했습니다.';
  static const String createInvitationCode = '파트너 초대 코드 생성하기';
  static const String enterInvitationCode = '받은 초대 코드 입력';
  static const String acceptInvitation = '초대 수락';
  static const String copyCode = '코드 복사';
  static const String copyCodeSuccess = '초대 코드가 클립보드에 복사되었습니다.';
  static String connectedPartner(String nickname) => '연결된 파트너: $nickname';
  static String partnerSince(String date) => '연결 시작일: $date';
  static String chatWithPartner(String nickname) => '$nickname님과 채팅하기';
  static const String generateNewCode = '새 코드로 다시 생성';

  // Chat
  static String chatRoomTitle(String nickname) => '$nickname님과의 대화';
  static const String refreshMessages = '메시지 새로고침';
  static const String messageLoadError = "메시지를 불러오는 중 오류 발생";
  static const String noMessages = "아직 메시지가 없습니다.\n첫 메시지를 보내보세요!";
  static const String unread = '안 읽음';
  static const String messageInputHint = '메시지를 입력하세요...';
  static const String chatServerError = "채팅 서버에 연결되어 있지 않습니다.";

  // Error Controller & General Errors
  static const String networkError = "네트워크에 연결할 수 없습니다. 인터넷 상태를 확인해주세요.";
  static const String unknownError = "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요.";
}