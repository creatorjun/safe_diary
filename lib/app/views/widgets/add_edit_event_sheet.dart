// lib/app/views/widgets/add_edit_event_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:safe_diary/app/models/anniversary_dtos.dart';

import '../../models/event_item.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_strings.dart';

class AddEditEventSheet extends StatefulWidget {
  final DateTime eventDate;
  final EventItem? existingEvent;
  final Future<void> Function(EventItem event)? onEventSubmit;
  final Future<void> Function(AnniversaryCreateRequestDto anniversary)?
  onAnniversarySubmit;
  final bool isEditMode;

  const AddEditEventSheet({
    super.key,
    required this.eventDate,
    this.existingEvent,
    this.onEventSubmit,
    this.onAnniversarySubmit,
  }) : isEditMode = existingEvent != null;

  @override
  State<AddEditEventSheet> createState() => _AddEditEventSheetState();
}

class _AddEditEventSheetState extends State<AddEditEventSheet> {
  late TextEditingController _titleController;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isAnniversaryMode = false;

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

      if (now.hour >= 23) {
        _endTime = const TimeOfDay(hour: 23, minute: 59);
      } else {
        _endTime = TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isAnniversaryMode = !_isAnniversaryMode;
    });
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
      startWidget: const Text(AppStrings.startTime),
      endWidget: const Text(AppStrings.endTime),
    );

    if (dateTimeList != null && dateTimeList.length == 2) {
      setState(() {
        _startTime = TimeOfDay.fromDateTime(dateTimeList[0]);
        _endTime = TimeOfDay.fromDateTime(dateTimeList[1]);
      });
    }
  }

  Widget _buildTimeRangePicker(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;

    final String startTimeStr =
        _startTime?.format(context) ?? AppStrings.unspecified;
    final String endTimeStr =
        _endTime?.format(context) ?? AppStrings.unspecified;

    final bool isEndTimeFixed = widget.existingEvent == null &&
        _startTime != null &&
        _startTime!.hour >= 23;

    return InkWell(
      onTap: isEndTimeFixed ? null : () => _selectDateTimeRange(context),
      borderRadius: BorderRadius.circular(12.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppStrings.timePickerLabelOptional,
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
          enabledBorder: isEndTimeFixed
              ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: colorScheme.onSurface.withAlpha(77),
            ),
          )
              : null,
        ),
        child: Text(
          "$startTimeStr - $endTimeStr",
          style: textStyles.bodyLarge.copyWith(
            color: isEndTimeFixed
                ? colorScheme.onSurface.withAlpha(128)
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        if (_isAnniversaryMode) {
          if (widget.onAnniversarySubmit != null) {
            final anniversary = AnniversaryCreateRequestDto(
              title: _titleController.text.trim(),
              date: DateFormat('yyyy-MM-dd').format(widget.eventDate),
            );
            await widget.onAnniversarySubmit!(anniversary);
          }
        } else {
          if (widget.onEventSubmit != null) {
            if (_startTime != null && _endTime != null) {
              final startTimeDouble =
                  _startTime!.hour + _startTime!.minute / 60.0;
              final endTimeDouble = _endTime!.hour + _endTime!.minute / 60.0;
              if (endTimeDouble <= startTimeDouble) {
                final colorScheme = Theme.of(context).colorScheme;
                Get.snackbar(
                  AppStrings.error,
                  AppStrings.endTimeAfterStartTimeError,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(12),
                  backgroundColor: colorScheme.errorContainer,
                  colorText: colorScheme.onErrorContainer,
                );
                setState(() {
                  _isSubmitting = false;
                });
                return;
              }
            }
            final event = EventItem(
              backendEventId: widget.existingEvent?.backendEventId,
              title: _titleController.text.trim(),
              eventDate: widget.eventDate,
              startTime: _startTime,
              endTime: _endTime,
              createdAt: widget.existingEvent?.createdAt,
            );
            await widget.onEventSubmit!(event);
          }
        }
        Get.back();
      } catch (e) {
        // Error handling is managed by the calling controller
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;

    final String dialogTitleText = _isAnniversaryMode
        ? "기념일 추가"
        : (widget.isEditMode ? AppStrings.editEvent : AppStrings.addEvent);
    final String submitButtonText = _isAnniversaryMode
        ? AppStrings.add
        : (widget.isEditMode ? AppStrings.edit : AppStrings.add);
    final String hintText = _isAnniversaryMode
        ? "기념일 이름을 입력하세요"
        : AppStrings.eventContentHint;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
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
                Row(
                  children: [
                    Icon(
                      _isAnniversaryMode
                          ? Icons.cake_outlined
                          : Icons.calendar_today_outlined,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    SizedBox(width: spacing.small),
                    Expanded(
                      child: Text(
                        "${DateFormat('MM월 dd일 (E)', 'ko_KR').format(widget.eventDate.toLocal())} $dialogTitleText",
                        style: textStyles.bodyLarge.copyWith(
                          color: colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!widget.isEditMode) ...[
                      SizedBox(width: spacing.small),
                      OutlinedButton(
                        onPressed: _toggleMode,
                        child: Text(
                          _isAnniversaryMode ? "일반 일정" : "기념일 지정",
                          style: textStyles.bodyMedium,
                        ),
                      ),
                    ]
                  ],
                ),
                SizedBox(height: spacing.medium),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: spacing.small),
                      TextFormField(
                        controller: _titleController,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: _isAnniversaryMode
                              ? "기념일 이름"
                              : AppStrings.eventContent,
                          hintText: hintText,
                          prefixIcon: Icon(
                            _isAnniversaryMode
                                ? Icons.favorite_border
                                : Icons.notes_rounded,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                        style: textStyles.bodyLarge,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return _isAnniversaryMode
                                ? "기념일 이름을 입력해주세요."
                                : AppStrings.eventContentRequired;
                          }
                          return null;
                        },
                      ),
                      if (!_isAnniversaryMode) ...[
                        SizedBox(height: spacing.medium),
                        _buildTimeRangePicker(context),
                      ],
                      SizedBox(height: spacing.small),
                    ],
                  ),
                ),
                SizedBox(height: spacing.large),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text(
                        AppStrings.cancel,
                        style: textStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    SizedBox(width: spacing.small),
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
                        widget.isEditMode
                            ? Icons.check_circle_outline
                            : Icons.add_circle_outline,
                        size: 18,
                      ),
                      label: Text(
                        submitButtonText,
                        style: textStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _handleSubmit,
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