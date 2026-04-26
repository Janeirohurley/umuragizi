import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/animal_provider.dart';
import '../../utils/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'animal_detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      _processScannedCode(barcodes.first.rawValue!);
    }
  }

  void _processScannedCode(String scannedCode) {
    setState(() => _isProcessing = true);

    final l10n = AppLocalizations.of(context)!;
    final animalProvider = context.read<AnimalProvider>();

    try {
      final foundAnimal = animalProvider.animaux.firstWhere((a) => a.identifiant == scannedCode);
      _controller.stop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AnimalDetailScreen(animalId: foundAnimal.id),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.animalNotFound}: $scannedCode', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.errorRed,
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isProcessing = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.scanQrCode, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryPurple, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple))
                  : null,
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                l10n.scanHint,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
