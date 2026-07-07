/// GoRouter configuration — Shell route với bottom navigation
library;

import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:thermo_humi/core/router/route_names.dart';
import 'package:thermo_humi/features/home/presentation/pages/home_page.dart';
import 'package:thermo_humi/features/notification/presentation/pages/notification_page.dart';
import 'package:thermo_humi/features/profile/presentation/pages/profile_page.dart';
import 'package:thermo_humi/features/report/presentation/pages/report_page.dart';
import 'package:thermo_humi/features/room/presentation/pages/room_list_page.dart';
import 'package:thermo_humi/features/room/presentation/pages/room_detail_page.dart';
import 'package:thermo_humi/common/widgets/nav_bar.dart';
import 'package:thermo_humi/features/auth/presentation/pages/sign_in_page.dart';
import 'package:thermo_humi/features/auth/presentation/pages/sign_up_page.dart';

@singleton
class AppRouter {
  AppRouter._();
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.login,
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (_, __) => const SignInPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => const SignUpPage(),
      ),

      // ── Shell Route (Bottom Nav) ───────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Tab 0: Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                name: 'home',
                builder: (_, __) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'room/:roomId',
                    name: 'device-list',
                    builder: (_, state) =>
                        RoomDetailPage(roomId: state.pathParameters['roomId']!),
                  ),
                ],
              ),
            ],
          ),

          // Tab 1: Areas (Danh sách các phòng)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.areas,
                name: 'areas',
                builder: (_, __) => const RoomListPage(),
                routes: [
                  GoRoute(
                    path: 'room/:roomId',
                    name: 'areas-device-list',
                    builder: (_, state) =>
                        RoomDetailPage(roomId: state.pathParameters['roomId']!),
                  ),
                ],
              ),
            ],
          ),

          // Tab 2: Notifications
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.notifications,
                name: 'notifications',
                builder: (_, __) => const NotificationPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.report,
                name: 'report',
                builder: (_, __) => const ReportPage(),
              ),
            ],
          ),

          // Tab 4: Settings (Profile)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                name: 'profile',
                builder: (_, __) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
