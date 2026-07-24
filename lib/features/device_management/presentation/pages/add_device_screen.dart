import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';
import 'package:thermo_humi/features/device_management/presentation/bloc/add_device/add_device_cubit.dart';
import 'package:thermo_humi/core/di/injection_container.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/add_room/qr_scanner_sheet.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/add_room/scan_option_sheet.dart';
import 'package:thermo_humi/features/room_management/presentation/pages/addroom/widgets/add_room/qr_scan_area.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final TextEditingController _imeiCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _imeiCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AddDeviceCubit>().submitDevice(
        imei: _imeiCtrl.text.trim(),
        deviceName: _nameCtrl.text.trim(),
      );
    }
  }

  // ── Action sheet chọn phương thức quét ──────────────────────────────────
  void _showScanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => ScanOptionSheet(
        onCamera: () async {
          Navigator.pop(sheetCtx);
          await Future.delayed(const Duration(milliseconds: 250));
          if (context.mounted) _openCameraScanner(context);
        },
        onGallery: () async {
          Navigator.pop(sheetCtx);
          await Future.delayed(const Duration(milliseconds: 250));
          if (context.mounted) _pickFromGallery(context);
        },
      ),
    );
  }

  // ── Camera scanner ───────────────────────────────────────────────────────
  Future<void> _openCameraScanner(BuildContext context) async {
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
      builder: (_) => QrScannerSheet(
        onScanned: (raw) => setState(() => _imeiCtrl.text = raw),
      ),
    );
  }

  // ── Image picker + QR decode ─────────────────────────────────────────────
  Future<void> _pickFromGallery(BuildContext context) async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final result = await MobileScannerController().analyzeImage(image.path);
    if (!context.mounted) return;

    if (result != null && result.barcodes.isNotEmpty) {
      final raw = result.barcodes.first.rawValue;
      if (raw != null) {
        setState(() => _imeiCtrl.text = raw);
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddDeviceCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.gradientEnd,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Thêm thiết bị mới',
            style: AppTextStyles.titleMediumAppBar(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 22.sp),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<AddDeviceCubit, AddDeviceState>(
          listener: (context, state) {
            if (state.status == AddDeviceStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thêm thiết bị thành công!')),
              );
              context.pop(true); // Trả về true để refresh danh sách
            } else if (state.status == AddDeviceStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Đã có lỗi xảy ra'),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state.status == AddDeviceStatus.loading;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 24.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tên thiết bị', style: AppTextStyles.bodyMedium()),
                        SizedBox(height: 8.h),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            hintText: 'Nhập tên thiết bị (VD: Thiết bị 1)',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng nhập tên thiết bị';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24.h),
                        QrScanArea(onTap: () => _showScanOptions(context)),
                        SizedBox(height: 24.h),
                        Text('Mã IMEI', style: AppTextStyles.bodyMedium()),
                        SizedBox(height: 8.h),
                        TextFormField(
                          controller: _imeiCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Nhập mã IMEI',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng nhập mã IMEI';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 40.h),
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _submit(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Thêm thiết bị',
                              style: AppTextStyles.titleMedium(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
