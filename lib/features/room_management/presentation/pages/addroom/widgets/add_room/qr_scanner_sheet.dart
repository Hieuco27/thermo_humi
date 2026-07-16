/// QrScannerSheet — modal bottom sheet chứa MobileScannerController
/// Controller được dispose tự động khi sheet đóng qua lifecycle Flutter.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:thermo_humi/core/theme/app_colors.dart';
import 'package:thermo_humi/core/theme/text_styles.dart';

class QrScannerSheet extends StatefulWidget {
  /// Callback nhận raw QR string sau khi quét thành công
  final ValueChanged<String> onScanned;

  const QrScannerSheet({super.key, required this.onScanned});

  @override
  State<QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<QrScannerSheet> {
  late final MobileScannerController _controller;
  bool _isProcessing = false; // Lock: tránh xử lý QR trùng lặp

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Giải phóng camera ngay khi sheet đóng
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return; // Bỏ qua nếu đang xử lý
    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue;
    if (raw == null || raw.isEmpty) return;

    _isProcessing = true;
    _controller.stop(); // Dừng camera stream ngay lập tức

    widget.onScanned(raw);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),

          // Title
          Text(
            'Quét mã QR thiết bị',
            style: AppTextStyles.titleMedium(color: Colors.white),
          ),
          SizedBox(height: 16.h),

          // Scanner
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Lỗi Camera:\n$error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
              placeholderBuilder: (context, child) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
              overlayBuilder: (context, constraints) =>
                  _ScanOverlay(constraints: constraints),
            ),
          ),

          // Close button
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Đóng',
                  style: AppTextStyles.bodyMedium(color: Colors.white70),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlay khung ngắm QR
class _ScanOverlay extends StatelessWidget {
  final BoxConstraints constraints;

  const _ScanOverlay({required this.constraints});

  @override
  Widget build(BuildContext context) {
    final size = constraints.biggest;
    final boxSize = size.width * 0.65;
    final left = (size.width - boxSize) / 2;
    final top = (size.height - boxSize) / 2;

    return Stack(
      children: [
        // Dark overlay with transparent hole using CustomPaint (safer for Android Impeller)
        Positioned.fill(
          child: CustomPaint(painter: _OverlayPainter(holeSize: boxSize)),
        ),
        // Corner decorators
        Positioned(
          left: left,
          top: top,
          child: _CornerFrame(size: boxSize),
        ),
      ],
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double holeSize;

  _OverlayPainter({required this.holeSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    // Toàn bộ màn hình
    final backgroundRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Vùng đục lỗ ở giữa
    final left = (size.width - holeSize) / 2;
    final top = (size.height - holeSize) / 2;
    final holeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, holeSize, holeSize),
      Radius.circular(12.r), // Bo góc giống design cũ
    );

    // Dùng path difference để đục lỗ
    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(backgroundRect),
      Path()..addRRect(holeRect),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return oldDelegate.holeSize != holeSize;
  }
}

class _CornerFrame extends StatelessWidget {
  final double size;
  const _CornerFrame({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CornerPainter()),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 24.0;
    const r = 8.0;
    final w = size.width;
    final h = size.height;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: const Radius.circular(r))
        ..lineTo(len, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(w - len, 0)
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: const Radius.circular(r))
        ..lineTo(w, len),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, h - len)
        ..lineTo(0, h - r)
        ..arcToPoint(Offset(r, h), radius: const Radius.circular(r))
        ..lineTo(len, h),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(w - len, h)
        ..lineTo(w - r, h)
        ..arcToPoint(Offset(w, h - r), radius: const Radius.circular(r))
        ..lineTo(w, h - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
