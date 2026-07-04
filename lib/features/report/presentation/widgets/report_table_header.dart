import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

/// Hàng tiêu đề cố định của bảng báo cáo (Giờ / Nhiệt độ / Độ ẩm / Tình trạng).
class ReportTableHeader extends StatelessWidget {
  const ReportTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(flex: 2, child: _headerText('Giờ')),
          Expanded(
            flex: 3,
            child: _headerText('Nhiệt độ', align: TextAlign.center),
          ),
          Expanded(
            flex: 3,
            child: _headerText('Độ ẩm', align: TextAlign.center),
          ),
          Expanded(
            flex: 3,
            child: _headerText('Tình trạng', align: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _headerText(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: AppTextStyles.labelMedium(color: Colors.black)
          .copyWith(fontWeight: FontWeight.w600),
    );
  }
}
