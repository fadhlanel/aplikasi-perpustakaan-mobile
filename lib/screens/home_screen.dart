import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/network_service.dart';
import '../models/buku.dart';
import '../providers/auth_provider.dart';
import '../providers/buku_provider.dart';
import '../providers/config_provider.dart';
import '../providers/pengumuman_provider.dart';
import '../providers/pinjaman_provider.dart';
import '../widgets/api_status_badge.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/custom_badge.dart';
import '../widgets/pengumuman_section.dart';
import 'detail_buku_screen.dart';
import 'pinjaman_screen.dart';

/// Screen 3: Beranda (Home Screen)
/// Sesuai 100% dengan Mockup Desain Figma (Foto 2)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigateTab});

  final void Function(int index)? onNavigateTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  Timer? _syncTimer;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PengumumanProvider>().ensureLoaded();
        context.read<ConfigProvider>().load();
        context.read<BukuProvider>().loadFirst();
        context.read<PinjamanProvider>().fetchApiLoans();
        _startSyncTimer();
      }
    });
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) => _syncData());
  }

  Future<void> _syncData() async {
    if (_syncing || !mounted) return;
    _syncing = true;
    try {
      await Future.wait([
        context.read<BukuProvider>().loadFirst(),
        context.read<PinjamanProvider>().fetchApiLoans(),
        context.read<PengumumanProvider>().load(),
        context.read<ConfigProvider>().load(),
      ]);
    } finally {
      _syncing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      _syncData();
      _startSyncTimer();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _syncTimer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _syncTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Buku buku) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailBukuScreen(bukuId: buku.id),
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bukuProv = context.watch<BukuProvider>();
    final pengumumanProv = context.watch<PengumumanProvider>();
    final config = context.watch<ConfigProvider>();
    final pinjamanProv = context.watch<PinjamanProvider>();
    final network = context.watch<NetworkService>();
    final profile = auth.profile;

    final activeLoan = pinjamanProv.activeLoans.isNotEmpty
        ? pinjamanProv.activeLoans.first
        : null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await network.checkConnection();
            await config.load();
            await bukuProv.loadFirst();
            await pengumumanProv.load();
            await pinjamanProv.fetchApiLoans();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.softBlueBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: AppTheme.primaryBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              config.namaPerpustakaan.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const Text(
                              'Beranda',
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
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status Keterhubungan REST API
                        const ApiStatusBadge(),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () {
                            final sync = network.lastSyncTime;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  sync != null
                                      ? 'Data terakhir disinkronkan ke database: ${_relativeTime(sync)}'
                                      : 'Belum ada sinkronisasi data. Tarik ke bawah untuk sinkron.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_outlined, size: 24),
                          color: AppTheme.primaryNavy,
                        ),
                        InkWell(
                          onTap: () => widget.onNavigateTab?.call(3),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
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
                        ),
                      ],
                    ),
                  ],
                ),

                // Indikator sinkronisasi database terakhir
                if (network.lastSyncTime != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.sync_rounded,
                          size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'Sinkron ke database: ${_relativeTime(network.lastSyncTime!)}',
                        style: const TextStyle(
                            fontSize: 10.5, color: AppTheme.textMuted),
                      ),
                      const Spacer(),
                      // Status Layanan Perpustakaan dari Web Admin
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: config.statusLayanan == 'aktif'
                              ? const Color(0xFFD1FAE5)
                              : config.statusLayanan == 'pemeliharaan'
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          config.statusLabel,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: config.statusLayanan == 'aktif'
                                ? const Color(0xFF065F46)
                                : config.statusLayanan == 'pemeliharaan'
                                    ? const Color(0xFF92400E)
                                    : const Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Notifikasi Konektivitas Offline / Tanpa Internet
                if (network.hasNoInternet) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 20, color: AppTheme.dangerRed),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Perangkat Tidak Terhubung ke Internet',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Silakan hubungkan perangkat ke internet. Data yang ditampilkan saat ini adalah data tersimpan terakhir.',
                                style: TextStyle(fontSize: 11, color: Color(0xFF7F1D1D), height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (network.isApiOffline) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cloud_off_rounded, size: 20, color: AppTheme.amberWarning),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Server REST API Tidak Terjangkau (Mode Offline)',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Koneksi internet aktif, namun backend perpustakaan belum dapat dihubungi. Menampilkan data lokal terakhir.',
                                style: TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // User Greeting Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.softBlueBackground,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      // Avatar with online green dot
                      Stack(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 32,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.mintGreen,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Hai, ${profile.nama}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD1FAE5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle, size: 6, color: AppTheme.mintGreen),
                                      SizedBox(width: 4),
                                      Text(
                                        'Anggota Aktif',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF065F46),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'NIS: ${profile.nis} • ${profile.kelas}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: AppTheme.accentBlue,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Pengumuman perpustakaan (GET /pengumuman)
                const PengumumanSection(),
                const SizedBox(height: 18),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (val) {
                      bukuProv.setQuery(val.trim());
                      widget.onNavigateTab?.call(1);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari judul buku atau penulis...',
                      hintStyle: const TextStyle(color: AppTheme.textSubtle, fontSize: 13.5),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune_rounded, color: AppTheme.primaryNavy),
                        onPressed: () => widget.onNavigateTab?.call(1),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Status Peminjaman Anda Card
                if (activeLoan != null) ...[
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PinjamanScreen()),
                    ),
                    child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0F2654),
                          Color(0xFF133678),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F2654).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
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
                            const Row(
                              children: [
                                Icon(Icons.schedule_rounded, color: AppTheme.cyanAccent, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'STATUS PEMINJAMAN ANDA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '1 Buku Aktif',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Card Content
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BookCoverWidget(
                              judul: activeLoan.judulBuku,
                              penulis: activeLoan.pengarang,
                              sampulUrl: activeLoan.sampul,
                              width: 64,
                              height: 90,
                              borderRadius: 8,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TEKNOLOGI INFORMASI',
                                    style: TextStyle(
                                      color: AppTheme.cyanAccent.withValues(alpha: 0.9),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activeLoan.judulBuku,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    activeLoan.pengarang,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.alarm_rounded,
                                            size: 13,
                                            color: AppTheme.amberWarning,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Sisa ${activeLoan.sisaHari} hari lagi',
                                            style: const TextStyle(
                                              color: AppTheme.amberWarning,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Jatuh Tempo: ${activeLoan.tanggalJatuhTempo}',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: activeLoan.persentaseWaktu,
                            minHeight: 5,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.cyanAccent),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Footer Row
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              'Dipinjam: ${activeLoan.tanggalPinjam}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 11,
                              ),
                            ),
                            InkWell(
                              onTap: () => widget.onNavigateTab?.call(2),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Perpanjang Pinjaman',
                                    style: TextStyle(
                                      color: AppTheme.cyanAccent,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.cyanAccent),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],

                // Section: Kategori Buku
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kategori Buku',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigateTab?.call(1),
                      child: const Text(
                        'Semua Kategori',
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

                // Horizontal Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('Semua', Icons.grid_view_rounded, bukuProv),
                      const SizedBox(width: 8),
                      _buildCategoryChip('RPL & IT', Icons.code_rounded, bukuProv),
                      const SizedBox(width: 8),
                      _buildCategoryChip('Sains & Fisika', Icons.science_outlined, bukuProv),
                      const SizedBox(width: 8),
                      _buildCategoryChip('Novel & Fiksi', Icons.auto_stories_outlined, bukuProv),
                      const SizedBox(width: 8),
                      _buildCategoryChip('Sejarah & Sosial', Icons.history_edu_rounded, bukuProv),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Section: Rekomendasi Terpopuler
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rekomendasi Terpopuler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Paling sering dipinjam pekan ini',
                          style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.softBlueBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Top 10',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Popular Books Horizontal List
                SizedBox(
                  height: 290,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: bukuProv.filteredPopularBooks.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final buku = bukuProv.filteredPopularBooks[index];
                      return _buildPopularCard(buku, bukuProv);
                    },
                  ),
                ),
                const SizedBox(height: 22),

                // Section: Koleksi Terbaru Ditambahkan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Koleksi Terbaru Ditambahkan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Koleksi buku kurikulum & referensi baru',
                          style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigateTab?.call(1),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.accentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2-Column Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.64,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: bukuProv.filteredLatestBooks.length,
                  itemBuilder: (context, index) {
                    final buku = bukuProv.filteredLatestBooks[index];
                    return _buildLatestCard(buku);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String title, IconData icon, BukuProvider provider) {
    final isSelected = provider.selectedCategoryName == title;
    return InkWell(
      onTap: () => provider.selectCategory(title),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryNavy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryNavy : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppTheme.primaryNavy,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.primaryNavy,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCard(Buku buku, BukuProvider provider) {
    return InkWell(
      onTap: () => _openDetail(buku),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(10),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover with badges
            Stack(
              children: [
                Center(
                  child: BookCoverWidget(
                    judul: buku.judul,
                    penulis: buku.namaPenulis,
                    sampulUrl: buku.sampul,
                    width: 155,
                    height: 140,
                    borderRadius: 10,
                  ),
                ),
                // Top-left availability badge
                Positioned(
                  top: 6,
                  left: 6,
                  child: CustomBadge(
                    label: buku.isTersedia ? 'Tersedia' : 'Dipinjam',
                    type: buku.isTersedia ? BadgeType.tersedia : BadgeType.dipinjam,
                    fontSize: 9.5,
                  ),
                ),
                // Bottom-right rating badge
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          '${buku.rating}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Call number
            Text(
              buku.kodePanggil,
              style: const TextStyle(fontSize: 10, color: AppTheme.textSubtle, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),

            // Title
            Text(
              buku.judul,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),

            // Author
            Text(
              buku.namaPenulis,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
            const Spacer(),

            // Footer info + action icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: buku.isTersedia ? const Color(0xFFF1F5F9) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    buku.isTersedia ? 'Sisa ${buku.stokTersedia} Buku' : 'Antrean (2)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: buku.isTersedia ? AppTheme.textDark : AppTheme.dangerRed,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => provider.toggleBookmark(buku.id),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.softBlueBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      buku.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      size: 16,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestCard(Buku buku) {
    return InkWell(
      onTap: () => _openDetail(buku),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover with rack chip
            Stack(
              children: [
                Center(
                  child: BookCoverWidget(
                    judul: buku.judul,
                    penulis: buku.namaPenulis,
                    sampulUrl: buku.sampul,
                    width: 150,
                    height: 125,
                    borderRadius: 10,
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shelves, size: 11, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Rak-04',
                          style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              buku.judul,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),

            // Author
            Text(
              buku.namaPenulis,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
            ),
            const Spacer(),

            // Status and info button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  buku.isTersedia ? 'Tersedia' : 'Dipinjam',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: buku.isTersedia ? AppTheme.mintGreen : AppTheme.textMuted,
                  ),
                ),
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppTheme.primaryNavy,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
