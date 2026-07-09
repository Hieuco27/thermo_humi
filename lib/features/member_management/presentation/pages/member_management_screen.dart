import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/member_management/domain/entities/member.dart';
import 'package:thermo_humi/features/member_management/presentation/cubit/member_cubit.dart';
import 'package:thermo_humi/features/member_management/presentation/cubit/member_state.dart';
import 'package:thermo_humi/features/member_management/presentation/widgets/member_list_tile.dart';
import 'package:thermo_humi/features/member_management/presentation/widgets/member_search_bar.dart';
import 'package:thermo_humi/features/member_management/presentation/widgets/pending_member_action_sheet.dart';
import 'package:thermo_humi/features/member_management/presentation/widgets/remove_confirm_dialog.dart';
import 'package:thermo_humi/features/member_management/presentation/widgets/role_selection_sheet.dart';

class MemberManagementScreen extends StatelessWidget {
  const MemberManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MemberCubit>()..fetchMembers(),
      child: const _MemberManagementView(),
    );
  }
}

class _MemberManagementView extends StatefulWidget {
  const _MemberManagementView();

  @override
  State<_MemberManagementView> createState() => _MemberManagementViewState();
}

class _MemberManagementViewState extends State<_MemberManagementView> {
  void _showRoleSheet(
    BuildContext context,
    Member member,
    bool isLastAdmin,
  ) async {
    final result = await showModalBottomSheet<MemberRole>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return RoleSelectionSheet(
          member: member,
          isLastAdmin: isLastAdmin,
          onRemove: () async {
            // Đóng sheet trước, mở dialog sau
            Navigator.pop(context);
            _showRemoveDialog(context, member);
          },
        );
      },
    );

    if (result != null && mounted) {
      context.read<MemberCubit>().updateRole(member.id, result);
    }
  }

  void _showPendingSheet(BuildContext context, Member member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PendingMemberActionSheet(
          member: member,
          onResend: () {
            context.read<MemberCubit>().resendInvite(member.id);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Đã gửi lại lời mời')));
          },
          onRevoke: () {
            context.read<MemberCubit>().revokeInvite(member.id);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Đã thu hồi lời mời')));
          },
        );
      },
    );
  }

  void _showRemoveDialog(BuildContext context, Member member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => RemoveConfirmDialog(member: member),
    );

    if (confirm == true && mounted) {
      context.read<MemberCubit>().removeMember(member.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.gradientEnd,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 22.sp),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Quản lý thành viên',
            style: AppTextStyles.titleMediumAppBar().copyWith(
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
              onPressed: () {
                // Dummy action for now
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Tính năng mời thành viên đang được xây dựng',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            MemberSearchBar(
              onSearch: (query) {
                context.read<MemberCubit>().search(query);
              },
            ),

            // Content
            Expanded(
              child: BlocConsumer<MemberCubit, MemberState>(
                listenWhen: (previous, current) =>
                    previous.errorMessage != current.errorMessage,
                listener: (context, state) {
                  if (state.status == MemberStatus.failure &&
                      state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.status == MemberStatus.loading ||
                      state.status == MemberStatus.initial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final members = state.filteredMembers;
                  final isLastAdmin = state.isLastAdmin;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Member Count
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                        child: Text(
                          '${members.length} thành viên',
                          style: AppTextStyles.labelMedium(
                            color: Colors.grey[600]!,
                          ),
                        ),
                      ),

                      // List
                      Expanded(
                        child: members.isEmpty
                            ? Center(
                                child: Text(
                                  'Không tìm thấy thành viên nào',
                                  style: AppTextStyles.bodyMedium(),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: members.length,
                                itemBuilder: (context, index) {
                                  final member = members[index];
                                  return MemberListTile(
                                    key: ValueKey(member.id),
                                    member: member,
                                    onTap: () {
                                      if (member.isPending) {
                                        _showPendingSheet(context, member);
                                      } else {
                                        _showRoleSheet(
                                          context,
                                          member,
                                          isLastAdmin,
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Bottom Invite Button
            // Container(
            //   padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black.withOpacity(0.05),
            //         offset: const Offset(0, -4),
            //         blurRadius: 8,
            //       ),
            //     ],
            //   ),
            //   child: ElevatedButton.icon(
            //     onPressed: () {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //           content: Text(
            //             'Tính năng mời thành viên đang được xây dựng',
            //           ),
            //         ),
            //       );
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.gradientEnd,
            //       padding: EdgeInsets.symmetric(vertical: 14.h),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8.r),
            //       ),
            //       elevation: 0,
            //     ),
            //     icon: const Icon(Icons.mail_outline, color: Colors.white),
            //     label: Text(
            //       'Mời thành viên mới',
            //       style: AppTextStyles.bodyLarge().copyWith(
            //         color: Colors.white,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
