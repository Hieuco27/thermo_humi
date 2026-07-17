import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class ReportDatePicker extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const ReportDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<ReportDatePicker> createState() => _ReportDatePickerState();
}

class _ReportDatePickerState extends State<ReportDatePicker> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollToSelectedDay();
  }

  @override
  void didUpdateWidget(covariant ReportDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _scrollToSelectedDay();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Calculate offset: each item is 56.w width + 8.w margin = 64.w
        final offset = (widget.selectedDate.day - 1) * 64.w;
        // Adjust offset to center it (subtract half of available width)
        final screenWidth = MediaQuery.of(context).size.width;
        final listWidth = screenWidth - 100.w - 32.w; // approx width of list
        final finalOffset = (offset - (listWidth / 2) + 32.w).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );

        _scrollController.animateTo(
          finalOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String _getVietnameseDayOfWeek(int weekday) {
    if (weekday == DateTime.sunday) return 'CN';
    return 'TH ${weekday + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );

    return SizedBox(
      height: 64.h,
      child: Row(
        children: [
          // Nút chọn Tháng / Năm
          GestureDetector(
            onTap: () async {
              final date = await showDialog<DateTime>(
                context: context,
                builder: (context) =>
                    _MonthYearPickerDialog(initialDate: widget.selectedDate),
              );
              if (date != null) {
                widget.onDateSelected(date);
              }
            },
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: AppColors.gradientEnd,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Thg ${widget.selectedDate.month}',
                    style: AppTextStyles.label13(
                      color: Colors.white,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.selectedDate.year}',
                    style: AppTextStyles.bodySmall(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Thanh phân cách
          Container(
            width: 1,
            height: 40.h,
            color: Colors.grey.shade300,
            margin: EdgeInsets.symmetric(horizontal: 12.w),
          ),

          // Danh sách cuộn chọn ngày
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: daysInMonth,
              itemBuilder: (context, index) {
                final day = index + 1;
                final date = DateTime(
                  widget.selectedDate.year,
                  widget.selectedDate.month,
                  day,
                );
                final isSelected = day == widget.selectedDate.day;
                final dayOfWeek = _getVietnameseDayOfWeek(date.weekday);

                return GestureDetector(
                  onTap: () => widget.onDateSelected(date),
                  child: Container(
                    width: 56.w,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.gradientEnd
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style:
                              AppTextStyles.label13(
                                color: isSelected ? Colors.white : Colors.black,
                              ).copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          dayOfWeek,
                          style: AppTextStyles.labelSmall(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const _MonthYearPickerDialog({required this.initialDate});

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thg $_selectedMonth $_selectedYear',
              style: AppTextStyles.titleMedium(color: Colors.black),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Text(
                  '$_selectedYear',
                  style: AppTextStyles.titleLarge(
                    color: Colors.black,
                  ).copyWith(fontSize: 28.sp),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedYear++;
                    });
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedYear--;
                    });
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.2,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 16.h,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = month == _selectedMonth;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMonth = month;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.gradientEnd
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Thg $month',
                      style:
                          AppTextStyles.bodyMedium(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ).copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Hủy',
                    style: AppTextStyles.titleSmall2(
                      color: AppColors.gradientEnd,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                TextButton(
                  onPressed: () {
                    // Nếu chọn trúng tháng/năm hiện tại ngoài đời thực -> nhảy về hôm nay
                    // Nếu chọn tháng khác -> giữ nguyên ngày đang chọn
                    final now = DateTime.now();
                    int targetDay = widget.initialDate.day;

                    if (_selectedYear == now.year &&
                        _selectedMonth == now.month) {
                      targetDay = now.day;
                    }

                    int maxDays = DateUtils.getDaysInMonth(
                      _selectedYear,
                      _selectedMonth,
                    );
                    if (targetDay > maxDays) {
                      targetDay = maxDays;
                    }
                    Navigator.of(
                      context,
                    ).pop(DateTime(_selectedYear, _selectedMonth, targetDay));
                  },
                  child: Text(
                    'Chọn',
                    style: AppTextStyles.titleSmall2(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
