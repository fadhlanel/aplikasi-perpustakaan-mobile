import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/book_cover_widget.dart';
import 'login_screen.dart';

/// Screen 6: Profil Siswa Screen
/// Sesuai 100% dengan Mockup Desain Figma (Foto 5)
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  void _handleLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.dangerRed),
            SizedBox(width: 8),
            Text('Keluar Akun?'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun perpustakaan ini?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header PUSTAKADIGITAL - Profil Siswa
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.softBlueBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppTheme.primaryBlue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PUSTAKADIGITAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          Text(
                            'Profil Siswa',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined, size: 24),
                        color: AppTheme.primaryNavy,
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryNavy,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Student Profile Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.softBlueBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDCEBFA)),
                ),
                child: Row(
                  children: [
                    // Avatar with verified badge
                    Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 10, color: Color(0xFF047857)),
                                SizedBox(width: 4),
                                Text(
                                  'ANGGOTA TERVERIFIKASI',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            profile.nama,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'NIS: ${profile.nis} • ${profile.kelas}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.school_outlined, size: 13, color: AppTheme.primaryNavy),
                              const SizedBox(width: 4),
                              Text(
                                profile.sekolah,
                                style: const TextStyle(fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded, size: 11, color: AppTheme.accentBlue),
                                    SizedBox(width: 2),
                                    Text(
                                      'Peminjam Teladan',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.accentBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3 Stat Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.menu_book_rounded,
                      value: '${profile.bukuDibacaCount}',
                      label: 'Buku Pernah\nDibaca',
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: AppTheme.accentBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.calendar_month_rounded,
                      value: '${profile.bukuAktifCount}',
                      label: 'Buku Sedang\nAktif',
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: AppTheme.mintGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.shield_outlined,
                      value: '${profile.dendaCount}',
                      label: 'Denda &\nSanksi',
                      iconBg: const Color(0xFFF8FAFC),
                      iconColor: AppTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Active Loan Reminder Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEF2F6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const BookCoverWidget(
                      judul: 'Clean Code & Architecture',
                      penulis: 'Robert C. Martin',
                      width: 44,
                      height: 60,
                      borderRadius: 6,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppTheme.mintGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Tenggat 3 Hari Lagi',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Clean Code & Architecture',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Kembalikan s.d. 28 Okt 2024',
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppTheme.softBlueBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppTheme.accentBlue,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Section: AKTIVITAS & PREFERENSI
              const Text(
                'AKTIVITAS & PREFERENSI',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEF2F6)),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.bookmark_outline_rounded,
                      title: 'Buku Favorit & Bookmark',
                      subtitle: '8 judul tersimpan di koleksi',
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: AppTheme.accentBlue,
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildMenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifikasi Pengingat Pengembalian',
                      subtitle: 'H-3 sebelum jatuh tempo buku',
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: AppTheme.accentBlue,
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildMenuItem(
                      icon: Icons.qr_code_scanner_rounded,
                      title: 'Riwayat Kunjungan Perpustakaan',
                      subtitle: 'Presensi fisik & baca di tempat',
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: AppTheme.accentBlue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section: PUSAT BANTUAN & PENGATURAN
              const Text(
                'PUSAT BANTUAN & PENGATURAN',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEF2F6)),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.tune_rounded,
                      title: 'Pengaturan Tema & Akun',
                      subtitle: 'Keamanan sandi, profil, preferensi',
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: AppTheme.accentBlue,
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildMenuItem(
                      icon: Icons.menu_book_outlined,
                      title: 'Panduan & Tata Tertib Perpustakaan',
                      subtitle: 'Aturan peminjaman, durasi, denda',
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: AppTheme.accentBlue,
                    ),
                    const Divider(height: 1, indent: 60),
                    _buildMenuItem(
                      icon: Icons.headset_mic_outlined,
                      title: 'Hubungi Petugas Perpustakaan',
                      subtitle: 'Layanan konsultasi sirkulasi',
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: AppTheme.mintGreen,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Keluar Akun Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _handleLogout(context, auth),
                  icon: const Icon(Icons.logout_rounded, size: 18, color: AppTheme.dangerRed),
                  label: const Text(
                    'Keluar Akun',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.dangerRed,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.dangerBackground,
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppTheme.textMuted,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.textSubtle),
        onTap: () {},
      ),
    );
  }
}
