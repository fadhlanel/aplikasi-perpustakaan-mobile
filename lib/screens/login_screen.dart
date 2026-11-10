import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import 'main_navigation.dart';

/// Screen 2: Login Screen
/// Sesuai 100% dengan Mockup Desain Figma (Foto 1)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nisController = TextEditingController(text: AppConstants.defaultNis);
  final _pinController = TextEditingController(text: AppConstants.defaultPin);

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nisController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();

    final success = await auth.login(
      nis: _nisController.text,
      pin: _pinController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NIS atau PIN salah. Silakan coba lagi.'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Top Section
            Stack(
              children: [
                // Background Image / Gradient Room
                Container(
                  height: size.height * 0.36,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFF1E3A8A),
                        Color(0xFF0F172A),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Atmospheric subtle shapes
                      Positioned(
                        right: -40,
                        top: -20,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: 0,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.cyanAccent.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      // Dark gradient overlay for text readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hero Content
                Positioned.fill(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F766E).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.menu_book_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'PustakaDigital SMK Negeri 1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Selamat Datang Kembali!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Akses ribuan buku bacaan, jurnal pelajaran, dan riwayat pinjamanmu.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13.5,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Form Sheet
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    const Center(
                      child: Text(
                        'Login atau Daftar!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Active Tab Indicator Pill
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.softBlueBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.badge_rounded,
                            color: AppTheme.primaryNavy,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Masuk dengan NIS atau Nomor Anggota',
                              style: TextStyle(
                                color: AppTheme.primaryNavy,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input 1: NIS / ID Anggota
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'NIS / ID Anggota',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Contoh: 202410882',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nisController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan NIS / Email Siswa',
                        prefixIcon: const Icon(
                          Icons.perm_identity_rounded,
                          color: AppTheme.textMuted,
                        ),
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'NIS wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Input 2: Password / PIN
                    const Text(
                      'Password / PIN Perpustakaan',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pinController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '6 digit PIN atau password',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppTheme.textMuted,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textMuted,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Password / PIN wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Checkbox & Forgot PIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppTheme.primaryNavy,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (v) => setState(() => _rememberMe = v ?? true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Ingat Saya',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Silakan hubungi pustakawan sekolah untuk reset PIN.'),
                              ),
                            );
                          },
                          child: const Text(
                            'Lupa PIN / Butuh Bantuan?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login_rounded, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
