import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/buku.dart';
import '../providers/auth_provider.dart';
import '../providers/buku_provider.dart';
import '../providers/pinjaman_provider.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/custom_badge.dart';

/// Screen 4: Detail Buku Screen
/// Sesuai 100% dengan Mockup Desain Figma (Foto 3)
class DetailBukuScreen extends StatefulWidget {
  const DetailBukuScreen({super.key, required this.bukuId});

  final int bukuId;

  @override
  State<DetailBukuScreen> createState() => _DetailBukuScreenState();
}

class _DetailBukuScreenState extends State<DetailBukuScreen> {
  int _selectedTab = 0; // 0: Sinopsis & Ringkasan, 1: Detail Metadata, 2: Ulasan
  bool _isPinjamLoading = false;

  @override
  Widget build(BuildContext context) {
    final bukuProv = context.watch<BukuProvider>();
    final auth = context.watch<AuthProvider>();
    final pinjamanProv = context.watch<PinjamanProvider>();

    final buku = bukuProv.items.firstWhere(
      (b) => b.id == widget.bukuId,
      orElse: () => bukuProv.getHeroBook(),
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Detail Buku'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryNavy,
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top action bar (Share & Bookmark)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tautan buku disalin ke clipboard.')),
                    );
                  },
                  icon: const Icon(Icons.share_outlined, color: AppTheme.primaryNavy, size: 20),
                ),
                IconButton(
                  onPressed: () => bukuProv.toggleBookmark(buku.id),
                  icon: Icon(
                    buku.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: AppTheme.primaryNavy,
                    size: 22,
                  ),
                ),
              ],
            ),

            // Large Book Cover Hero
            Center(
              child: BookCoverWidget(
                judul: buku.judul,
                penulis: buku.namaPenulis,
                width: 170,
                height: 240,
                borderRadius: 14,
                elevation: 8,
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              buku.judul,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),

            // Author with graduation cap icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school_outlined, size: 16, color: AppTheme.primaryNavy),
                const SizedBox(width: 6),
                Text(
                  buku.namaPenulis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${buku.rating}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  '  •  ${buku.ulasanCount} Ulasan Sivitas',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tag Chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                _buildTagChip('RPL / Software'),
                _buildTagChip('Indonesia'),
                _buildTagChip('Tahun ${buku.tahunTerbit}'),
                _buildTagChip(buku.kodePanggil),
              ],
            ),
            const SizedBox(height: 18),

            // Availability Card (Mint / Green)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFB9F0D8)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.mintGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: AppTheme.mintGreen, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  '${buku.stokTersedia} dari ${buku.stok} Buku',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const CustomBadge(
                                  label: 'Tersedia',
                                  type: BadgeType.tersedia,
                                  fontSize: 10,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${buku.dipinjamCount} sedang dipinjam mahasiswa',
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
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: buku.stok > 0 ? (buku.stokTersedia / buku.stok) : 0.8,
                      minHeight: 6,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.mintGreen),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Location Card (Blue)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.softBlueBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD6E6F9)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppTheme.primaryBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LOKASI PENEMPATAN',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          buku.lokasiRak,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _showMapDialog,
                    icon: const Icon(Icons.map_outlined, size: 14, color: AppTheme.primaryNavy),
                    label: const Text(
                      'Peta',
                      style: TextStyle(fontSize: 11.5, color: AppTheme.primaryNavy, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Segmented Tabs (Sinopsis, Metadata, Ulasan)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildTabItem(0, 'Sinopsis & Ringkasan'),
                  _buildTabItem(1, 'Detail Metadata'),
                  _buildTabItem(2, 'Ulasan (${buku.ulasanCount})'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Content
            _buildTabContent(buku),
            const SizedBox(height: 22),

            // Section: Buku Terkait di Rak RPL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Buku Terkait di Rak RPL',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Lihat Koleksi',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.accentBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Related Books Horizontal Carousel
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: bukuProv.popularBooks.length,
                separatorBuilder: (_, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final related = bukuProv.popularBooks[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => DetailBukuScreen(bukuId: related.id),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 110,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BookCoverWidget(
                            judul: related.judul,
                            penulis: related.namaPenulis,
                            width: 110,
                            height: 130,
                            borderRadius: 8,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            related.judul,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            related.namaPenulis,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Sticky Bottom Bar
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Tanya Pustakawan (Secondary button)
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Menghubungkan ke layanan chat pustakawan...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppTheme.primaryNavy),
                  label: const Text(
                    'Tanya Pustakawan',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Reservasi Peminjaman (Primary Navy button)
              Expanded(
                flex: 5,
                child: ElevatedButton.icon(
                  onPressed: _isPinjamLoading
                      ? null
                      : () => _handlePinjam(context, buku, auth, pinjamanProv),
                  icon: _isPinjamLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.calendar_month_rounded, size: 18),
                  label: const Text(
                    'Reservasi Pinjam',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(Buku buku) {
    if (_selectedTab == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF2F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tentang Buku Ini',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              buku.deskripsiText,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FeaturePill(text: 'Dart SDK 3.x & Flutter 3.10+'),
                _FeaturePill(text: 'State Management Modern'),
                _FeaturePill(text: 'Integrasi Backend REST & GraphQL'),
                _FeaturePill(text: 'Repository Proyek GitHub Eksklusif'),
              ],
            ),
          ],
        ),
      );
    } else if (_selectedTab == 1) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF2F6)),
        ),
        child: Column(
          children: [
            _buildMetaRow('Judul Lengkap', buku.judul),
            _buildMetaRow('Penulis', buku.namaPenulis),
            _buildMetaRow('Penerbit', buku.namaPenerbit),
            _buildMetaRow('Tahun Terbit', '${buku.tahunTerbit}'),
            _buildMetaRow('ISBN', buku.isbn ?? '978-602-05-1234-5'),
            _buildMetaRow('Klasifikasi DDC', buku.kodePanggil),
            _buildMetaRow('Bahasa', 'Bahasa Indonesia'),
            _buildMetaRow('Lokasi Fisik', buku.lokasiRak),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF2F6)),
        ),
        child: Column(
          children: [
            _buildReviewItem('Ahmad Fauzi (XII RPL 2)', 5, 'Buku sangat mudah dipahami, contoh kodenya relevan untuk tugas akhir.'),
            const Divider(),
            _buildReviewItem('Siti Nurhaliza (XI RPL 1)', 5, 'Penjelasan State Management Provider & BLoC paling lengkap!'),
          ],
        ),
      );
    }
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primaryNavy,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryNavy : AppTheme.textMuted,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, int stars, String comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(
                  stars,
                  (_) => const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Future<void> _handlePinjam(
    BuildContext context,
    Buku buku,
    AuthProvider auth,
    PinjamanProvider pinjamanProv,
  ) async {
    setState(() => _isPinjamLoading = true);

    await pinjamanProv.pinjamBuku(
      buku: buku,
      nis: auth.profile.nis,
      nama: auth.profile.nama,
    );

    if (!mounted || !context.mounted) return;
    setState(() => _isPinjamLoading = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.mintGreen, size: 28),
            SizedBox(width: 10),
            Text('Reservasi Berhasil'),
          ],
        ),
        content: Text(
          'Buku "${buku.judul}" berhasil direservasi atas nama ${auth.profile.nama}. '
          'Silakan ambil fisik buku di ${buku.lokasiRak} dalam 1x24 jam.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMapDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Denah Rak Perpustakaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppTheme.softBlueBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_rounded, size: 48, color: AppTheme.primaryBlue),
                    SizedBox(height: 8),
                    Text(
                      'Lantai 2 — Sayap Barat\nZona Rekayasa Perangkat Lunak',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Tutup')),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.mintGreen),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF166534),
            ),
          ),
        ],
      ),
    );
  }
}
