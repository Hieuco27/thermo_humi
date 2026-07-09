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
import 'package:thermo_humi/features/history/presentation/pages/threshold_log_page.dart';
import 'package:thermo_humi/features/member_management/presentation/pages/member_management_screen.dart';
import 'package:thermo_humi/features/request_access/domain/entities/access_request.dart';
import 'package:thermo_humi/features/request_access/presentation/pages/access_request_list_screen.dart';
import 'package:thermo_humi/features/request_access/presentation/pages/access_request_detail_screen.dart';
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
                routes: [
                  GoRoute(
                    path: 'request-access',
                    name: 'request-access-list',
                    builder: (_, __) => const AccessRequestListScreen(),
                  ),
                  GoRoute(
                    path: 'request-access/:id',
                    name: 'request-access-detail',
                    builder: (_, state) {
                      final id = state.pathParameters['id']!;
                      final typeString = state.uri.queryParameters['type'];
                      final type = typeString == 'room' ? AccessRequestType.room : AccessRequestType.device;
                      return AccessRequestDetailScreen(id: id, type: type);
                    },
                  ),
                ],
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
                routes: [
                  GoRoute(
                    path: 'threshold-history',
                    name: 'threshold-history',
                    builder: (_, __) => const ThresholdLogPage(),
                  ),
                  GoRoute(
                    path: 'member-management',
                    name: 'member-management',
                    builder: (_, __) => const MemberManagementScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
