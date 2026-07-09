import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/history/domain/entities/threshold_change_log.dart';
import 'package:thermo_humi/features/history/presentation/bloc/threshold_log_cubit.dart';
import 'package:thermo_humi/features/history/presentation/bloc/threshold_log_state.dart';
import 'package:thermo_humi/features/history/presentation/widgets/threshold_log_tile.dart';
import 'package:thermo_humi/features/history/presentation/widgets/threshold_search_bar.dart';

class ThresholdLogPage extends StatelessWidget {
  const ThresholdLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ThresholdLogCubit>()..fetchLogs(),
      child: const _ThresholdLogView(),
    );
  }
}

class _ThresholdLogView extends StatefulWidget {
  const _ThresholdLogView();

  @override
  State<_ThresholdLogView> createState() => _ThresholdLogViewState();
}

class _ThresholdLogViewState extends State<_ThresholdLogView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ThresholdLogCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            'Lịch sử thay đổi',
            style: AppTextStyles.titleMediumAppBar().copyWith(
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            ThresholdSearchBar(
              onSearch: (query) {
                context.read<ThresholdLogCubit>().search(query);
              },
            ),
            Expanded(
              child: BlocConsumer<ThresholdLogCubit, ThresholdLogState>(
                listener: (context, state) {
                  if (state is ThresholdLogLoadMoreError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
                  }
                },
                builder: (context, state) {
                  if (state is ThresholdLogLoading ||
                      state is ThresholdLogInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ThresholdLogError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (state is ThresholdLogLoaded) {
                    final items = state.items;

                    if (items.isEmpty) {
                      return const Center(
                        child: Text('Không tìm thấy dữ liệu'),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(bottom: 24.h),
                      itemCount: items.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == items.length) {
                          return Padding(
                            padding: EdgeInsets.all(16.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final item = items[index];
                        if (item is String) {
                          // Date Header
                          return Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                            child: Text(
                              item,
                              style: AppTextStyles.bodyMedium().copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        } else if (item is ThresholdChangeLog) {
                          // Log item
                          return ThresholdLogTile(log: item);
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
