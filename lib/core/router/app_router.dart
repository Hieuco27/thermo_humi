import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:thermo_humi/core/router/route_names.dart';
import 'package:thermo_humi/features/home/presentation/pages/home_page.dart';
import 'package:thermo_humi/features/notification/presentation/pages/notification_page.dart';
import 'package:thermo_humi/features/profile/presentation/pages/profile_page.dart';
import 'package:thermo_humi/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/device_management/presentation/pages/add_device_screen.dart';
import 'package:thermo_humi/features/report/presentation/pages/report_page.dart';
import 'package:thermo_humi/features/room/presentation/pages/room_list_page.dart';
import 'package:thermo_humi/features/room/presentation/pages/room_detail_page.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/room_detail_screen.dart'
    as rm;
import 'package:thermo_humi/common/widgets/nav_bar.dart';
import 'package:thermo_humi/features/auth/presentation/pages/sign_in_page.dart';
import 'package:thermo_humi/features/auth/presentation/pages/sign_up_page.dart';
import 'package:thermo_humi/features/auth/presentation/pages/change_password.dart';
import 'package:thermo_humi/features/history/presentation/pages/threshold_log_page.dart';
import 'package:thermo_humi/features/member_management/presentation/pages/member_management_screen.dart';
import 'package:thermo_humi/features/request_access/domain/entities/access_request.dart';
import 'package:thermo_humi/features/request_access/presentation/pages/access_request_list_screen.dart';
import 'package:thermo_humi/features/request_access/presentation/pages/access_request_detail_screen.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/room_management_screen.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/add_room_screen.dart';
import 'package:thermo_humi/features/device_management/presentation/pages/device_management_screen.dart';

import 'package:thermo_humi/core/router/router_guard.dart';
import 'package:thermo_humi/core/di/injection_container.dart';

@singleton
class AppRouter {
  AppRouter._();
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.login,
    redirect: sl<RouterGuard>().redirect,
    routes: [
      // Auth
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (_, __) => const SignInPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (_, __) => const SignUpPage(),
      ),
      // Access Request
      GoRoute(
        path: '/request-access',
        name: 'request-access-list',
        builder: (_, __) => const AccessRequestListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'request-access-detail',
            builder: (_, state) {
              final id = state.pathParameters['id']!;
              final typeString = state.uri.queryParameters['type'];
              final type = typeString == 'room'
                  ? AccessRequestType.room
                  : AccessRequestType.device;
              return AccessRequestDetailScreen(id: id, type: type);
            },
          ),
        ],
      ),

      // Shell Route (Bottom Nav)
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
                builder: (_, __) => BlocProvider(
                  create: (context) => sl<ProfileCubit>()..loadUser(),
                  child: const ProfilePage(),
                ),
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
                  GoRoute(
                    path: 'room-management',
                    name: 'room-management',
                    builder: (_, __) => const RoomManagementScreen(),
                    routes: [
                      GoRoute(
                        path: 'add-room',
                        name: 'add-room',
                        builder: (_, state) => AddRoomScreen(
                          existingRoomId:
                              state.uri.queryParameters['existingRoomId'],
                          isFlexible:
                              state.uri.queryParameters['flexible'] == 'true',
                        ),
                      ),
                      GoRoute(
                        path: ':roomId',
                        name: 'room-management-detail',
                        builder: (_, state) => rm.RoomDetailScreen(
                          roomId: state.pathParameters['roomId']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'device-management',
                    name: 'device-management',
                    builder: (_, __) => const DeviceManagementScreen(),
                    routes: [
                      GoRoute(
                        path: 'add-device',
                        name: 'add-device',
                        builder: (_, __) => const AddDeviceScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'change-password',
                    name: 'change-password',
                    builder: (_, __) => const ChangePasswordPage(),
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
