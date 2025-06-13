import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/login_controller.dart';
import '../models/event_item.dart';
import '../routes/app_pages.dart';
import '../services/event_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../views/widgets/add_edit_event_dialog.dart';
import 'error_controller.dart';

class HomeController extends GetxController {
  final LoginController _loginController;
  final EventService _eventService;

  HomeController(this._loginController, this._eventService);

  ErrorController get _errorController => Get.find<ErrorController>();

  final RxInt selectedIndex = 0.obs;
  final List<String> tabTitles = ['일정', '날씨', '운세'];

  String get currentTitle => tabTitles[selectedIndex.value];

  final RxBool _newUserWarningShown = false.obs;

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
  }

  @override
  void onReady() {
    super.onReady();
    _checkAndShowNewUserWarning();
  }

  void _checkAndShowNewUserWarning() {
    if (_loginController.user.isNew &&
        !_loginController.user.isAppPasswordSet &&
        !_newUserWarningShown.value) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.isRegistered<HomeController>() && Get.context != null) {
          _showNewUserPasswordSetupWarning();
          _newUserWarningShown.value = true;
        }
      });
    }
  }

  void _showNewUserPasswordSetupWarning() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              spreadRadius: 0,
              blurRadius: 10,
            ),
          ],
        ),
        child: Wrap(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '🔒 개인 정보 보호 알림',
                  style: textStyleLarge,
                  textAlign: TextAlign.center,
                ),
                verticalSpaceMedium,
                Text(
                  "개인정보 - 비밀번호 설정을 활성화 해주세요.",
                  style: textStyleMedium.copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
                verticalSpaceLarge,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('나중에 하기', style: textStyleSmall),
                      ),
                    ),
                    horizontalSpaceSmall,
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Theme.of(Get.context!).primaryColor,
                        ),
                        onPressed: () {
                          Get.back();
                          Get.toNamed(Routes.profileAuth);
                        },
                        child: Text(
                          '지금 설정',
                          style: textStyleSmall.copyWith(color: Colors.white),
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
    focusedDay.value = _normalizeDate(newFocusedDay);
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
      Get.snackbar("알림", "먼저 날짜를 선택해주세요.");
      return;
    }
    Get.bottomSheet(
      AddEditEventDialog(
        eventDate: selectedDay.value!,
        onSubmit: (event) {
          _createEventOnServer(event);
        },
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
    Get.bottomSheet(
      AddEditEventDialog(
        eventDate: existingEvent.eventDate,
        existingEvent: existingEvent,
        onSubmit: (event) {
          _updateEventOnServer(event);
        },
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
    Get.dialog(
      AlertDialog(
        title: const Text("일정 삭제"),
        content: Text("'${eventToDelete.title}' 일정을 삭제하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("취소")),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteEventOnServer(eventToDelete);
            },
            child: const Text("삭제", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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