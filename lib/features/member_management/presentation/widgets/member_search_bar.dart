import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class MemberSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const MemberSearchBar({super.key, required this.onSearch});

  @override
  State<MemberSearchBar> createState() => _MemberSearchBarState();
}

class _MemberSearchBarState extends State<MemberSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey, size: 22.w),
          hintText: 'Tìm theo tên hoặc email',
          hintStyle: AppTextStyles.bodyMedium().copyWith(color: Colors.grey),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        style: AppTextStyles.bodyMedium(),
      ),
    );
  }
}
