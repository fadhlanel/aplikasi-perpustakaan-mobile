import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/offline_cache.dart';
import '../providers/auth_provider.dart';
import '../providers/buku_provider.dart';
import '../providers/pinjaman_provider.dart';
import '../widgets/book_cover_widget.dart';
import 'login_screen.dart';
import 'pinjaman_screen.dart';

/// Screen 6: Profil Siswa Screen
/// Sesuai Desain Figma (Foto 5) dengan seluruh menu fungsional dan anti-overflow
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().refreshProfile();
      }
    });
  }

  void _showEditProfileSheet(BuildContext context, AuthProvider auth) {
    final namaController = TextEditingController(text: auth.profile.nama);
    final nisController = TextEditingController(text: auth.profile.nis);
    final kelasController = TextEditingController(
      text: auth.profile.kelas == '-' ? '' : auth.profile.kelas,
    );
    final emailController = TextEditingController(
      text: auth.profile.email ?? '',
    );
    final teleponController = TextEditingController(
      text: auth.profile.telepon ?? '',
    );
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(dialogCtx).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: AppTheme.accentBlue,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Edit Profil Siswa',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Perubahan dikirim ke admin untuk diperiksa sebelum diterapkan.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Nama wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nisController,
                        decoration: const InputDecoration(
                          labelText: 'NIS',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: kelasController,
                        decoration: const InputDecoration(
                          labelText: 'Kelas',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: teleponController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telepon',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setSheetState(() => saving = true);
                                  final ok = await auth.updateProfile(
                                    nama: namaController.text,
                                    nis: nisController.text,
                                    kelas: kelasController.text,
                                    email: emailController.text,
                                    telepon: teleponController.text,
                                  );
                                  if (ctx.mounted) Navigator.of(ctx).pop();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ok
                                              ? 'Profil berhasil diperbarui!'
                                              : 'Gagal memperbarui profil.',
                                        ),
                                        backgroundColor: ok
                                            ? const Color(0xFF047857)
                                            : AppTheme.dangerRed,
                                      ),
                                    );
                                  }
                                },
                          child: Text(
                            saving ? 'Menyimpan...' : 'Simpan Profil',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.dangerRed),
            SizedBox(width: 8),
            Expanded(child: Text('Keluar Akun?')),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
            ),
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

  // 1. Bottom Sheet: Buku Favorit & Bookmark
  void _showBookmarkSheet(BuildContext context) {
    final bukuProv = context.read<BukuProvider>();
    final bookmarked = [
      ...bukuProv.items.where((b) => b.isBookmarked),
      ...bukuProv.popularBooks.where(
        (b) => b.isBookmarked && !bukuProv.items.any((i) => i.id == b.id),
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.bookmark_rounded,
                              color: AppTheme.accentBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Buku Favorit & Bookmark',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Text(
                                'Daftar judul buku yang Anda simpan',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${bookmarked.length} Judul',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Expanded(
                    child: bookmarked.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bookmark_border_rounded,
                                  size: 54,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Belum Ada Buku Tersimpan',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    'Jelajahi Beranda atau Katalog, lalu tekan ikon bookmark untuk menyimpan buku favorit Anda di sini.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: bookmarked.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (ctx, i) {
                              final buku = bookmarked[i];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFEEF2F6),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    BookCoverWidget(
                                      judul: buku.judul,
                                      penulis: buku.namaPenulis,
                                      sampulUrl: buku.sampul,
                                      width: 48,
                                      height: 64,
                                      borderRadius: 6,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            buku.judul,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            buku.namaPenulis,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                size: 14,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${buku.rating}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                buku.lokasiRak,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppTheme.textSubtle,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.bookmark_remove_rounded,
                                        color: AppTheme.dangerRed,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        bukuProv.toggleBookmark(buku.id);
                                        Navigator.of(ctx).pop();
                                        _showBookmarkSheet(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 2. Bottom Sheet: Notifikasi Pengingat Pengembalian
  void _showNotificationSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool hMinus3 = true;
        bool hDay = true;
        bool sound = true;

        return StatefulBuilder(
          builder: (ctx, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: AppTheme.accentBlue,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Pengingat Jatuh Tempo Buku',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pilih waktu notifikasi pengingat sebelum batas akhir pinjaman berakhir agar terhindar dari denda.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: hMinus3,
                      activeThumbColor: AppTheme.primaryNavy,
                      title: const Text(
                        'Pengingat H-3 Sebelum Jatuh Tempo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Memberi waktu persiapan mengembalikan buku ke perpustakaan',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      onChanged: (v) => setState(() => hMinus3 = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: hDay,
                      activeThumbColor: AppTheme.primaryNavy,
                      title: const Text(
                        'Pengingat Hari-H Pengembalian',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Notifikasi pagi hari jam 07:00 pada tanggal jatuh tempo',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      onChanged: (v) => setState(() => hDay = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: sound,
                      activeThumbColor: AppTheme.primaryNavy,
                      title: const Text(
                        'Suara & Getar Pengingat',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Bunyikan alarm ringan saat notifikasi tiba',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      onChanged: (v) => setState(() => sound = v),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Preferensi notifikasi pengingat berhasil disimpan.',
                              ),
                              backgroundColor: Color(0xFF047857),
                            ),
                          );
                        },
                        child: const Text(
                          'Simpan Preferensi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 3. Bottom Sheet: Riwayat Kunjungan Perpustakaan
  void _showVisitHistorySheet(BuildContext context) {
    final visits = [
      {
        'tanggal': 'Hari ini, 09:15 WIB',
        'lokasi': 'Ruang Sirkulasi & Baca Lt. 2',
        'status': 'Presensi QR Terverifikasi',
        'tipe': 'Membaca di Tempat',
      },
      {
        'tanggal': '28 Okt 2024, 13:40 WIB',
        'lokasi': 'Meja Layanan Sirkulasi',
        'status': 'Peminjaman Mandiri Sukses',
        'tipe': 'Sirkulasi Buku',
      },
      {
        'tanggal': '21 Okt 2024, 10:05 WIB',
        'lokasi': 'Ruang Referensi & Jurnal',
        'status': 'Presensi QR Terverifikasi',
        'tipe': 'Studi Mandiri',
      },
      {
        'tanggal': '14 Okt 2024, 11:20 WIB',
        'lokasi': 'Laboratorium Multimedia',
        'status': 'Presensi QR Terverifikasi',
        'tipe': 'Pencarian e-Book',
      },
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppTheme.accentBlue,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Riwayat Kunjungan Perpustakaan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Catatan presensi fisik saat berkunjung ke ruang perpustakaan sekolah.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '4 Kali',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentBlue,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Bulan Ini',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 24,
                        child: VerticalDivider(color: Color(0xFFBFDBFE)),
                      ),
                      Column(
                        children: [
                          Text(
                            '6.5 Jam',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.mintGreen,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Durasi Baca',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 24,
                        child: VerticalDivider(color: Color(0xFFBFDBFE)),
                      ),
                      Column(
                        children: [
                          Text(
                            '100%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF047857),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Disiplin QR',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView.separated(
                    itemCount: visits.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final v = visits[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEEF2F6)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.place_outlined,
                                color: AppTheme.primaryNavy,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v['lokasi']!,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    v['tanggal']!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                v['tipe']!,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangePinDialog(BuildContext context, AuthProvider auth) {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (dialogCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(dialogCtx).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.lock_reset_rounded,
                            color: AppTheme.accentBlue,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Ganti PIN / Kata Sandi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.darkTextPrimary
                                  : AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Masukkan PIN lama Anda dan tentukan 6 digit PIN baru untuk keamanan akun.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: oldPinController,
                        obscureText: obscureOld,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: 'PIN Lama',
                          counterText: '',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureOld
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setSheetState(() => obscureOld = !obscureOld),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'PIN lama wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: newPinController,
                        obscureText: obscureNew,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: 'PIN Baru (6 Digit Angka)',
                          counterText: '',
                          prefixIcon: const Icon(Icons.password_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setSheetState(() => obscureNew = !obscureNew),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().length != 6) {
                            return 'PIN baru harus 6 digit angka';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmPinController,
                        obscureText: obscureConfirm,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi PIN Baru',
                          counterText: '',
                          prefixIcon: const Icon(
                            Icons.check_circle_outline_rounded,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setSheetState(
                              () => obscureConfirm = !obscureConfirm,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v != newPinController.text) {
                            return 'Konfirmasi PIN tidak cocok';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            final success = await auth.changePin(
                              oldPinController.text,
                              newPinController.text,
                            );
                            if (ctx.mounted) Navigator.of(ctx).pop();
                            if (context.mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'PIN berhasil diperbarui! Silakan gunakan PIN baru untuk login selanjutnya.',
                                    ),
                                    backgroundColor: Color(0xFF047857),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Gagal mengubah PIN. PIN lama yang Anda masukkan salah.',
                                    ),
                                    backgroundColor: AppTheme.dangerRed,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Simpan PIN Baru',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 4. Bottom Sheet: Pengaturan Tema & Akun
  void _showAccountSettingsSheet(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      color: AppTheme.accentBlue,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Pengaturan Tema & Akun',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.edit_note_rounded,
                    color: AppTheme.accentBlue,
                  ),
                  title: Text(
                    'Edit Data Profil',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textDark,
                    ),
                  ),
                  subtitle: const Text(
                    'Perbarui nama dan data akun Anda',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textSubtle,
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showEditProfileSheet(context, auth);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppTheme.primaryNavy,
                  ),
                  title: Text(
                    'Ganti PIN / Kata Sandi',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textDark,
                    ),
                  ),
                  subtitle: const Text(
                    'Perbarui kode sandi login keanggotaan Anda',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textSubtle,
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showChangePinDialog(context, auth);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.cleaning_services_rounded,
                    color: AppTheme.amberWarning,
                  ),
                  title: Text(
                    'Hapus Cache Data Offline',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textDark,
                    ),
                  ),
                  subtitle: const Text(
                    'Bersihkan data tersimpan lokal jika ada pembaruan',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textSubtle,
                  ),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await OfflineCache.clearCache();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cache offline berhasil dibersihkan.'),
                          backgroundColor: Color(0xFF047857),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Pustaka Digital v1.0.0 (Build 1) • SMK Negeri 1 Surabaya',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 5. Bottom Sheet: Panduan & Tata Tertib
  void _showRulesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (ctx, scroll) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: AppTheme.accentBlue,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Panduan & Tata Tertib Sirkulasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scroll,
                      children: [
                        _buildRuleItem(
                          '1',
                          'Batas Kuota Pinjam',
                          'Maksimal 3 eksemplar buku per siswa sekaligus.',
                        ),
                        _buildRuleItem(
                          '2',
                          'Durasi Peminjaman',
                          'Lama peminjaman adalah 3 hari kalender sejak tanggal transaksi.',
                        ),
                        _buildRuleItem(
                          '3',
                          'Perpanjangan Mandiri',
                          'Perpanjangan dapat diajukan mandiri 1x per transaksi peminjaman (+1 hari kalender).',
                        ),
                        _buildRuleItem(
                          '4',
                          'Denda Keterlambatan',
                          'Keterlambatan pengembalian buku dikenakan denda administratif sebesar Rp 1.000 / hari per eksemplar.',
                        ),
                        _buildRuleItem(
                          '5',
                          'Integritas Koleksi',
                          'Dilarang mencoret, melipat, atau merusak barcode buku. Kehilangan buku wajib diganti dengan judul dan edisi yang sama.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRuleItem(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppTheme.softBlueBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. Bottom Sheet: Hubungi Petugas Perpustakaan
  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Icon(
                      Icons.headset_mic_rounded,
                      color: AppTheme.mintGreen,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Layanan Bantuan Pustakawan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Butuh bantuan perpanjangan manual, pencarian judul skripsi, atau pertanyaan sirkulasi?',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            color: Color(0xFF047857),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Jam Layanan: Senin - Jumat (07:30 - 15:30 WIB)',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.room_rounded,
                            color: Color(0xFF047857),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Lokasi: Gedung Perpustakaan Lt. 2 Sayap Barat',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.chat_rounded, size: 18),
                    label: const Text(
                      'Hubungi via WhatsApp Pustakawan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Menghubungkan ke WhatsApp Ruang Sirkulasi Perpustakaan...',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pinjaman = context.watch<PinjamanProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = auth.profile;
    final activeLoans = pinjaman.activeLoans;
    final activeLoan = activeLoans.isNotEmpty ? activeLoans.first : null;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await auth.refreshProfile();
            await pinjaman.fetchApiLoans();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                            color: isDark
                                ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                                : AppTheme.softBlueBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppTheme.primaryBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
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
                                color: isDark
                                    ? AppTheme.darkTextPrimary
                                    : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
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
                const SizedBox(height: 16),

                // Student Profile Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkSurface
                        : AppTheme.softBlueBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.darkBorder
                          : const Color(0xFFDCEBFA),
                    ),
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
                              color: AppTheme.primaryNavy.withValues(
                                alpha: 0.1,
                              ),
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.darkBorder
                                    : Colors.white,
                                width: 2.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: AppTheme.cyanAccent,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkSurface
                                    : Colors.white,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 10,
                                    color: Color(0xFF047857),
                                  ),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    profile.nama,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppTheme.darkTextPrimary
                                          : AppTheme.textDark,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () =>
                                      _showEditProfileSheet(context, auth),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue.shade100,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.edit_rounded,
                                          size: 12,
                                          color: AppTheme.primaryNavy,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Edit',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryNavy,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'NIS: ${profile.nis} • ${profile.kelas}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Responsive Wrap for School + Badge (Anti-Overflow)
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      size: 13,
                                      color: isDark
                                          ? AppTheme.cyanAccent
                                          : AppTheme.primaryNavy,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      profile.sekolah,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? AppTheme.darkTextPrimary
                                            : AppTheme.textDark,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        size: 11,
                                        color: AppTheme.accentBlue,
                                      ),
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
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.calendar_month_rounded,
                        value: '${activeLoans.length}',
                        label: 'Buku Sedang\nAktif',
                        iconBg: const Color(0xFFECFDF5),
                        iconColor: AppTheme.mintGreen,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.shield_outlined,
                        value: '${profile.dendaCount}',
                        label: 'Denda &\nSanksi',
                        iconBg: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFF8FAFC),
                        iconColor: isDark
                            ? AppTheme.cyanAccent
                            : AppTheme.primaryNavy,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Active Loan Reminder Card (Dynamic from PinjamanProvider)
                if (activeLoan != null) ...[
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PinjamanScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.darkBorder
                              : const Color(0xFFEEF2F6),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.03,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          BookCoverWidget(
                            judul: activeLoan.judulBuku,
                            penulis: activeLoan.pengarang,
                            sampulUrl: activeLoan.sampul,
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
                                      decoration: BoxDecoration(
                                        color: activeLoan.sisaHari <= 0
                                            ? AppTheme.dangerRed
                                            : (activeLoan.sisaHari <= 2
                                                  ? AppTheme.amberWarning
                                                  : AppTheme.mintGreen),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      activeLoan.sisaHari > 0
                                          ? 'Tenggat ${activeLoan.sisaHari} Hari Lagi'
                                          : (activeLoan.sisaHari == 0
                                                ? 'Jatuh Tempo Hari Ini!'
                                                : 'Terlambat ${activeLoan.sisaHari.abs()} Hari!'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: activeLoan.sisaHari <= 0
                                            ? AppTheme.dangerRed
                                            : (activeLoan.sisaHari <= 2
                                                  ? AppTheme.amberWarning
                                                  : const Color(0xFF047857)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activeLoan.judulBuku,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppTheme.darkTextPrimary
                                        : AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Kembalikan s.d. ${activeLoan.tanggalJatuhTempo}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E3A8A)
                                        .withValues(alpha: 0.3)
                                  : AppTheme.softBlueBackground,
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
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppTheme.darkBorder
                            : const Color(0xFFEEF2F6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF064E3B)
                                : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppTheme.mintGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tidak Ada Pinjaman Aktif',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppTheme.darkTextPrimary
                                      : AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Semua buku telah dikembalikan tepat waktu.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.darkBorder
                          : const Color(0xFFEEF2F6),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.bookmark_outline_rounded,
                        title: 'Buku Favorit & Bookmark',
                        subtitle: 'Buku tersimpan di koleksi pribadi',
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: AppTheme.accentBlue,
                        onTap: () => _showBookmarkSheet(context),
                        isDark: isDark,
                      ),
                      Divider(
                        height: 1,
                        indent: 60,
                        color: isDark ? AppTheme.darkBorder : null,
                      ),
                      _buildMenuItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifikasi Pengingat Pengembalian',
                        subtitle: 'H-3 sebelum jatuh tempo buku',
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: AppTheme.accentBlue,
                        onTap: () => _showNotificationSettingsSheet(context),
                        isDark: isDark,
                      ),
                      Divider(
                        height: 1,
                        indent: 60,
                        color: isDark ? AppTheme.darkBorder : null,
                      ),
                      _buildMenuItem(
                        icon: Icons.qr_code_scanner_rounded,
                        title: 'Riwayat Kunjungan Perpustakaan',
                        subtitle: 'Presensi fisik & baca di tempat',
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: AppTheme.accentBlue,
                        onTap: () => _showVisitHistorySheet(context),
                        isDark: isDark,
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
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.darkBorder
                          : const Color(0xFFEEF2F6),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.tune_rounded,
                        title: 'Pengaturan Tema & Akun',
                        subtitle: 'Keamanan sandi, profil, preferensi',
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: AppTheme.accentBlue,
                        onTap: () => _showAccountSettingsSheet(context, auth),
                        isDark: isDark,
                      ),
                      Divider(
                        height: 1,
                        indent: 60,
                        color: isDark ? AppTheme.darkBorder : null,
                      ),
                      _buildMenuItem(
                        icon: Icons.menu_book_outlined,
                        title: 'Panduan & Tata Tertib Perpustakaan',
                        subtitle: 'Aturan peminjaman, durasi, denda',
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: AppTheme.accentBlue,
                        onTap: () => _showRulesSheet(context),
                        isDark: isDark,
                      ),
                      Divider(
                        height: 1,
                        indent: 60,
                        color: isDark ? AppTheme.darkBorder : null,
                      ),
                      _buildMenuItem(
                        icon: Icons.headset_mic_outlined,
                        title: 'Hubungi Petugas Perpustakaan',
                        subtitle: 'Layanan konsultasi sirkulasi',
                        iconBg: const Color(0xFFECFDF5),
                        iconColor: AppTheme.mintGreen,
                        onTap: () => _showContactSheet(context),
                        isDark: isDark,
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
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: AppTheme.dangerRed,
                    ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
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
    bool isDark = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFEEF2F6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppTheme.textMuted,
                height: 1.2,
              ),
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
    VoidCallback? onTap,
    bool isDark = false,
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
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: AppTheme.textSubtle,
        ),
        onTap: onTap,
      ),
    );
  }
}
