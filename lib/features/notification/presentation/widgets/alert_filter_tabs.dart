import 'package:flutter/material.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum AlertFilter {
  all('Tất cả'),
  unresolved('Chưa xử lý'),
  resolved('Đã xử lý');

  final String label;
  const AlertFilter(this.label);
}

class AlertFilterTabs extends StatelessWidget {
  final AlertFilter selectedFilter;
  final int unresolvedCount;
  final ValueChanged<AlertFilter> onFilterChanged;

  const AlertFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.unresolvedCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: AlertFilter.values.map((filter) {
          final isSelected = filter == selectedFilter;
          final isUnresolvedTab = filter == AlertFilter.unresolved;

          String displayText = filter.label;
          if (isUnresolvedTab && unresolvedCount > 0) {
            displayText = '${filter.label} ($unresolvedCount)';
          }

          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.gradientEnd : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.gradientEnd
                        : Colors.grey.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: Offset(0, 3.w),
                    ),
                  ],
                ),
                child: Text(
                  displayText,
                  style:
                      AppTextStyles.labelMedium(
                        color: isSelected ? Colors.white : Colors.grey,
                      ).copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
