import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.background, // Dark blue from design
          indicatorColor: Colors.transparent, // Disable default pill indicator
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(
                color: Colors.green,
                size: 24,
              ); // Cyan for selected
            }
            return const IconThemeData(
              color: Colors.grey,
              size: 22,
            ); // Grey for unselected
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelSmall(color: Colors.green);
            }
            return AppTextStyles.labelSmall(color: Colors.grey);
          }),
        ),
        child: NavigationBar(
          height: 60 + MediaQuery.paddingOf(context).bottom,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onTap,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: AppTab.values.map((tab) => tab.destination).toList(),
        ),
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// Enum định nghĩa các tab trong ứng dụng.
enum AppTab {
  home('Trang chủ', 'assets/icons/navbar/home.svg'),
  areas('Phòng', 'assets/icons/navbar/list.svg'),
  notifications('Thông báo', 'assets/icons/navbar/thongBao.svg'),
  report('Báo cáo', 'assets/icons/navbar/report.svg'),
  settings('Tài khoản', 'assets/icons/navbar/profile.svg');

  const AppTab(this.label, this.iconPath);

  final String label;
  final String iconPath;

  NavigationDestination get destination =>
      NavigationDestination(icon: SvgNavIcon(iconPath), label: label);
}

class SvgNavIcon extends StatelessWidget {
  final String assetName;

  const SvgNavIcon(this.assetName, {super.key});

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    return SvgPicture.asset(
      assetName,
      width: iconTheme.size ?? 22,
      height: iconTheme.size ?? 22,
      colorFilter: iconTheme.color != null
          ? ColorFilter.mode(iconTheme.color!, BlendMode.srcIn)
          : null,
    );
  }
}
