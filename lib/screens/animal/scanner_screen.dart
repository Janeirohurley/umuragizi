import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/animal_provider.dart';
import '../../utils/app_theme.dart';
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
      final code = barcodes.first.rawValue!;
      _processScannedCode(code);
    }
  }

  void _processScannedCode(String scannedCode) {
    setState(() => _isProcessing = true);
    
    final animalProvider = context.read<AnimalProvider>();
    final animaux = animalProvider.animaux;
    
    try {
      final foundAnimal = animaux.firstWhere((a) => a.identifiant == scannedCode);
      
      // Animal trouvé ! On arrête le scan et on va à l'écran de détail
      _controller.stop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AnimalDetailScreen(animalId: foundAnimal.id),
        ),
      );
    } catch (e) {
      // Non trouvé
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Aucun animal trouvé avec l'identifiant: $scannedCode", style: const TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      
      // Permettre de scanner à nouveau après un délai
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scanner le QR Code', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Interface de visée visuelle
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
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Pointez vers le QR Code ou Tagger',
                style: TextStyle(
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
