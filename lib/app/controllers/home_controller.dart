// lib/app/controllers/home_controller.dart

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_diary/app/services/dialog_service.dart';
import 'package:safe_diary/app/services/holiday_service.dart';
import 'package:safe_diary/app/utils/app_strings.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/login_controller.dart';
import '../models/event_item.dart';
import '../routes/app_pages.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';
import '../views/widgets/add_edit_event_sheet.dart';
import 'error_controller.dart';

class HomeController extends GetxController {
  final LoginController _loginController;
  final EventService _eventService;
  final DialogService _dialogService;
  final HolidayService _holidayService;

  HomeController(
      this._loginController,
      this._eventService,
      this._dialogService,
      this._holidayService,
      );

  ErrorController get _errorController => Get.find<ErrorController>();

  final RxInt selectedIndex = 0.obs;
  final List<String> tabTitles = [
    AppStrings.tabCalendar,
    AppStrings.tabWeather,
    AppStrings.tabLuck,
  ];

  String get currentTitle => tabTitles[selectedIndex.value];

  // 신규 사용자에게 비밀번호 설정 안내 팝업이 표시되었는지 확인하는 플래그
  final RxBool _passwordSetupWarningShown = false.obs;

  final RxBool isLoadingEvents = false.obs;
  final RxBool isSubmittingEvent = false.obs;

  late final Rx<DateTime> focusedDay;
  late final Rx<DateTime?> selectedDay;

  final RxMap<DateTime, List<EventItem>> events =
  RxMap<DateTime, List<EventItem>>(
    LinkedHashMap<DateTime, List<EventItem>>(
      equals: isSameDay,
      hashCode: (key) => key.year * 1000000 + key.month * 10000 + key.day,
    ),
  );

  final RxMap<DateTime, String> holidays = RxMap<DateTime, String>();

  List<EventItem> get selectedDayEvents {
    final day = selectedDay.value;
    if (day == null) return <EventItem>[];
    final eventsForDay = events[day] ?? <EventItem>[];
    eventsForDay.sort((a, b) {
      final orderA = a.displayOrder ?? 999;
      final orderB = b.displayOrder ?? 999;
      return orderA.compareTo(orderB);
    });
    return eventsForDay;
  }

  String? get selectedDayHolidayName {
    if (selectedDay.value == null) return null;
    return holidays[selectedDay.value];
  }

  DateTime _normalizeDate(DateTime dateTime) {
    return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
  }

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    final normalizedNow = _normalizeDate(now);
    focusedDay = normalizedNow.obs;
    selectedDay = normalizedNow.obs;

