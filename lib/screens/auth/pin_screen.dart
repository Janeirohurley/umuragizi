import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../utils/app_theme.dart';
import '../dashboard_screen.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;

  const PinScreen({super.key, this.isSetup = false});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with SingleTickerProviderStateMixin {
  static const String _pinBoxName = 'pin_settings';
  static const String _pinKey = 'user_pin';

  String _enteredPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _hasError = false;
  String _errorMessage = '';

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<String?> _getSavedPin() async {
    final box = await Hive.openBox(_pinBoxName);
    return box.get(_pinKey);
  }

  Future<void> _savePin(String pin) async {
    final box = await Hive.openBox(_pinBoxName);
    await box.put(_pinKey, pin);
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 6) {
      HapticFeedback.lightImpact();
      setState(() {
        _enteredPin += number;
        _hasError = false;
        _errorMessage = '';
      });

      if (_enteredPin.length == 6) {
        _validatePin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _hasError = false;
        _errorMessage = '';
      });
    }
  }

  Future<void> _validatePin() async {
    if (widget.isSetup) {
      if (!_isConfirming) {
        setState(() {
          _confirmPin = _enteredPin;
          _enteredPin = '';
          _isConfirming = true;
        });
      } else {
        if (_enteredPin == _confirmPin) {
          await _savePin(_enteredPin);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
        } else {
          _showError('Les codes PIN ne correspondent pas');
          setState(() {
            _enteredPin = '';
            _confirmPin = '';
            _isConfirming = false;
          });
        }
      }
    } else {
      final savedPin = await _getSavedPin();
      if (_enteredPin == savedPin) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        _showError('Code PIN incorrect');
        setState(() {
          _enteredPin = '';
        });
      }
    }
  }

  void _showError(String message) {
    HapticFeedback.heavyImpact();
    _shakeController.forward().then((_) => _shakeController.reset());
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColorOf(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXXLarge),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildHeader(),
              const SizedBox(height: AppTheme.spacingXXLarge),
              _buildPinIndicators(),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingMedium),
                _buildErrorMessage(),
              ],
              const Spacer(flex: 1),
              _buildKeypad(),
              const SizedBox(height: AppTheme.spacingXXLarge),
              if (widget.isSetup) _buildSkipButton(),
              const SizedBox(height: AppTheme.spacingXLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                blurRadius: AppTheme.spacingLarge,
                offset: const Offset(0, AppTheme.spacingMedium),
              ),
            ],
          ),
          child: Icon(
            Icons.lock_outline_rounded,
            color: Colors.white,
            size: AppTheme.iconSizeMedium,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXLarge),
        Text(
          widget.isSetup
              ? (_isConfirming ? 'Confirmez votre PIN' : 'Créez votre PIN')
              : 'Entrez votre PIN',
          style: AppTheme.cardTitle.copyWith(
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Text(
          widget.isSetup
              ? (_isConfirming
                  ? 'Entrez à nouveau votre code PIN'
                  : 'Choisissez un code PIN à 6 chiffres')
              : 'Entrez votre code PIN pour accéder à l\'application',
          textAlign: TextAlign.center,
          style: AppTheme.bodyTextSecondary.copyWith(
            color: AppTheme.textSecondaryOf(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPinIndicators() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = _hasError ? (1 - _shakeAnimation.value) * 10 *
            ((_shakeAnimation.value * 10).floor() % 2 == 0 ? 1 : -1) : 0.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (index) {
          final isFilled = index < _enteredPin.length;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall),
            width: AppTheme.spacingMedium,
            height: AppTheme.spacingMedium,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              color: _hasError
                  ? AppTheme.errorRed
                  : (isFilled ? AppTheme.primaryPurple : Colors.transparent),
              border: Border.all(
                color: _hasError
                    ? AppTheme.errorRed
                    : (isFilled ? AppTheme.primaryPurple : AppTheme.textLightOf(context)),
                width: 2,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingSmall),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorRed,
            size: AppTheme.iconSizeSmall,
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          Text(
            _errorMessage,
            style: AppTheme.errorText,
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('1'),
            _buildKeypadButton('2'),
            _buildKeypadButton('3'),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('4'),
            _buildKeypadButton('5'),
            _buildKeypadButton('6'),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('7'),
            _buildKeypadButton('8'),
            _buildKeypadButton('9'),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: AppTheme.iconSizeXLarge, height: AppTheme.iconSizeXLarge),
            _buildKeypadButton('0'),
            _buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNumberPressed(number),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundOf(context),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.softShadow,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTheme.bodyText.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: AppTheme.textPrimaryOf(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onDeletePressed,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              size: AppTheme.iconSizeMedium,
              color: AppTheme.textSecondaryOf(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      },
      child: Text(
        'Passer pour l\'instant',
        style: AppTheme.buttonTextSecondary.copyWith(
          color: AppTheme.textSecondaryOf(context),
        ),
      ),
    );
  }
}