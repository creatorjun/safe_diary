import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../models/event_item.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class AddEditEventSheet extends StatefulWidget {
  final DateTime eventDate;
  final EventItem? existingEvent;
  final Function(EventItem event) onSubmit;

  const AddEditEventSheet({
    super.key,
    required this.eventDate,
    this.existingEvent,
    required this.onSubmit,
  });

  @override
  State<AddEditEventSheet> createState() => _AddEditEventSheetState();
}

class _AddEditEventSheetState extends State<AddEditEventSheet> {
  late TextEditingController _titleController;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingEvent?.title ?? '',
    );
    _startTime = widget.existingEvent?.startTime;
    _endTime = widget.existingEvent?.endTime;

    if (widget.existingEvent == null) {
      final now = DateTime.now();
      _startTime = TimeOfDay.fromDateTime(now);
      _endTime = TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTimeRange(BuildContext context) async {
    final now = DateTime.now();
    final initialStartDateTime = DateTime(
      widget.eventDate.year,
      widget.eventDate.month,
      widget.eventDate.day,
      _startTime?.hour ?? now.hour,
      _startTime?.minute ?? now.minute,
    );
    final initialEndDateTime = DateTime(
      widget.eventDate.year,
      widget.eventDate.month,
      widget.eventDate.day,
      _endTime?.hour ?? now.hour + 1,
      _endTime?.minute ?? now.minute,
    );

    List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
      context: context,
      startInitialDate: initialStartDateTime,
      startFirstDate:
      DateTime(widget.eventDate.year).subtract(const Duration(days: 365)),
      startLastDate:
      DateTime(widget.eventDate.year).add(const Duration(days: 365)),
      endInitialDate: initialEndDateTime,
      endFirstDate:
      DateTime(widget.eventDate.year).subtract(const Duration(days: 365)),
      endLastDate:
      DateTime(widget.eventDate.year).add(const Duration(days: 365)),
      is24HourMode: true,
      isShowSeconds: false,
      minutesInterval: 5,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 650),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(Tween(begin: 0, end: 1)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      type: OmniDateTimePickerType.time,
      startWidget: const Text("시작 시간"),
      endWidget: const Text("종료 시간"),
    );

    if (dateTimeList != null && dateTimeList.length == 2) {
      setState(() {
        _startTime = TimeOfDay.fromDateTime(dateTimeList[0]);
        _endTime = TimeOfDay.fromDateTime(dateTimeList[1]);
      });
    }
  }

  Widget _buildTimeRangePicker(BuildContext context) {
    final String startTimeStr = _startTime?.format(context) ?? "미지정";
    final String endTimeStr = _endTime?.format(context) ?? "미지정";
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _selectDateTimeRange(context),
      borderRadius: BorderRadius.circular(12.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "시간 지정 (선택)",
          prefixIcon: Icon(
            Icons.access_time_filled_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        child: Text(
          "$startTimeStr - $endTimeStr",
          style: textStyleMedium.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      if (_startTime != null && _endTime != null) {
        final startTimeDouble = _startTime!.hour + _startTime!.minute / 60.0;
        final endTimeDouble = _endTime!.hour + _endTime!.minute / 60.0;
        if (endTimeDouble <= startTimeDouble) {
          final colorScheme = Theme.of(context).colorScheme;
          Get.snackbar(
            "오류",
            "종료 시간은 시작 시간보다 늦어야 합니다.",
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(12),
            backgroundColor: colorScheme.errorContainer,
            colorText: colorScheme.onErrorContainer,
          );
          return;
        }
      }
      setState(() {
        _isSubmitting = true;
      });

      final event = EventItem(
        backendEventId: widget.existingEvent?.backendEventId,
        title: _titleController.text.trim(),
        eventDate: widget.eventDate,
        startTime: _startTime,
        endTime: _endTime,
        createdAt: widget.existingEvent?.createdAt,
      );

      widget.onSubmit(event);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existingEvent != null;
    final String dialogTitleText = isEditing ? "일정 수정" : "일정 추가";
    final String submitButtonText = isEditing ? "수정" : "추가";
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: colorScheme.primary, size: 22),
                    horizontalSpaceSmall,
                    Expanded(
                      child: Text(
                        "${DateFormat('MM월 dd일 (E)', 'ko_KR').format(widget.eventDate.toLocal())} $dialogTitleText",
                        style: textStyleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                verticalSpaceMedium,

                // Content
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      verticalSpaceSmall,
                      TextFormField(
                        controller: _titleController,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: "일정 내용",
                          hintText: "무슨 일정이 있나요?",
                          prefixIcon: Icon(
                            Icons.notes_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide:
                            BorderSide(color: colorScheme.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: textStyleMedium,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '일정 내용을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      verticalSpaceMedium,
                      _buildTimeRangePicker(context),
                      verticalSpaceSmall,
                    ],
                  ),
                ),
                verticalSpaceLarge,

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text(
                        "취소",
                        style: textStyleSmall.copyWith(
                            color: colorScheme.onSurfaceVariant),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    horizontalSpaceSmall,
                    FilledButton.icon(
                      icon: _isSubmitting
                          ? Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(right: 4),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                          : Icon(
                        isEditing
                            ? Icons.check_circle_outline
                            : Icons.add_circle_outline,
                        size: 18,
                      ),
                      label: Text(
                        submitButtonText,
                        style: textStyleSmall.copyWith(
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}