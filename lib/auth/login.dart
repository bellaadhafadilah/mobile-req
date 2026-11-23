import 'package:flutter/material.dart';

import '../admin/dashboard/dashboard_komplain.dart';
import '../screens/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController unitController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    unitController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    // Simulasi proses autentikasi singkat
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat datang, ${unitController.text.trim()}!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.sizeOf(context).height - 180,
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      final isAdminLogin =
          unitController.text.trim() == 'test' &&
          passwordController.text == '123456789';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              isAdminLogin ? const AdminDashboardPage() : const HomePage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF071A3A), Color(0xFF0B3974), Color(0xFF1266A8)],
              ),
            ),
            child: SizedBox.expand(),
          ),
          Positioned(
            top: -110,
            right: -70,
            child: _backgroundOrb(size: 300, opacity: 0.08),
          ),
          Positioned(
            bottom: -150,
            left: -90,
            child: _backgroundOrb(size: 360, opacity: 0.07),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 960;
                final minimumHeight = constraints.maxHeight > 56
                    ? constraints.maxHeight - 56
                    : 0.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 40 : 20,
                    vertical: 28,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minimumHeight),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isWide ? 980 : 480,
                            ),
                            child: _buildLoginCard(
                              isWide: isWide,
                              compact: !isWide && constraints.maxHeight < 700,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'RSAB Harapan Kita  •  Sistem Layanan dan Monitoring IT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFD8E7F8),
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard({required bool isWide, required bool compact}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00132E).withValues(alpha: 0.24),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: isWide
          ? Row(
              children: [
                Expanded(flex: 5, child: _buildWelcomePanel()),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(44, 44, 44, 40),
                    child: _buildLoginForm(showLogo: false, compact: false),
                  ),
                ),
              ],
            )
          : Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                compact ? 18 : 30,
                24,
                compact ? 18 : 28,
              ),
              child: _buildLoginForm(showLogo: true, compact: compact),
            ),
    );
  }

  Widget _buildWelcomePanel() {
    return Container(
      constraints: const BoxConstraints(minHeight: 590),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D3B73), Color(0xFF087CB5)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -75,
            right: -75,
            child: _backgroundOrb(size: 220, opacity: 0.08),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _backgroundOrb(size: 250, opacity: 0.08),
          ),
          Padding(
            padding: const EdgeInsets.all(42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Image.asset(
                    'assets/icons/logo-fullname.png',
                    height: 42,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 44),
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Layanan IT, dalam satu portal.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Kelola permintaan dan pantau layanan teknologi informasi RSAB Harapan Kita dengan lebih mudah.',
                  style: TextStyle(
                    color: Color(0xFFD9EBF8),
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 30),
                const Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: Color(0xFFBDE8FF),
                      size: 18,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Akses internal yang aman dan terpusat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm({required bool showLogo, required bool compact}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            Center(
              child: Image.asset(
                'assets/icons/logo-fullname.png',
                height: compact ? 38 : 46,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: compact ? 18 : 30),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5FF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'PORTAL LAYANAN IT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF0879B5),
                fontSize: 10,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: compact ? 12 : 18),
          const Text(
            'Login Admin Permintaan IT',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: Color(0xFF172B4D),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: compact ? 6 : 8),
          const Text(
            'Silakan masukkan username dan password Anda',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: compact ? 18 : 30),
          buildLabel('Username'),
          TextFormField(
            controller: unitController,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText: 'Masukkan username',
              icon: Icons.person_outline_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username wajib diisi';
              }
              return null;
            },
          ),
          SizedBox(height: compact ? 14 : 20),
          buildLabel('Password'),
          TextFormField(
            controller: passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: _inputDecoration(
              hintText: 'Masukkan password',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? 'Tampilkan password'
                    : 'Sembunyikan password',
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    key: ValueKey(_obscurePassword),
                    color: const Color(0xFF718096),
                    size: 20,
                  ),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password wajib diisi';
              }
              return null;
            },
          ),
          SizedBox(height: compact ? 8 : 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 2,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: const Color(0xFF0879B5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ingat Saya',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF52627A),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Silakan hubungi administrator IT untuk reset password.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0879B5),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lupa Password?',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 16 : 26),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0879B5),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF8BBBD6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _isLoading
                    ? const Row(
                        key: ValueKey('loading'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Memproses...',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      )
                    : const Row(
                        key: ValueKey('login'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Masuk ke Akun',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ),
          SizedBox(height: compact ? 10 : 18),
          const Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: Color(0xFF8A98AB),
              ),
              Text(
                'Gunakan akun internal yang terdaftar',
                style: TextStyle(fontSize: 11, color: Color(0xFF8A98AB)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    const borderColor = Color(0xFFDCE4EF);
    const focusColor = Color(0xFF0879B5);
    final borderRadius = BorderRadius.circular(14);

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9AA8BA), fontSize: 13),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF5C83A8)),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: focusColor, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: Color(0xFFD64545)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: Color(0xFFD64545), width: 1.4),
      ),
    );
  }

  Widget _backgroundOrb({required double size, required double opacity}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF30415B),
        ),
      ),
    );
  }
}
