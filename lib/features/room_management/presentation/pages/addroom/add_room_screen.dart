/// AddRoomScreen — màn hình thêm phòng / thêm thiết bị
/// 3 mode:
///  - forceNewRoom  (existingRoomId=null, isFlexible=false) → tạo phòng + thiết bị tùy chọn
///  - lockedToRoom  (existingRoomId!=null, isFlexible=false) → chỉ thêm thiết bị vào phòng cố định
///  - flexible      (existingRoomId=null, isFlexible=true)  → chọn phòng từ picker hoặc không gán
library;

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
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/add_room/scan_option_sheet.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/qr_scanner_sheet.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/add_room/room_picker_sheet.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/room_selector_field.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/section_label.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/room_name_input.dart';

class AddRoomScreen extends StatelessWidget {
  final String? existingRoomId;

  /// true = mode flexible (điều hướng từ DeviceManagementScreen)
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
        // Thành công → pop về màn trước với result
        if (state.status == AddRoomStatus.success) {
          // Result đã được trả từ cubit.activate() — xử lý trong _onActivate
        }
        // Lỗi API → show snackbar
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
          context.read<AddRoomCubit>().clearError();
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
                  // Container luôn kéo dài ít nhất bằng toàn bộ chiều cao còn lại
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── forceNewRoom: ô nhập tên phòng ──
                        if (state.isNewRoomMode) ...[
                          const SectionLabel(label: 'Thêm phòng mới'),
                          SizedBox(height: 12.h),
                          RoomNameInput(
                            controller: _roomNameCtrl,
                            onChanged: context
                                .read<AddRoomCubit>()
                                .updateRoomName,
                          ),
                          SizedBox(height: 20.h),
                        ],

                        // ── flexible: ô chọn phòng từ picker ──
                        if (state.isFlexibleMode) ...[
                          const SectionLabel(label: 'Chọn phòng'),
                          SizedBox(height: 6.h),
                          Text(
                            'Tùy chọn — thiết bị có thể hoạt động mà không cần gán phòng',
                            style: AppTextStyles.bodySmall(color: Colors.grey),
                          ),
                          SizedBox(height: 10.h),
                          RoomSelectorField(
                            selectedRoomName: state.selectedRoomName,
                            onTap: () => _showRoomPicker(context),
                          ),
                          SizedBox(height: 10.h),
                          Divider(color: Colors.grey.shade200, height: 1),
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
                          onChanged: context
                              .read<AddRoomCubit>()
                              .updateImeiInput,
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
                        // ── Nút Kích hoạt ở cuối container ──
                        SizedBox(height: 20.h),
                        ActivateButton(
                          isEnabled: state.canActivate,
                          isLoading: state.isSubmitting,
                          onTap: () => _onActivate(context),
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
    final String title;
    if (state.isFlexibleMode) {
      title = 'Thêm thiết bị mới';
    } else if (state.isNewRoomMode) {
      title = 'Thêm phòng mới';
    } else {
      title = 'Thêm thiết bị';
    }
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
        title,
        style: AppTextStyles.titleMediumAppBar(color: Colors.white),
      ),
    );
  }

  // ── Action sheet chọn phương thức quét ──────────────────────────────────
  void _showScanOptions(BuildContext context) {
    final cubit = context.read<AddRoomCubit>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      // Dùng sheetCtx (context của sheet) để pop — tránh crash khi context cha detached
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

  // ── Camera scanner ───────────────────────────────────────────────────────
  Future<void> _openCameraScanner(
    BuildContext context,
    AddRoomCubit cubit,
  ) async {
    // Xin quyền camera trước khi mở scanner
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
      builder: (_) =>
          QrScannerSheet(onScanned: (raw) => cubit.handleScannedCode(raw)),
    );
  }

  // ── Image picker + QR decode ─────────────────────────────────────────────
  Future<void> _pickFromGallery(
    BuildContext context,
    AddRoomCubit cubit,
  ) async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    // Dùng mobile_scanner BarcodeCapture để decode từ file ảnh
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
          content: const Text(
            'Không tìm thấy mã QR trong ảnh. Vui lòng chọn ảnh khác.',
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  // ── Activate ─────────────────────────────────────────────────────────────
  Future<void> _onActivate(BuildContext context) async {
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    final cubit = context.read<AddRoomCubit>();
    final result = await cubit.activate();

    if (result != null && context.mounted) {
      context.pop(result); // Trả kết quả về màn trước
    }
  }

  // ── Room Picker (flexible mode) ───────────────────────────────────────────
  Future<void> _showRoomPicker(BuildContext context) async {
    final cubit = context.read<AddRoomCubit>();

    // Lazy-load phòng lần đầu bấm mở picker
    await cubit.loadAvailableRoomsIfNeeded();

    if (!context.mounted) return;

    final state = cubit.state;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoomPickerSheet(
        rooms: state.availableRooms,
        isLoading: state.isLoadingRooms,
        selectedRoomId: state.selectedRoomId,
        onSelected: (roomId, roomName) => cubit.selectRoom(roomId, roomName),
      ),
    );
  }
}
