import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/common/widgets/app_background.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/features/notification/domain/entities/alert_model.dart';
import 'package:thermo_humi/features/notification/presentation/cubit/alert_cubit.dart';
import 'package:thermo_humi/features/notification/presentation/cubit/alert_state.dart';
import 'package:thermo_humi/features/notification/presentation/widgets/alert_card.dart';
import 'package:thermo_humi/features/notification/presentation/widgets/alert_filter_tabs.dart';
import 'package:thermo_humi/features/notification/presentation/widgets/day_group_header.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ScrollController _scrollController = ScrollController();
  AlertFilter _currentFilter = AlertFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AlertCubit>().loadMore();
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
          title: Text(
            'Thông báo',
            style: AppTextStyles.titleMedium(color: Colors.white),
          ),
        ),
        body: BlocBuilder<AlertCubit, AlertState>(
          builder: (context, state) {
            if (state is AlertInitial ||
                (state is AlertLoading && state is! AlertLoaded)) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AlertError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state is AlertLoaded) {
              final unresolvedCount = state.unresolvedCount;
              final filteredItems = _getFilteredItems(state.items);
              final flattenData = _buildFlattenData(filteredItems);

              return RefreshIndicator(
                onRefresh: () => context.read<AlertCubit>().refresh(),
                child: Column(
                  children: [
                    AlertFilterTabs(
                      selectedFilter: _currentFilter,
                      unresolvedCount: unresolvedCount,
                      onFilterChanged: (filter) {
                        setState(() => _currentFilter = filter);
                      },
                    ),
                    Expanded(
                      child: filteredItems.isEmpty
                          ? const Center(
                              child: Text(
                                'Không có thông báo nào',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount:
                                  flattenData.length +
                                  (state.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == flattenData.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final item = flattenData[index];
                                if (item is DateTime) {
                                  return DayGroupHeader(date: item);
                                } else if (item is AlertModel) {
                                  return AlertCard(
                                    alert: item,
                                    isResolving: state.resolvingIds.contains(
                                      item.id,
                                    ),
                                    onTap: () {
                                      // Navigate to Device Detail / Threshold
                                      context.push('/home/room/${item.roomId}');
                                      // Note: adjust route based on exact app flow to DeviceDetailPage
                                    },
                                    onResolveTap: () {
                                      context.read<AlertCubit>().resolveAlert(
                                        item.id,
                                      );
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  List<AlertModel> _getFilteredItems(List<AlertModel> items) {
    if (_currentFilter == AlertFilter.unresolved) {
      return items.where((e) => !e.isResolved).toList();
    } else if (_currentFilter == AlertFilter.resolved) {
      return items.where((e) => e.isResolved).toList();
    }
    return items;
  }

  List<dynamic> _buildFlattenData(List<AlertModel> items) {
    final List<dynamic> data = [];
    DateTime? lastDate;

    for (final item in items) {
      final date = DateTime(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );
      if (lastDate != date) {
        data.add(date);
        lastDate = date;
      }
      data.add(item);
    }

    return data;
  }
}
