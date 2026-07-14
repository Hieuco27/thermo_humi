/// AddRoomScreen — màn hình thêm phòng / thêm thiết bị
/// Nhận [existingRoomId]:
///  - null     → Chế độ tạo phòng mới + gán thiết bị đầu tiên
///  - có giá trị → Chế độ chỉ thêm thiết bị vào phòng đó
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
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/activate_button.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/device_recognized_banner.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/imei_input_field.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/qr_scan_area.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/qr_scanner_sheet.dart';

class AddRoomScreen extends StatelessWidget {
  final String? existingRoomId;

  const AddRoomScreen({super.key, this.existingRoomId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddRoomCubit(
        repository: sl<RoomRepository>(),
        existingRoomId: existingRoomId,
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
          backgroundColor: const Color(0xFFF5F5F7),
          appBar: _buildAppBar(context, state),
          body: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
            child: LayoutBuilder(
              builder: (_, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  // Container luôn kéo dài ít nhất bằng toàn bộ chiều cao còn lại
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Khối tạo phòng mới (ẩn khi existingRoomId != null) ──
                        if (state.isNewRoomMode) ...[
                          _SectionLabel(label: 'Thêm phòng mới'),
                          SizedBox(height: 12.h),
                          _RoomNameInput(
                            controller: _roomNameCtrl,
                            onChanged: context
                                .read<AddRoomCubit>()
                                .updateRoomName,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Ví dụ: Phòng khách, Phòng ngủ, Nhà bếp...',
                            style: AppTextStyles.bodySmall(
                              color: Colors.grey.shade400,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Divider(color: Colors.grey.shade200, height: 1),
                          SizedBox(height: 20.h),
                        ],

                        // ── Khối thêm thiết bị mới (luôn hiển thị) ──
                        _SectionLabel(label: 'Thêm thiết bị mới'),
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
    final title = state.isNewRoomMode ? 'Thêm phòng mới' : 'Thêm thiết bị';
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
      builder: (sheetCtx) => _ScanOptionSheet(
        onCamera: () async {
          Navigator.pop(sheetCtx); // ✅ dùng context của sheet
          await Future.delayed(const Duration(milliseconds: 250));
          if (context.mounted) _openCameraScanner(context, cubit);
        },
        onGallery: () async {
          Navigator.pop(sheetCtx); // ✅ dùng context của sheet
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
}

// ── Bottom Bar ─────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final AddRoomState state;
  final VoidCallback onActivate;

  const _BottomBar({required this.state, required this.onActivate});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        MediaQuery.viewPaddingOf(
          context,
        ).bottom, // Chỉ lấy viền màn hình (notch), không bị đẩy bởi bàn phím
      ),
      child: ActivateButton(
        isEnabled: state.canActivate,
        isLoading: state.isSubmitting,
        onTap: onActivate,
      ),
    );
  }
}

// ── Section Label ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelLarge().copyWith(fontWeight: FontWeight.w600),
    );
  }
}

// ── Room Name Input ────────────────────────────────────────────────────────
class _RoomNameInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _RoomNameInput({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.sentences,
      style: AppTextStyles.label13(),
      decoration: InputDecoration(
        hintText: 'Tên phòng',
        isDense: true,
        constraints: BoxConstraints(minHeight: 44.h, maxHeight: 44.h),
        prefixIconConstraints: BoxConstraints(minWidth: 40.w, minHeight: 20.w),
        hintStyle: AppTextStyles.label13(color: Colors.grey.shade400),
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Icon(
            Icons.meeting_room_outlined,
            color: Colors.grey.shade400,
            size: 20.sp,
          ),
        ),
        suffixIcon: controller.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  controller.clear();
                  onChanged('');
                },

                child: Icon(
                  Icons.close_rounded,
                  size: 14.sp,
                  color: Colors.grey.shade600,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
    );
  }
}

// ── Scan Option Sheet ──────────────────────────────────────────────────────
class _ScanOptionSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _ScanOptionSheet({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chọn phương thức quét QR',
                  style: AppTextStyles.titleMedium(color: Colors.black87),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            ListTile(
              leading: Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.primary,
                size: 22.sp,
              ),
              title: Text(
                'Quét bằng camera',
                style: AppTextStyles.bodyMedium(color: Colors.black87),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
              onTap: onCamera,
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
                size: 22.sp,
              ),
              title: Text(
                'Chọn ảnh từ thư viện',
                style: AppTextStyles.bodyMedium(color: Colors.black87),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
              onTap: onGallery,
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
