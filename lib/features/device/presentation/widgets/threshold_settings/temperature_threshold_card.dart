import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import '../../bloc/threshold_settings/threshold_settings_cubit.dart';
import '../../bloc/threshold_settings/threshold_settings_state.dart';
import 'edit_threshold_dialog.dart';
import 'border_slider.dart';

class TemperatureThresholdCard extends StatefulWidget {
  final double? currentTemperature;

  const TemperatureThresholdCard({super.key, this.currentTemperature});

  @override
  State<TemperatureThresholdCard> createState() =>
      _TemperatureThresholdCardState();
}

class _TemperatureThresholdCardState extends State<TemperatureThresholdCard> {
  RangeValues? _localRange;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BlocBuilder<ThresholdSettingsCubit, ThresholdSettingsState>(
        buildWhen: (previous, current) =>
            previous.tempMin != current.tempMin ||
            previous.tempMax != current.tempMax,
        builder: (context, state) {
          final currentRange =
              _localRange ?? RangeValues(state.tempMin, state.tempMax);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.thermostat, color: Colors.red, size: 22.w),
                  SizedBox(width: 8.w),
                  Text(
                    'Điều chỉnh nhiệt độ',
                    style: AppTextStyles.titleMediumLogin(),
                  ),
                ],
              ),

              SizedBox(height: 32.h),
              LayoutBuilder(
                builder: (context, constraints) {
                  final double maxWidth = constraints.maxWidth;
                  const double padding = 24.0;
                  final double currentVal = widget.currentTemperature ?? 0;
                  final double percentage =
                      (currentVal.clamp(0, 100) - 0) / 100;
                  final double activeWidth = maxWidth - (padding * 2);
                  final double centerPos = padding + (percentage * activeWidth);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          rangeThumbShape: const BorderedRangeSliderThumbShape(
                            borderColor: AppColors.wardroRedText,
                          ),
                          trackHeight: 4.0,
                        ),
                        child: RangeSlider(
                          values: currentRange,
                          min: 0,
                          max: 100,
                          divisions: 1000,
                          activeColor: AppColors.wardroRedText,
                          inactiveColor: AppColors.textFieldHint,
                          onChanged: (values) {
                            setState(() {
                              _localRange = values;
                            });
                          },
                          onChangeEnd: (values) {
                            context
                                .read<ThresholdSettingsCubit>()
                                .updateTempRange(values.start, values.end);
                            _localRange = null;
                          },
                        ),
                      ),
                      if (widget.currentTemperature != null)
                        Positioned(
                          left: centerPos - 30, // Approx center of text
                          top: -20.h,
                          child: Column(
                            children: [
                              Text(
                                'Hiện tại ${widget.currentTemperature!.toStringAsFixed(1).replaceAll('.', ',')}°C',
                                style: AppTextStyles.titleSmall(),
                              ),
                              SizedBox(height: 2.h),
                              Column(
                                children: List.generate(
                                  4,
                                  (index) => Container(
                                    width: 1.5,
                                    height: 9.h,
                                    color: AppColors.textFieldHint,
                                    margin: EdgeInsets.only(bottom: 2.h),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildThresholdButton(
                      context,
                      label: 'Low',
                      value: currentRange.start,
                      isMin: true,
                      currentRange: currentRange,
                    ),
                    _buildThresholdButton(
                      context,
                      label: 'High',
                      value: currentRange.end,
                      isMin: false,
                      currentRange: currentRange,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThresholdButton(
    BuildContext context, {
    required String label,
    required double value,
    required bool isMin,
    required RangeValues currentRange,
  }) {
    return InkWell(
      onTap: () => _showEditDialog(context, value, isMin, currentRange),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          '$label: ${value.toStringAsFixed(1).replaceAll('.', ',')}°C',
          style: AppTextStyles.titleSmall().copyWith(color: Colors.black),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    double currentValue,
    bool isMin,
    RangeValues currentRange,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return EditThresholdDialog(
          currentValue: currentValue,
          isMin: isMin,
          currentRange: currentRange,
          suffixText: '°C',
          primaryColor: const Color(0xFFE53935),
          onSave: (newMin, newMax) {
            context.read<ThresholdSettingsCubit>().updateTempRange(
              newMin,
              newMax,
            );
          },
        );
      },
    );
  }
}