    _loadEventsFromServer();
    _loadHolidaysForYear(now.year);
  }

  @override
  void onReady() {
    super.onReady();
    // 홈 화면이 준비되면, 신규 사용자에게 비밀번호 설정을 안내합니다.
    _showPasswordSetupWarningIfNeeded();
  }

  /// 신규 사용자이고, 아직 앱 비밀번호를 설정하지 않았으며,
  /// 안내 팝업이 표시된 적이 없다면 팝업을 표시합니다.
  void _showPasswordSetupWarningIfNeeded() {
    // isNew 플래그는 서버에서 로그인 시 한 번만 true로 내려옵니다.
    // 사용자가 한 번이라도 로그인하면 다음부터는 false가 됩니다.
    if (_loginController.user.isNew &&
        !_loginController.user.isAppPasswordSet &&
        !_passwordSetupWarningShown.value) {

      // 화면이 완전히 그려진 후에 BottomSheet를 보여주기 위해 짧은 지연을 줍니다.
      Future.delayed(const Duration(milliseconds: 500), () {
        // BottomSheet가 표시되는 동안 사용자가 다른 화면으로 이동했을 경우를 대비해
        // 현재 화면이 HomeController인지 다시 한 번 확인합니다.
        if (Get.isRegistered<HomeController>() && Get.context != null) {
          _showPasswordSetupBottomSheet();
          _passwordSetupWarningShown.value = true; // 팝업이 다시 뜨지 않도록 플래그 설정
        }
      });
    }
  }

  void _showPasswordSetupBottomSheet() {
    final BuildContext context = Get.context!;
    final ThemeData theme = Theme.of(context);
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    _dialogService.showCustomBottomSheet(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Wrap(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '🔒 ${AppStrings.profileAndSettings}',
                  style: textStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.medium),
                Text(
                  "소중한 정보를 안전하게 보호하기 위해\n앱 비밀번호를 설정하는 것을 권장해요.",
                  style: textStyles.bodyMedium.copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.large),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: theme.colorScheme.outline.withAlpha(128)),
                        ),
                        onPressed: () => Get.back(),
                        child: Text('나중에 할게요', style: textStyles.bodyMedium),
                      ),
                    ),
                    SizedBox(width: spacing.small),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          Get.back(); // BottomSheet 닫기
                          Get.toNamed(Routes.profileAuth); // 프로필 인증 화면으로 이동
                        },
                        child: Text(
                          '지금 설정하기',
                          style: textStyles.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }


  void onDaySelected(DateTime newSelectedDay, DateTime newFocusedDay) {
    final normalizedNewSelectedDay = _normalizeDate(newSelectedDay);
    if (selectedDay.value == null ||
        !isSameDay(selectedDay.value!, normalizedNewSelectedDay)) {
      selectedDay.value = normalizedNewSelectedDay;
    }
    focusedDay.value = _normalizeDate(newFocusedDay);
  }

  void onPageChanged(DateTime newFocusedDay) {
    final normalizedDay = _normalizeDate(newFocusedDay);
    if (focusedDay.value.year != normalizedDay.year) {
      _loadHolidaysForYear(normalizedDay.year);
    }
    focusedDay.value = normalizedDay;
  }

  List<EventItem> getEventsForDay(DateTime day) {
    final normalizedDay = _normalizeDate(day);
    final eventsForDay = events[normalizedDay] ?? <EventItem>[];
    eventsForDay.sort((a, b) {
      final orderA = a.displayOrder ?? 999;
      final orderB = b.displayOrder ?? 999;
      return orderA.compareTo(orderB);
    });
    return eventsForDay;
  }

  Future<void> _loadHolidaysForYear(int year) async {
    try {
      final holidayList = await _holidayService.getHolidays(year);
      for (final holiday in holidayList) {
        holidays[_normalizeDate(holiday.date)] = holiday.name;
      }
      holidays.refresh();
    } catch (e) {
      _errorController.handleError(
        e,
        userFriendlyMessage: '공휴일 정보를 불러오는 데 실패했습니다.',
      );
    }
  }

  Future<void> _loadEventsFromServer() async {
    isLoadingEvents.value = true;
    try {
      final List<EventItem> serverEvents = await _eventService.getEvents();
      final newEventsMap = LinkedHashMap<DateTime, List<EventItem>>(
        equals: isSameDay,
        hashCode: (key) => key.year * 1000000 + key.month * 10000 + key.day,
      );

      for (var event in serverEvents) {
        final normalizedEventDate = _normalizeDate(event.eventDate);
        final list = newEventsMap.putIfAbsent(normalizedEventDate, () => []);
        list.add(event);
      }
      events.clear();
      events.addAll(newEventsMap);
      events.refresh();
    } catch (e) {
      _errorController.handleError(
        e,
        userFriendlyMessage: '이벤트 목록을 불러오는 데 실패했습니다.',
      );
    } finally {
      isLoadingEvents.value = false;
    }
  }

  void showAddEventDialog() {
    if (selectedDay.value == null) {
      _dialogService.showSnackbar(AppStrings.notification, "먼저 날짜를 선택해주세요.");
      return;
    }
    _dialogService.showCustomBottomSheet(
      child: AddEditEventSheet(
        eventDate: selectedDay.value!,
        onSubmit: (event) {
          _createEventOnServer(event);
        },
      ),
    );
  }

  Future<void> _createEventOnServer(EventItem event) async {
    isSubmittingEvent.value = true;
    try {
      final normalizedDate = _normalizeDate(event.eventDate);
      final newOrder = events[normalizedDate]?.length ?? 0;

      final eventWithOrder = event.copyWith(displayOrder: newOrder);

      final createdEvent = await _eventService.createEvent(eventWithOrder);

      final list = events.putIfAbsent(normalizedDate, () => []);
      list.add(createdEvent);
      events.refresh();
    } catch (e) {
      _errorController.handleError(e, userFriendlyMessage: '일정 추가에 실패했습니다.');
    } finally {
      isSubmittingEvent.value = false;
    }
  }

  void showEditEventDialog(EventItem existingEvent) {
    _dialogService.showCustomBottomSheet(
      child: AddEditEventSheet(
        eventDate: existingEvent.eventDate,
        existingEvent: existingEvent,
        onSubmit: (event) {
          _updateEventOnServer(event);
        },
      ),
    );
  }

  Future<void> _updateEventOnServer(EventItem eventToUpdate) async {
    if (eventToUpdate.backendEventId == null) {
      return;
    }
    isSubmittingEvent.value = true;
    try {
      final updatedEventFromServer = await _eventService.updateEvent(
        eventToUpdate,
      );

      final originalNormalizedDate = _normalizeDate(eventToUpdate.eventDate);
      if (events[originalNormalizedDate] != null) {
        events[originalNormalizedDate]!.removeWhere(
              (e) => e.backendEventId == updatedEventFromServer.backendEventId,
        );
        if (events[originalNormalizedDate]!.isEmpty) {
          events.remove(originalNormalizedDate);
        }
      }

      final updatedNormalizedDate = _normalizeDate(
        updatedEventFromServer.eventDate,
      );
      final list = events.putIfAbsent(updatedNormalizedDate, () => []);
      list.add(updatedEventFromServer);

      events.refresh();
    } catch (e) {
      _errorController.handleError(e, userFriendlyMessage: '일정 수정에 실패했습니다.');
    } finally {
      isSubmittingEvent.value = false;
    }
  }

  void confirmDeleteEvent(EventItem eventToDelete) {
    if (eventToDelete.backendEventId == null) {
      return;
    }
    _dialogService.showConfirmDialog(
      title: AppStrings.deleteEventConfirmationTitle,
      content: AppStrings.deleteEventConfirmationContent(eventToDelete.title),
      confirmText: AppStrings.delete,
      onConfirm: () => _deleteEventOnServer(eventToDelete),
    );
  }

  Future<void> _deleteEventOnServer(EventItem eventToDelete) async {
    if (eventToDelete.backendEventId == null) return;

    isSubmittingEvent.value = true;
    try {
      await _eventService.deleteEvent(eventToDelete.backendEventId!);

      final normalizedEventDate = _normalizeDate(eventToDelete.eventDate);
      if (events[normalizedEventDate] != null) {
        events[normalizedEventDate]!.removeWhere(
              (e) => e.backendEventId == eventToDelete.backendEventId,
        );
        if (events[normalizedEventDate]!.isEmpty) {
          events.remove(normalizedEventDate);
        }
        events.refresh();
      }
    } catch (e) {
      _errorController.handleError(e, userFriendlyMessage: '일정 삭제에 실패했습니다.');
    } finally {
      isSubmittingEvent.value = false;
    }
  }

  void changeTabIndex(int index) {
    if (index >= 0 && index < tabTitles.length) {
      selectedIndex.value = index;
    }
  }
}