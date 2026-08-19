import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/color_tokens.dart';
import '../../../theme/spacing_tokens.dart';
import '../../../shared_widgets/trime_logo.dart';
import '../../../shared_widgets/primary_button.dart';
import '../../../core/services/auth_service.dart';
import '../../app_scaffold.dart';

enum AuthMode { login, register }

class LoginPage extends StatefulWidget {
  final AuthService authService;

  const LoginPage({
    super.key,
    required this.authService,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Login fields
  final TextEditingController _identifierController = TextEditingController(); // phone or username

  // Register fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Shared
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = false;
  final TextEditingController _confirmPasswordController = TextEditingController();

  AuthMode _mode = AuthMode.login;
  UserRole _selectedRole = UserRole.pelanggan;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    setState(() {
      _mode = mode;
      _errorMessage = null;
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
    _animController
      ..reset()
      ..forward();
  }

  // ─── GOOGLE SIGN-IN ───
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await widget.authService.signInWithGoogle(role: _selectedRole);
      if (user != null && mounted) {
        _navigateToHome(user.name);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Gagal login Google. Pastikan internet tersambung.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── CREDENTIAL LOGIN ───
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final identifier = _identifierController.text.trim();
      final password = _passwordController.text;
      final user = await widget.authService.loginWithCredentials(
        identifier: identifier,
        password: password,
        role: _selectedRole,
      );
      if (!mounted) return;
      if (user != null) {
        _navigateToHome(user.name);
      } else {
        setState(() => _errorMessage = 'No. HP/Username atau password salah. Periksa kembali dan coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── CREDENTIAL REGISTER ───
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Konfirmasi password tidak cocok.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final phone = _phoneController.text.trim();
      final normalizedPhone = phone.startsWith('0')
          ? '62${phone.substring(1)}'
          : phone.replaceAll(RegExp(r'\D'), '');

      final user = await widget.authService.registerWithCredentials(
        name: _nameController.text.trim(),
        phone: normalizedPhone,
        password: _passwordController.text,
        role: _selectedRole,
      );
      if (!mounted) return;
      if (user != null) {
        _navigateToHome(user.name);
      } else {
        setState(() => _errorMessage = 'Nomor HP ini sudah terdaftar. Coba login atau gunakan nomor lain.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: TrimeColors.successGreen,
        content: Text('Selamat datang, $name! 👋'),
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppScaffold()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrimeColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── HEADER ──
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: TrimeSpacing.xl,
                  vertical: TrimeSpacing.xxl,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [TrimeColors.primaryNavy, TrimeColors.secondaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Colors.white70],
                      ).createShader(bounds),
                      child: const TrimeLogo(size: TrimeLogoSize.large),
                    ),
                    const SizedBox(height: TrimeSpacing.lg),
                    Text(
                      _mode == AuthMode.login
                          ? 'Selamat Datang Kembali!'
                          : 'Gabung Bersama TRIME',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: TrimeSpacing.xs),
                    Text(
                      _mode == AuthMode.login
                          ? 'Masuk menggunakan No. HP atau Username'
                          : 'Daftarkan akun dan temukan kapster terbaik',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── FORM ──
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TrimeSpacing.xl,
                    TrimeSpacing.xl,
                    TrimeSpacing.xl,
                    TrimeSpacing.xl * 2,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Mode toggle
                        _buildModeToggle(),
                        const SizedBox(height: TrimeSpacing.xl),

                        // Role selector
                        _buildRoleSelector(),
                        const SizedBox(height: TrimeSpacing.lg),

                        // Error message
                        if (_errorMessage != null) ...[
                          _buildErrorBanner(),
                          const SizedBox(height: TrimeSpacing.md),
                        ],

                        // ── LOGIN FIELDS ──
                        if (_mode == AuthMode.login) ...[
                          _buildLabel('No. HP atau Username'),
                          const SizedBox(height: TrimeSpacing.xs),
                          TextFormField(
                            controller: _identifierController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'Contoh: 08123456789',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                              return null;
                            },
                          ),
                          const SizedBox(height: TrimeSpacing.md),
                          _buildLabel('Password'),
                          const SizedBox(height: TrimeSpacing.xs),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Masukkan password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password wajib diisi';
                              if (v.length < 6) return 'Password minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: TrimeSpacing.lg),
                          PrimaryButton(
                            label: 'Masuk',
                            prefixIcon: Icons.login_rounded,
                            onPressed: _isLoading ? null : _handleLogin,
                            isLoading: _isLoading,
                          ),
                        ],

                        // ── REGISTER FIELDS ──
                        if (_mode == AuthMode.register) ...[
                          _buildLabel('Nama Lengkap'),
                          const SizedBox(height: TrimeSpacing.xs),
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            keyboardType: TextInputType.name,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan nama lengkapmu',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
                              if (v.trim().length < 3) return 'Nama minimal 3 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: TrimeSpacing.md),
                          _buildLabel('Nomor WhatsApp'),
                          const SizedBox(height: TrimeSpacing.xs),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: '08xx xxxx xxxx',
                              prefixIcon: const Icon(Icons.phone_android_rounded),
                              prefix: Padding(
                                padding: const EdgeInsets.only(right: TrimeSpacing.xs),
                                child: Text(
                                  '+62',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'No. HP wajib diisi';
                              final digits = v.replaceAll(RegExp(r'\D'), '');
                              if (digits.length < 9) return 'No. HP tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: TrimeSpacing.md),
                          _buildLabel('Password'),
                          const SizedBox(height: TrimeSpacing.xs),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Minimal 6 karakter',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password wajib diisi';
                              if (v.length < 6) return 'Password minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: TrimeSpacing.md),
                          _buildLabel('Konfirmasi Password'),
                          const SizedBox(height: TrimeSpacing.xs),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            decoration: InputDecoration(
                              hintText: 'Ulangi password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                              if (v != _passwordController.text) return 'Password tidak cocok';
                              return null;
                            },
                          ),
                          const SizedBox(height: TrimeSpacing.lg),
                          PrimaryButton(
                            label: 'Daftar Akun Baru',
                            prefixIcon: Icons.person_add_alt_1_rounded,
                            onPressed: _isLoading ? null : _handleRegister,
                            isLoading: _isLoading,
                          ),
                        ],

                        // ── DIVIDER ATAU ──
                        const SizedBox(height: TrimeSpacing.md),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'atau',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: TrimeColors.textMuted,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: TrimeSpacing.md),

                        // ── GOOGLE BUTTON ──
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: TrimeSpacing.radiusMd,
                            ),
                            side: const BorderSide(color: TrimeColors.surfaceAlt),
                          ),
                          icon: const Icon(
                            Icons.g_mobiledata_rounded,
                            size: 32,
                            color: TrimeColors.primaryNavy,
                          ),
                          label: Text(
                            _mode == AuthMode.login
                                ? 'Masuk dengan Google'
                                : 'Daftar dengan Google',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: TrimeColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: TrimeSpacing.lg),

                        // ── FOOTER ──
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: TrimeColors.textPrimary,
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(TrimeSpacing.md),
      decoration: BoxDecoration(
        color: TrimeColors.dangerRed.withValues(alpha: 0.08),
        borderRadius: TrimeSpacing.radiusMd,
        border: Border.all(color: TrimeColors.dangerRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: TrimeColors.dangerRed, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: TrimeColors.dangerRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TrimeColors.surfaceAlt,
        borderRadius: TrimeSpacing.radiusPill,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleTab(
              title: 'Masuk',
              isSelected: _mode == AuthMode.login,
              onTap: () => _switchMode(AuthMode.login),
            ),
          ),
          Expanded(
            child: _buildToggleTab(
              title: 'Daftar',
              isSelected: _mode == AuthMode.register,
              onTap: () => _switchMode(AuthMode.register),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: TrimeSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? TrimeColors.primaryNavy : Colors.transparent,
          borderRadius: TrimeSpacing.radiusPill,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : TrimeColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _mode == AuthMode.login ? 'Masuk sebagai' : 'Daftar sebagai',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: TrimeColors.textPrimary,
          ),
        ),
        const SizedBox(height: TrimeSpacing.xs),
        Row(
          children: [
            Expanded(
              child: _buildRoleCard(
                role: UserRole.pelanggan,
                title: 'Pelanggan',
                subtitle: 'Booking potong rambut',
                icon: Icons.person,
              ),
            ),
            const SizedBox(width: TrimeSpacing.sm),
            Expanded(
              child: _buildRoleCard(
                role: UserRole.mitra,
                title: 'Mitra',
                subtitle: 'Pemilik Barbershop',
                icon: Icons.store,
              ),
            ),
            const SizedBox(width: TrimeSpacing.sm),
            Expanded(
              child: _buildRoleCard(
                role: UserRole.kapster,
                title: 'Kapster',
                subtitle: 'Pekerja cukur',
                icon: Icons.content_cut,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: TrimeSpacing.md,
          horizontal: TrimeSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? TrimeColors.primaryNavy.withValues(alpha: 0.08)
              : TrimeColors.surfaceAlt,
          borderRadius: TrimeSpacing.radiusMd,
          border: Border.all(
            color: selected ? TrimeColors.primaryNavy : TrimeColors.surfaceAlt,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? TrimeColors.primaryNavy : TrimeColors.textMuted,
              size: 26,
            ),
            const SizedBox(height: TrimeSpacing.xs),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? TrimeColors.primaryNavy : TrimeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: TrimeColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text.rich(
        TextSpan(
          text: _mode == AuthMode.login
              ? 'Belum punya akun? '
              : 'Sudah punya akun? ',
          style: GoogleFonts.poppins(
            color: TrimeColors.textSecondary,
            fontSize: 13,
          ),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () => _switchMode(
                  _mode == AuthMode.login ? AuthMode.register : AuthMode.login,
                ),
                child: Text(
                  _mode == AuthMode.login ? 'Daftar Sekarang' : 'Masuk',
                  style: GoogleFonts.poppins(
                    color: TrimeColors.primaryNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
