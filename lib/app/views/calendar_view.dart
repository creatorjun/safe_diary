import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/home_controller.dart';
import '../models/event_item.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  Widget _buildEventMarker(
    BuildContext context,
    DateTime day,
    EventItem event,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      width: 7,
      height: 7,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildEventsCountMarker(
    BuildContext context,
    DateTime day,
    int count,
  ) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColor.withAlpha(120),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<Color> markerColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
    ];

    return Column(
      children: [
        Obx(() {
          final _ = controller.events.length;
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: TableCalendar<EventItem>(
              locale: 'ko_KR',
              firstDay: DateTime.utc(2010, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: controller.focusedDay.value,
              calendarFormat: CalendarFormat.month,
              daysOfWeekHeight: 30.0,
              selectedDayPredicate: (day) {
                return controller.selectedDay.value != null &&
                    isSameDay(controller.selectedDay.value!, day);
              },
              onDaySelected: controller.onDaySelected,
              onPageChanged: controller.onPageChanged,
              eventLoader: controller.getEventsForDay,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: textStyleMedium,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: colorScheme.onTertiaryContainer,
                ),
                selectedDecoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: colorScheme.onPrimary),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, eventsFromLoader) {
                  if (eventsFromLoader.isEmpty) return null;

                  List<Widget> markers = [];
                  if (eventsFromLoader.length <= 3) {
                    for (int i = 0; i < eventsFromLoader.length; i++) {
                      markers.add(
                        _buildEventMarker(
                          context,
                          day,
                          eventsFromLoader[i],
                          markerColors[i % markerColors.length],
                        ),
                      );
                    }
                  } else {
                    markers.add(
                      _buildEventsCountMarker(
                        context,
                        day,
                        eventsFromLoader.length,
                      ),
                    );
                  }

                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: markers,
                    ),
                  );
                },
              ),
            ),
          );
        }),
        verticalSpaceSmall,
        Obx(() {
          if (controller.selectedDay.value == null) {
            return const SizedBox.shrink();
          }
          final formattedDate = DateFormat(
            'yy년 MM월 dd일 (E)',
            'ko_KR',
          ).format(controller.selectedDay.value!.toLocal());
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              formattedDate,
              style: textStyleMedium,
              textAlign: TextAlign.center,
            ),
          );
        }),
        verticalSpaceSmall,
        Expanded(
          child: Obx(() {
            if (controller.isLoadingEvents.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final events = controller.selectedDayEvents;
            if (events.isEmpty) {
              return Center(
                child: Text(
                  "선택된 날짜에 일정이 없습니다.",
                  style: textStyleSmall.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                bool isCurrentlySubmittingThisEvent =
                    controller.isSubmittingEvent.value &&
                    event.backendEventId == null;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    title: Text(event.title, style: textStyleMedium),
                    subtitle: Text(
                      event.displayTime(context),
                      style: textStyleSmall,
                    ),
                    trailing:
                        isCurrentlySubmittingThisEvent
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: colorScheme.secondary,
                                    size: 20,
                                  ),
                                  tooltip: '수정',
                                  onPressed: () {
                                    if (event.backendEventId != null) {
                                      controller.showEditEventDialog(event);
                                    } else {
                                      Get.snackbar(
                                        "알림",
                                        "이벤트가 아직 동기화되지 않았습니다.",
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: colorScheme.error,
                                    size: 20,
                                  ),
                                  tooltip: '삭제',
                                  onPressed: () {
                                    if (event.backendEventId != null) {
                                      controller.confirmDeleteEvent(event);
                                    } else {
                                      Get.snackbar(
                                        "알림",
                                        "이벤트가 아직 동기화되지 않았습니다.",
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                    onTap: () {
                      if (event.backendEventId != null) {
                        controller.showEditEventDialog(event);
                      }
                    },
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
