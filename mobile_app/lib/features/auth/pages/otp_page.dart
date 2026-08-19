import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../../theme/color_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../shared_widgets/primary_button.dart';
import '../../../core/services/auth_service.dart';
import '../../app_scaffold.dart';

class OtpPage extends StatefulWidget {
  final AuthService authService;
  final String phoneNumber;
  final bool isRegister;
  final String? name;
  final UserRole role;

  const OtpPage({
    super.key,
    required this.authService,
    required this.phoneNumber,
    required this.isRegister,
    this.name,
    this.role = UserRole.pelanggan,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 30;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _resendCountdown = 30;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendCountdown--;
      });
      return _resendCountdown > 0;
    });
  }

  String get _formattedPhone {
    final phone = widget.phoneNumber;
    if (phone.startsWith('62')) {
      return '0${phone.substring(2)}';
    }
    return phone;
  }

  Future<void> _verifyOtp() async {
    if (_pinController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan 6 digit kode OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await widget.authService.verifyOtp(
        phoneNumber: widget.phoneNumber,
        otp: _pinController.text,
        isRegister: widget.isRegister,
        name: widget.name,
        role: widget.role,
      );

      if (!mounted) return;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: TrimeColors.successGreen,
            content: Text('${widget.isRegister ? 'Pendaftaran' : 'Login'} berhasil! Selamat datang, ${user.name}'),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppScaffold()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: TrimeColors.dangerRed,
            content: Text('Kode OTP salah. Coba lagi (hint: 123456)'),
          ),
        );
        _pinController.clear();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);
    try {
      await widget.authService.requestOtp(
        phoneNumber: widget.phoneNumber,
        isRegister: widget.isRegister,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP dikirim ulang')),
      );
      _startCountdown();
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: TrimeColors.primaryNavy,
      ),
      decoration: BoxDecoration(
        color: TrimeColors.surfaceAlt,
        borderRadius: TrimeSpacing.radiusMd,
        border: Border.all(color: Colors.transparent, width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: TrimeColors.secondaryBlue, width: 1.5),
      color: TrimeColors.surface,
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: TrimeColors.primaryNavy.withValues(alpha: 0.08),
        border: Border.all(color: TrimeColors.primaryNavy, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: TrimeColors.background,
      appBar: AppBar(
        backgroundColor: TrimeColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TrimeSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: TrimeSpacing.lg),
              Text(
                'Verifikasi Kode',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: TrimeColors.textPrimary,
                ),
              ),
              const SizedBox(height: TrimeSpacing.xs),
              Text.rich(
                TextSpan(
                  text: 'Kami mengirimkan 6 digit kode OTP ke WhatsApp ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: TrimeColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(
                      text: _formattedPhone,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: TrimeColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TrimeSpacing.xxl),
              Center(
                child: Pinput(
                  controller: _pinController,
                  length: 6,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  onCompleted: (_) => _verifyOtp(),
                ),
              ),
              const SizedBox(height: TrimeSpacing.xl),
              PrimaryButton(
                label: 'Verifikasi Kode',
                prefixIcon: Icons.verified_user_outlined,
                onPressed: _isLoading ? null : _verifyOtp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: TrimeSpacing.lg),
              Center(
                child: _resendCountdown > 0
                    ? Text(
                        'Kirim ulang kode dalam $_resendCountdown detik',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: TrimeColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : GestureDetector(
                        onTap: _isResending ? null : _resendOtp,
                        child: _isResending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Kirim Ulang Kode OTP',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: TrimeColors.primaryNavy,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(TrimeSpacing.md),
                decoration: BoxDecoration(
                  color: TrimeColors.secondaryBlue.withValues(alpha: 0.08),
                  borderRadius: TrimeSpacing.radiusMd,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: TrimeColors.secondaryBlue,
                      size: 18,
                    ),
                    const SizedBox(width: TrimeSpacing.sm),
                    Expanded(
                      child: Text(
                        'Kode OTP demo: 123456',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: TrimeColors.secondaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TrimeSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
