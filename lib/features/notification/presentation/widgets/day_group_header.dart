import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class DayGroupHeader extends StatelessWidget {
  final DateTime date;

  const DayGroupHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Text(
        _formatDate(date),
        style: AppTextStyles.labelMedium(color: Colors.black),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (targetDate == today) {
      return 'Hôm nay';
    } else if (targetDate == yesterday) {
      return 'Hôm qua';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}
