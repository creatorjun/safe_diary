// lib/app/views/calendar_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:safe_diary/app/utils/app_strings.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/home_controller.dart';
import '../models/event_item.dart';
import '../theme/app_theme.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHolidayCard(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;

    return Obx(() {
      final holidayName = controller.selectedDayHolidayName;
      if (holidayName == null) {
        return const SizedBox.shrink();
      }
      return Card(
        color: colorScheme.tertiaryContainer.withAlpha(150),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.celebration_outlined,
                color: colorScheme.onTertiaryContainer,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                holidayName,
                style: textStyles.bodyMedium.copyWith(
                  color: colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;
    final AppCustomColors customColors = theme.extension<AppCustomColors>()!;

    final List<Color> markerColors = [
      customColors.markerColor1,
      customColors.markerColor2,
      customColors.markerColor3,
    ];

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Obx(() {
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
                holidayPredicate: (day) {
                  return controller.holidays.containsKey(day);
                },
                onDaySelected: controller.onDaySelected,
                onPageChanged: controller.onPageChanged,
                eventLoader: controller.getEventsForDay,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: textStyles.bodyLarge,
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: textStyles.bodyMedium,
                  weekendStyle: textStyles.bodyMedium.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withAlpha(204),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: textStyles.bodyMedium.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: textStyles.bodyMedium.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                  defaultTextStyle: textStyles.bodyMedium,
                  weekendTextStyle: textStyles.bodyMedium.copyWith(
                    color: colorScheme.error,
                  ),
                  outsideTextStyle: textStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface.withAlpha(128),
                  ),
                  holidayTextStyle: textStyles.bodyMedium.copyWith(
                    color: colorScheme.error,
                  ),
                  holidayDecoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
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
          SizedBox(height: spacing.small),
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
                style: textStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
            );
          }),
          _buildHolidayCard(context),
          SizedBox(height: spacing.small),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingEvents.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final events = controller.selectedDayEvents;
              if (events.isEmpty) {
                return Center(
                  child: Text(
                    AppStrings.noEventsOnSelectedDate,
                    style: textStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
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
                    child: ListTile(
                      title: Text(event.title, style: textStyles.bodyLarge),
                      subtitle: Text(
                        event.displayTime(context),
                        style: textStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing:
                      isCurrentlySubmittingThisEvent
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
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
                            tooltip: AppStrings.edit,
                            onPressed: () {
                              if (event.backendEventId != null) {
                                controller.showEditEventDialog(event);
                              } else {
                                Get.snackbar(
                                  AppStrings.notification,
                                  AppStrings.eventNotSynced,
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
                            tooltip: AppStrings.delete,
                            onPressed: () {
                              if (event.backendEventId != null) {
                                controller.confirmDeleteEvent(event);
                              } else {
                                Get.snackbar(
                                  AppStrings.notification,
                                  AppStrings.eventNotSynced,
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
      ),
    );
  }
}