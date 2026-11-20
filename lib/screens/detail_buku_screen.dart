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
  List<Map<String, dynamic>> _ulasan = [];
  bool _loadingUlasan = false;

  @override
  void initState() {
    super.initState();
    _loadRatingAndUlasan();
  }

  Future<void> _loadRatingAndUlasan() async {
    final bukuProv = context.read<BukuProvider>();
    final buku = bukuProv.items.firstWhere(
      (b) => b.id == widget.bukuId,
      orElse: Buku.kosong,
    );

    if (buku.id != 0) {
      setState(() => _loadingUlasan = true);
      
      // Fetch rating stats and ulasan reviews in parallel
      await Future.wait([
        bukuProv.enrichBukuWithRatings(buku),
        bukuProv.fetchUlasan(buku.id).then((reviews) {
          setState(() => _ulasan = reviews);
        }),
      ]);
      
      setState(() => _loadingUlasan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bukuProv = context.watch<BukuProvider>();
    final auth = context.watch<AuthProvider>();
    final pinjamanProv = context.watch<PinjamanProvider>();

    final buku = bukuProv.items.firstWhere(
      (b) => b.id == widget.bukuId,
      orElse: Buku.kosong,
    );
    final bukuTersedia = buku.id != 0;

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
            if (!bukuTersedia)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Buku tidak tersedia. Muat ulang katalog dari server.'),
              ),
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
                sampulUrl: buku.sampul,
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
              height: 215,
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
                            sampulUrl: related.sampul,
                            width: 110,
                            height: 155,
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
                  onPressed: _isPinjamLoading || !bukuTersedia
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
      final sinopsisText = (buku.sinopsis?.trim().isNotEmpty ?? false)
          ? buku.sinopsis!.trim()
          : buku.deskripsiText;
      final ringkasanText = buku.ringkasan?.trim() ?? '';

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
              sinopsisText,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                height: 1.5,
              ),
            ),
            if (ringkasanText.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text(
                'Ringkasan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                ringkasanText,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF334155),
                  height: 1.5,
                ),
              ),
            ],
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
            _buildMetaRow('Bahasa', 'Bahasa Indonesia'),
          ],
        ),
      );
    } else {
      if (_loadingUlasan) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEF2F6)),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (_ulasan.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEF2F6)),
          ),
          child: const Center(
            child: Text(
              'Belum ada ulasan untuk buku ini',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
        );
      }

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
            for (int i = 0; i < _ulasan.length; i++) ...[
              _buildReviewItemFromData(_ulasan[i]),
              if (i < _ulasan.length - 1) const Divider(),
            ],
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
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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

  Widget _buildReviewItemFromData(Map<String, dynamic> data) {
    final nama = data['nama'] ?? data['nama_pengguna'] ?? data['user_name'] ?? 'Pengguna';
    final rating = (data['rating'] as num?)?.toInt() ?? 0;
    final komentar = data['komentar'] ?? data['comment'] ?? '';
    
    return _buildReviewItem(nama, rating, komentar);
  }

  Future<void> _handlePinjam(
    BuildContext context,
    Buku buku,
    AuthProvider auth,
    PinjamanProvider pinjamanProv,
  ) async {
    final apiBook = context.read<BukuProvider>().items.where((item) => item.id == buku.id);
    if (apiBook.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data buku belum sinkron. Muat ulang katalog terlebih dahulu.')),
      );
      return;
    }

    int selectedDurasi = 1; // Default 1 hari (siswa bisa pilih 1, 2, atau 3 hari)
    DateTime selectedDate = DateTime.now();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final now = DateTime.now();
            final returnDate = selectedDate.add(Duration(days: selectedDurasi));
            final jamStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

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
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.bookmark_add_rounded, color: AppTheme.accentBlue, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Form Peminjaman Buku',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                              Text(
                                'Pilih durasi & jadwal ambil buku',
                                style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.softBlueBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          BookCoverWidget(
                            judul: buku.judul,
                            penulis: buku.namaPenulis,
                            sampulUrl: buku.sampul,
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
                                  buku.judul,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  buku.namaPenulis,
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
                    const SizedBox(height: 18),

                    // Pilihan Durasi Peminjaman (1, 2, atau 3 Hari)
                    const Text(
                      'Pilih Durasi Peminjaman',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pilih lama peminjaman (1 - 3 hari)',
                      style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final day in [1, 2, 3]) ...[
                          if (day > 1) const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () => setModalState(() => selectedDurasi = day),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: selectedDurasi == day ? AppTheme.primaryNavy : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedDurasi == day ? AppTheme.primaryNavy : const Color(0xFFCBD5E1),
                                    width: selectedDurasi == day ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '$day Hari',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: selectedDurasi == day ? Colors.white : AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      day == 1 ? '1 Hari' : (day == 3 ? '3 Hari' : '2 Hari'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: selectedDurasi == day ? Colors.white70 : AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Pilihan Waktu Pengambilan (Maksimal 5 hari dari sekarang)
                    const Text(
                      'Waktu Pengambilan Buku',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Maksimal 5 hari dari hari ini untuk mengambil buku',
                      style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 5)),
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryNavy),
                                const SizedBox(width: 10),
                                Text(
                                  '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                            const Text(
                              'Ubah Jadwal',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentBlue),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Notifikasi H-5 Jam Pengembalian Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.alarm_on_rounded, size: 20, color: Color(0xFFB45309)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Notifikasi Pengingat Pengembalian (H-5 Jam)',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Batas pengembalian: ${returnDate.day.toString().padLeft(2, '0')}/${returnDate.month.toString().padLeft(2, '0')}/${returnDate.year} pukul $jamStr WIB.\n'
                                  'Notifikasi peringatan akan aktif 5 jam sebelum jam pengembalian tersebut.',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Tombol Konfirmasi
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.of(sheetCtx).pop(true),
                        child: Text(
                          'Konfirmasi Pinjam ($selectedDurasi Hari)',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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

    if (confirmed != true || !mounted) return;

    setState(() => _isPinjamLoading = true);

    final success = await pinjamanProv.pinjamBuku(
      buku: buku,
      nis: auth.profile.nis,
      nama: auth.profile.nama,
      tanggalAmbil: '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
      durasiHari: selectedDurasi,
    );

    if (!mounted || !context.mounted) return;
    setState(() => _isPinjamLoading = false);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pinjamanProv.error ?? 'Reservasi gagal.')),
      );
      return;
    }
    context.read<BukuProvider>().decrementStock(buku.id);

    final due = selectedDate.add(Duration(days: selectedDurasi));
    final now = DateTime.now();
    final jamStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.mintGreen, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Reservasi Berhasil',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          'Buku "${buku.judul}" berhasil dipinjam selama $selectedDurasi hari atas nama ${auth.profile.nama}.\n\n'
          'Batas pengembalian: ${due.day.toString().padLeft(2, '0')}/${due.month.toString().padLeft(2, '0')}/${due.year} pukul $jamStr WIB.\n'
          'Pengingat pengembalian otomatis akan aktif 5 jam sebelum waktu jatuh tempo.',
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
}
