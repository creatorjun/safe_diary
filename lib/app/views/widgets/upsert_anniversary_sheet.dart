// lib/app/views/widgets/upsert_anniversary_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:safe_diary/app/models/anniversary_dtos.dart';
import 'package:safe_diary/app/theme/app_theme.dart';
import 'package:safe_diary/app/utils/app_strings.dart';

class UpsertAnniversarySheet extends StatefulWidget {
  final AnniversaryResponseDto? existingAnniversary;
  final Future<void> Function(AnniversaryUpdateRequestDto request) onSubmit;

  const UpsertAnniversarySheet({
    super.key,
    this.existingAnniversary,
    required this.onSubmit,
  });

  @override
  State<UpsertAnniversarySheet> createState() => _UpsertAnniversarySheetState();
}

class _UpsertAnniversarySheetState extends State<UpsertAnniversarySheet> {
  late TextEditingController _titleController;
  late DateTime _selectedDate;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingAnniversary?.title ?? '');
    _selectedDate =
        widget.existingAnniversary?.dateTime ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final request = AnniversaryUpdateRequestDto(
        title: _titleController.text,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      );

      try {
        await widget.onSubmit(request);
        Get.back();
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
    final AppTextStyles textStyles = theme.extension<AppTextStyles>()!;
    final AppSpacing spacing = theme.extension<AppSpacing>()!;
    final bool isEditMode = widget.existingAnniversary != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditMode ? "기념일 수정" : "기념일 추가",
                  style: textStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.large),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "기념일 이름"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "기념일 이름을 입력해주세요.";
                    }
                    return null;
                  },
                ),
                SizedBox(height: spacing.medium),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "날짜",
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                          style: textStyles.bodyLarge,
                        ),
                        const Icon(Icons.calendar_today_outlined),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: spacing.large),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(AppStrings.cancel),
                    ),
                    SizedBox(width: spacing.small),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      child: _isSubmitting
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(AppStrings.save),
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