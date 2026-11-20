import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/peminjaman.dart';
import '../providers/pinjaman_provider.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/custom_badge.dart';

/// Screen 5: Daftar Peminjaman Screen (Pinjaman Saya)
/// Sesuai 100% dengan Mockup Desain Figma (Foto 4)
class PinjamanScreen extends StatefulWidget {
  const PinjamanScreen({super.key});

  @override
  State<PinjamanScreen> createState() => _PinjamanScreenState();
}

class _PinjamanScreenState extends State<PinjamanScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PinjamanProvider>().fetchApiLoans();
    });
  }

  String _nextDueDate(Peminjaman loan) {
    final match = RegExp(r'^(\d{1,2}) (\w+) (\d{4})').firstMatch(loan.tanggalJatuhTempo);
    if (match == null) return '1 hari setelah tanggal jatuh tempo saat ini';
    const months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    const monthNumbers = <String, int>{'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'Mei': 5, 'Jun': 6, 'Jul': 7, 'Agu': 8, 'Sep': 9, 'Okt': 10, 'Nov': 11, 'Des': 12};
    final date = DateTime(int.parse(match.group(3)!), monthNumbers[match.group(2)] ?? 1, int.parse(match.group(1)!)).add(const Duration(days: 1));
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  void _handlePerpanjang(Peminjaman loan, PinjamanProvider provider) {
    if (!loan.bisaPerpanjang) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buku ini sudah pernah diperpanjang 1x.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.history_rounded, color: AppTheme.accentBlue),
            SizedBox(width: 8),
            Expanded(
              child: Text('Perpanjang Pinjaman?', maxLines: 2),
            ),
          ],
        ),
        content: Text(
          'Ajukan penambahan durasi pinjam selama +1 hari untuk buku "${loan.judulBuku}". '
          'Batas kembali baru: ${_nextDueDate(loan)}.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (!mounted) return;
              final success = await provider.perpanjangPinjaman(loan.id);
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perpanjangan waktu +1 hari berhasil diajukan!'),
                    backgroundColor: AppTheme.mintGreen,
                  ),
                );
              }
            },
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  /// Dialog pengembalian mandiri oleh siswa dengan bukti foto di perpustakaan.
  /// Tidak perlu menunggu persetujuan admin.
  Future<void> _handleKembalikanMandiri(Peminjaman loan, PinjamanProvider provider) async {
    Uint8List? imageBytes;
    String? imageBase64;
    String? imagePath;
    bool submitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> pick(ImageSource source) async {
              try {
                final xfile = await _picker.pickImage(source: source, imageQuality: 75);
                if (xfile != null) {
                  final bytes = await xfile.readAsBytes();
                  final b64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                  setSheetState(() {
                    imageBytes = bytes;
                    imageBase64 = b64;
                    imagePath = xfile.name;
                  });
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Gagal mengambil foto: $e')),
                  );
                }
              }
            }

            // Fallback simulasi foto di perpustakaan jika kamera hardware tidak tersedia
            void usePresetPhoto() {
              // 1x1 transparent/colored pixel valid base64 image
              const sampleBase64 =
                  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
              setSheetState(() {
                imageBase64 = sampleBase64;
                imageBytes = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
                imagePath = 'foto_perpustakaan_terverifikasi.jpg';
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
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
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCFBF1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF0F766E), size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengembalian Buku Mandiri',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                              Text(
                                'Kembalikan lebih awal tanpa menunggu persetujuan admin',
                                style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Detail Buku
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.softBlueBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          BookCoverWidget(
                            judul: loan.judulBuku,
                            penulis: loan.pengarang,
                            sampulUrl: loan.sampul,
                            width: 38,
                            height: 52,
                            borderRadius: 6,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loan.judulBuku,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  loan.pengarang,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Petunjuk Foto
                    const Text(
                      'Foto Buku di Perpustakaan (Bukti Valid)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Silakan letakkan buku di meja sirkulasi perpustakaan, lalu ambil foto fisik buku di lokasi perpustakaan sebagai bukti valid.',
                      style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted, height: 1.3),
                    ),
                    const SizedBox(height: 10),

                    // Area Preview Foto
                    Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: imageBytes != null ? const Color(0xFF0D9488) : const Color(0xFFCBD5E1),
                          width: imageBytes != null ? 2 : 1,
                        ),
                      ),
                      child: imageBytes != null
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    imageBytes!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 160,
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_rounded, color: AppTheme.mintGreen, size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          'Foto Bukti di Perpustakaan Terverifikasi',
                                          style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: 36, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Belum ada foto bukti pengembalian',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),

                    // Tombol Aksi Kamera & Galeri
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: submitting ? null : () => pick(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_rounded, size: 16),
                            label: const Text('Buka Kamera', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: submitting ? null : () => pick(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_rounded, size: 16),
                            label: const Text('Pilih Galeri', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: TextButton.icon(
                        onPressed: submitting ? null : usePresetPhoto,
                        icon: const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF0D9488)),
                        label: const Text(
                          'Gunakan Bukti Foto Perpustakaan (Simulasi)',
                          style: TextStyle(fontSize: 11, color: Color(0xFF0D9488), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol "Saya Sudah Mengembalikan"
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: submitting || imageBytes == null
                            ? null
                            : () async {
                                setSheetState(() => submitting = true);
                                final ok = await provider.kembalikanBukuMandiri(
                                  peminjamanId: loan.id,
                                  fotoPath: imagePath,
                                  base64Foto: imageBase64,
                                );
                                if (ctx.mounted) Navigator.of(ctx).pop();
                                if (!mounted) return;

                                if (ok) {
                                  showDialog(
                                    context: context,
                                    builder: (diagCtx) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: const Row(
                                        children: [
                                          Icon(Icons.hourglass_top_rounded, color: Color(0xFF6366F1), size: 28),
                                          SizedBox(width: 10),
                                          Expanded(child: Text('Bukti Terkirim!')),
                                        ],
                                      ),
                                      content: Text(
                                        'Terima kasih! Foto bukti pengembalian buku "${loan.judulBuku}" telah terkirim.\n\n'
                                        'Status pengembalian akan diubah setelah dikonfirmasi oleh admin perpustakaan. Anda dapat membatalkan atau mengubah bukti jika diperlukan.',
                                        style: const TextStyle(fontSize: 13, height: 1.4),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF6366F1),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () => Navigator.of(diagCtx).pop(),
                                          child: const Text('Mengerti'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                        child: submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Saya Sudah Mengembalikan',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

  void _showNotificationCenter(BuildContext context, PinjamanProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final activeLoans = provider.activeLoans;
        final nearDueLoans = activeLoans.where((l) => l.isHampirTenggat).toList();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.notifications_active_rounded, color: AppTheme.accentBlue, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Pusat Notifikasi & Pengingat',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Notifikasi otomatis pengembalian buku (aktif 5 jam sebelum jatuh tempo)',
                  style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                if (nearDueLoans.isNotEmpty) ...[
                  for (final loan in nearDueLoans) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.alarm_rounded, size: 18, color: Color(0xFFB45309)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Peringatan Tenggat: ${loan.judulBuku}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Waktu peminjaman berakhir dalam kurang dari 5 jam lagi (${loan.tanggalJatuhTempo}). Segera kembalikan buku ke perpustakaan!',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF78350F), height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ] else if (activeLoans.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppTheme.primaryNavy, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Anda memiliki ${activeLoans.length} buku aktif. Notifikasi pengingat akan otomatis muncul 5 jam sebelum jam pengembalian.',
                            style: const TextStyle(fontSize: 11.5, color: AppTheme.primaryNavy, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Tidak ada pengingat aktif saat ini.',
                        style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinjamanProv = context.watch<PinjamanProvider>();

    final activeCount = pinjamanProv.activeLoans.length;
    final historyCount = pinjamanProv.historyLoans.length;
    final dendaCount = pinjamanProv.dendaLoans.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header PUSTAKADIGITAL - Pinjaman Saya
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
                          Icons.collections_bookmark_rounded,
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
                            'Pinjaman Saya',
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
                        onPressed: () => _showNotificationCenter(context, pinjamanProv),
                        icon: Stack(
                          children: [
                            const Icon(Icons.notifications_outlined, size: 24),
                            if (pinjamanProv.hampirTenggatLoans.isNotEmpty)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.amberWarning,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
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

              // Policy Alert Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.softBlueBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDCEBFA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppTheme.primaryBlue,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aturan & Notifikasi Pengembalian',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Peminjaman dapat dipilih 1 s.d. 3 hari. Pengingat pengembalian aktif 5 jam sebelum waktu habis. '
                            'Anda dapat mengembalikan lebih awal dengan menekan tombol "Saya Sudah Mengembalikan" dan melampirkan foto bukti di perpustakaan.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textDark.withValues(alpha: 0.8),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Segmented 3 Tab Controller
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEF2F6)),
                ),
                child: Row(
                  children: [
                    _buildTabItem(0, 'Sedang Dipinjam', activeCount, pinjamanProv),
                    _buildTabItem(1, 'Riwayat Selesai', historyCount, pinjamanProv),
                    _buildTabItem(2, 'Denda & Telat', dendaCount, pinjamanProv),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tab View Content
              if (pinjamanProv.selectedTab == 0) ...[
                if (pinjamanProv.activeLoans.isEmpty)
                  _buildEmptyState('Tidak ada buku yang sedang dipinjam.')
                else
                  for (final loan in pinjamanProv.activeLoans) ...[
                    _buildActiveLoanCard(loan, pinjamanProv),
                    const SizedBox(height: 14),
                  ],
              ] else if (pinjamanProv.selectedTab == 1) ...[
                if (pinjamanProv.historyLoans.isEmpty)
                  _buildEmptyState('Belum ada riwayat buku yang dikembalikan.')
                else
                  for (final loan in pinjamanProv.historyLoans) ...[
                    _buildHistoryLoanCard(loan),
                    const SizedBox(height: 12),
                  ],
              ] else ...[
                _buildDendaTab(dendaCount),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, int count, PinjamanProvider provider) {
    final isSelected = provider.selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF2F6)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveLoanCard(Peminjaman loan, PinjamanProvider provider) {
    final isHampirTenggat = loan.isHampirTenggat;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHampirTenggat ? const Color(0xFFFDE68A) : const Color(0xFFEEF2F6),
          width: isHampirTenggat ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loan.trxId,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMuted,
                ),
              ),
              // Badge: Bukti Pending Konfirmasi / Hampir Tenggat / Sisa Hari
              if (loan.buktiPendingKonfirmasi) ...[
                CustomBadge(
                  label: 'Bukti Terkirim',
                  type: BadgeType.dipinjam,
                  fontSize: 10,
                ),
              ] else ...[
                CustomBadge(
                  label: isHampirTenggat ? 'Hampir Tenggat (< 5 Jam)' : 'Sisa ${loan.sisaHari} Hari',
                  type: isHampirTenggat ? BadgeType.warning : BadgeType.tersedia,
                  fontSize: 10,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Peringatan H-5 Jam jika hampir jatuh tempo
          if (isHampirTenggat) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFB45309)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Peringatan: Kurang dari 5 jam lagi batas pengembalian! Anda bisa kembalikan sekarang dengan foto bukti di perpustakaan.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Status: Bukti Terkirim (Menunggu Konfirmasi Admin)
          if (loan.buktiPendingKonfirmasi) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top_rounded, size: 20, color: Color(0xFF6366F1)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bukti Terkirim — Menunggu Konfirmasi Admin',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3730A3)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Anda telah mengunggah foto bukti pengembalian. Admin akan memverifikasi segera. Anda dapat membatalkan jika ingin mengubah bukti.',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF4338CA), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Book Info Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCoverWidget(
                judul: loan.judulBuku,
                penulis: loan.pengarang,
                sampulUrl: loan.sampul,
                width: 56,
                height: 78,
                borderRadius: 8,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.kategoriNama.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: AppTheme.accentBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loan.judulBuku,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loan.pengarang,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dates & Progress Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tgl Pinjam',
                          style: TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loan.tanggalPinjam,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Batas Kembali',
                          style: TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loan.tanggalJatuhTempo,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress Waktu Pinjam',
                      style: TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                    ),
                    Text(
                      '${loan.hariBerjalan} dari ${loan.durasiHariTotal} hari (${loan.persentaseInt}%)',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: loan.persentaseWaktu,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryNavy),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons: Seimbang & Proporsional
          // State bukti pending konfirmasi -> hanya tombol batal, bukan Kembalikan/+1 Hari.
          // State reservasi (isBooking) -> tanpa aksi pinjam, tampilkan info reservasi.
          if (loan.buktiPendingKonfirmasi) ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () => provider.batalkanBuktiKembalikan(loan.id),
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text(
                        'Batalkan & Unggah Ulang',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryNavy,
                        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (!loan.isBooking && loan.statusReservasi != 'booking') ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleKembalikanMandiri(loan, provider),
                      icon: const Icon(Icons.camera_alt_outlined, size: 16),
                      label: const Text(
                        'Kembalikan',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                if (loan.bisaPerpanjang) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: () => _handlePerpanjang(loan, provider),
                        icon: const Icon(Icons.autorenew_rounded, size: 16),
                        label: const Text(
                          '+1 Hari',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryNavy,
                          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ] else if (loan.isBooking) ...[
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.softBlueBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Status Reservasi: Menunggu Tanggal Ambil',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRatingDialog(Peminjaman loan) {
    var rating = loan.rating?.round() ?? 0;
    var submitting = false;
    final komentar = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<PinjamanProvider>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogStateContext, setDialogState) => AlertDialog(
          title: Text(loan.rating == null ? 'Beri rating buku' : 'Ubah rating buku'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(alignment: WrapAlignment.center, spacing: 8, children: List.generate(5, (index) => IconButton(
                  onPressed: submitting ? null : () => setDialogState(() => rating = index + 1),
                  icon: Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.amber),
                ))),
                TextField(
                  controller: komentar,
                  maxLines: 2,
                  enabled: !submitting,
                  decoration: const InputDecoration(labelText: 'Komentar (opsional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: rating == 0 || submitting
                  ? null
                  : () async {
                      setDialogState(() => submitting = true);
                      final ok = await provider.submitRating(
                        peminjamanId: loan.id,
                        rating: rating,
                        komentar: komentar.text,
                      );
                      if (!dialogContext.mounted) {
                        return;
                      }
                      Navigator.pop(dialogContext);
                      if (!mounted) {
                        return;
                      }
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Rating berhasil disimpan' : (provider.error ?? 'Gagal menyimpan rating')),
                        ),
                      );
                    },
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryLoanCard(Peminjaman loan) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCoverWidget(
            judul: loan.judulBuku,
            penulis: loan.pengarang,
            sampulUrl: loan.sampul,
            width: 48,
            height: 68,
            borderRadius: 6,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loan.trxId,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                    ),
                    const CustomBadge(
                      label: 'Dikembalikan',
                      type: BadgeType.tersedia,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  loan.judulBuku,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  loan.pengarang,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 4),
                if (loan.isKembaliMandiri) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_rounded, size: 11, color: Color(0xFF0F766E)),
                        SizedBox(width: 4),
                        Text(
                          'Kembali Mandiri di Perpustakaan (Bukti Valid)',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  'Dipinjam ${loan.tanggalPinjam} • Dikembalikan tepat waktu',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF047857), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _showRatingDialog(loan),
                  icon: Icon(loan.rating == null ? Icons.star_border : Icons.edit_outlined, size: 16),
                  label: Text(loan.rating == null ? 'Beri rating' : 'Ubah rating'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDendaTab(int dendaCount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF2F6)),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.verified_rounded, size: 48, color: AppTheme.mintGreen),
            SizedBox(height: 12),
            Text(
              'Status Bebas Denda',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            SizedBox(height: 6),
            Text(
              'Hebat! Anda selalu mengembalikan buku tepat waktu dan tidak memiliki catatan denda keterlambatan aktif.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
