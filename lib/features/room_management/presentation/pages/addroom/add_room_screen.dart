import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/features/room_management/domain/repositories/room_repository.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/add_room/add_room_cubit.dart';
import 'package:thermo_humi/features/room_management/presentation/bloc/add_room/add_room_state.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/add_room/activate_button.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/add_room/device_recognized_banner.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/add_room/imei_input_field.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/add_room/qr_scan_area.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/add_room/qr_scanner_sheet.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/add_room/room_name_input.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/add_room/scan_option_sheet.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/section_label.dart';

class AddRoomScreen extends StatelessWidget {
  final String? existingRoomId;
  final bool isFlexible;

  const AddRoomScreen({
    super.key,
    this.existingRoomId,
    this.isFlexible = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddRoomCubit(
        repository: sl<RoomRepository>(),
        existingRoomId: existingRoomId,
        isFlexible: isFlexible,
      ),
      child: const _AddRoomView(),
    );
  }
}

class _AddRoomView extends StatefulWidget {
  const _AddRoomView();

  @override
  State<_AddRoomView> createState() => _AddRoomViewState();
}

class _AddRoomViewState extends State<_AddRoomView> {
  final TextEditingController _roomNameCtrl = TextEditingController();
  final TextEditingController _imeiCtrl = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _roomNameCtrl.dispose();
    _imeiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddRoomCubit, AddRoomState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status || prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.status == AddRoomStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.isNewRoomMode ? 'Thêm phòng thành công!' : 'Thêm thiết bị thành công!'),
              backgroundColor: AppColors.dashboardSuccess,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
          // Return the room name when popping so caller knows what was created
          context.pop(state.roomName);
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context, state),
          body: Padding(
            padding: EdgeInsets.all(1.w),
            child: LayoutBuilder(
              builder: (_, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.isNewRoomMode) ...[
                          const SectionLabel(label: 'Tên phòng mới'),
                          SizedBox(height: 12.h),
                          RoomNameInput(
                            controller: _roomNameCtrl,
                            onChanged: context.read<AddRoomCubit>().updateRoomName,
                          ),
                          SizedBox(height: 20.h),
                        ],

                        SectionLabel(label: 'Thêm thiết bị mới'),
                        if (state.isNewRoomMode) ...[
                          SizedBox(height: 4.h),
                          Text(
                            'Không bắt buộc — bạn có thể thêm thiết bị sau trong chi tiết phòng',
                            style: AppTextStyles.bodySmall(color: Colors.grey),
                          ),
                        ],
                        SizedBox(height: 12.h),

                        // Vùng quét QR
                        QrScanArea(onTap: () => _showScanOptions(context)),
                        SizedBox(height: 16.h),

                        // Ô nhập IMEI
                        ImeiInputField(
                          controller: _imeiCtrl,
                          onChanged: context.read<AddRoomCubit>().updateImeiInput,
                          errorText: state.validationError,
                        ),

                        // Banner xác nhận thiết bị
                        if (state.deviceCode != null) ...[
                          SizedBox(height: 12.h),
                          DeviceRecognizedBanner(
                            deviceCode: state.deviceCode!,
                            source: state.deviceSource,
                          ),
                        ],

                        SizedBox(height: 40.h),
                        ActivateButton(
                          title: state.isNewRoomMode ? 'Tạo phòng' : 'Thêm thiết bị',
                          isEnabled: state.canActivate,
                          isLoading: state.isSubmitting,
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            context.read<AddRoomCubit>().createRoom();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, AddRoomState state) {
    return AppBar(
      backgroundColor: AppColors.gradientEnd,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20.sp,
          color: Colors.white,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        state.isNewRoomMode ? 'Thêm phòng mới' : 'Thêm thiết bị',
        style: AppTextStyles.titleMediumAppBar(color: Colors.white),
      ),
    );
  }

  void _showScanOptions(BuildContext context) {
    final cubit = context.read<AddRoomCubit>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => ScanOptionSheet(
        onCamera: () async {
          Navigator.pop(sheetCtx);
          await Future.delayed(const Duration(milliseconds: 250));
          if (context.mounted) _openCameraScanner(context, cubit);
        },
        onGallery: () async {
          Navigator.pop(sheetCtx);
          await Future.delayed(const Duration(milliseconds: 250));
          if (context.mounted) _pickFromGallery(context, cubit);
        },
      ),
    );
  }

  Future<void> _openCameraScanner(BuildContext context, AddRoomCubit cubit) async {
    final status = await Permission.camera.request();
    if (!context.mounted) return;

    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cần cấp quyền camera để quét mã QR.'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          action: status.isPermanentlyDenied
              ? SnackBarAction(
                  label: 'Cài đặt',
                  textColor: Colors.white,
                  onPressed: () => openAppSettings(),
                )
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QrScannerSheet(onScanned: (raw) => cubit.handleScannedCode(raw)),
    );
  }

  Future<void> _pickFromGallery(BuildContext context, AddRoomCubit cubit) async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final result = await MobileScannerController().analyzeImage(image.path);
    if (!context.mounted) return;

    if (result != null && result.barcodes.isNotEmpty) {
      final raw = result.barcodes.first.rawValue;
      if (raw != null) {
        cubit.handleScannedCode(raw);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không tìm thấy mã QR trong ảnh. Vui lòng chọn ảnh khác.'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }
}
