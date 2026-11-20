import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/network_service.dart';
import '../models/buku.dart';
import '../models/kategori.dart';
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
  final Set<int> _ratingPrompted = <int>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        context.read<PengumumanProvider>().ensureLoaded();
        context.read<ConfigProvider>().load();
        await context.read<BukuProvider>().loadFirst();
        context.read<BukuProvider>().loadKategoris();
        await context.read<PinjamanProvider>().fetchApiLoans();
        if (mounted) await _promptPendingRating();
        _startSyncTimer();
      }
    });
  }

  Future<void> _promptPendingRating() async {
    final provider = context.read<PinjamanProvider>();
    final pendingLoans = provider.historyLoans.where(
      (item) => item.sudahDikembalikan &&
          item.rating == null &&
          !_ratingPrompted.contains(item.id),
    );
    if (pendingLoans.isEmpty) return;
    final loan = pendingLoans.first;
    _ratingPrompted.add(loan.id);
    var rating = 0;
    var submitting = false;
    final komentar = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Text(
                    'Beri rating buku',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bagaimana pengalamanmu membaca "${loan.judulBuku}"?',
                    style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  // Star rating
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(5, (index) => Semantics(
                      label: '${index + 1} bintang',
                      button: true,
                      onTap: () => setState(() => rating = index + 1),
                      child: IconButton(
                        tooltip: '${index + 1} bintang',
                        onPressed: () => setState(() => rating = index + 1),
                        icon: Icon(
                          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 36,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: TextField(
                      controller: komentar,
                      maxLines: 3,
                      minLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Komentar (opsional)',
                        hintText: 'Tulis pengalamanmu...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: submitting ? null : () => Navigator.pop(dialogContext, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Nanti', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: submitting || rating == 0 ? null : () async {
                            setState(() => submitting = true);
                            final ok = await provider.submitRating(
                              peminjamanId: loan.id,
                              rating: rating,
                              komentar: komentar.text,
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext, ok);
                            }
                            if (ok) provider.fetchApiLoans();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                          child: submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Kirim rating', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    komentar.dispose();
    if (submitted != true) _ratingPrompted.remove(loan.id);
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) => _syncData());
  }

  Future<void> _syncData() async {
    if (_syncing || !mounted) return;
    _syncing = true;
    try {
      final network = context.read<NetworkService>();
      await Future.wait([
        context.read<BukuProvider>().loadFirst(),
        context.read<PinjamanProvider>().fetchApiLoans(),
        context.read<PengumumanProvider>().load(),
        context.read<ConfigProvider>().load(),
        network.checkConnection(),
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

  void _showHomeNotificationCenter(BuildContext context, PinjamanProvider pinjamanProv, NetworkService network) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final activeLoans = pinjamanProv.activeLoans;
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
                      'Notifikasi Pengembalian Buku',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pengingat aktif otomatis 5 jam sebelum waktu jatuh tempo buku berakhir',
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
                                  'Peringatan: ${loan.judulBuku}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Waktu peminjaman tersisa kurang dari 5 jam lagi (${loan.tanggalJatuhTempo}). Anda dapat mengembalikan lebih awal dengan menekan tombol kembalikan dan foto bukti di perpustakaan.',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF78350F), height: 1.3),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D9488),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                widget.onNavigateTab?.call(2);
                              },
                              icon: const Icon(Icons.camera_alt_rounded, size: 14),
                              label: const Text('Kembalikan Sekarang', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                            ),
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
                        const Icon(Icons.check_circle_outline_rounded, color: AppTheme.primaryNavy, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Batas peminjaman Anda masih aman. Notifikasi otomatis akan muncul 5 jam sebelum jatuh tempo.',
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
                        'Tidak ada peminjaman aktif. Semua buku telah dikembalikan.',
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

  void _openDetail(Buku buku) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailBukuScreen(bukuId: buku.id),
      ),
    );
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
                    Flexible(
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
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  config.namaPerpustakaan.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Status Keterhubungan REST API
                        const ApiStatusBadge(),
                        IconButton(
                          onPressed: () => _showHomeNotificationCenter(context, pinjamanProv, network),
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

                // Badge status layanan perpustakaan (selalu tampil)
                ...[ 
                  const SizedBox(height: 8),
                  Row(
                    children: [
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

                        // Banner peringatan H-5 Jam jika hampir jatuh tempo
                        if (activeLoan.isHampirTenggat) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade400.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.alarm_on_rounded, size: 15, color: Colors.amber),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Kurang dari 5 jam batas pengembalian! Anda bisa kembalikan sekarang dengan foto bukti di perpustakaan.',
                                    style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold, height: 1.25),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

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
                            Flexible(
                              child: Text(
                                'Dipinjam: ${activeLoan.tanggalPinjam}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                InkWell(
                                  onTap: () => widget.onNavigateTab?.call(2),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.camera_alt_outlined, size: 13, color: AppTheme.cyanAccent),
                                      SizedBox(width: 4),
                                      Text(
                                        'Kembalikan Buku',
                                        style: TextStyle(
                                          color: AppTheme.cyanAccent,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => widget.onNavigateTab?.call(2),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Perpanjang',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white70),
                                    ],
                                  ),
                                ),
                              ],
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
                      _buildCategoryChip(
                        'Semua',
                        Icons.grid_view_rounded,
                        bukuProv,
                        null,
                      ),
                      for (final kategori in bukuProv.kategoris) ...[
                        const SizedBox(width: 8),
                        _buildCategoryChip(
                          kategori.nama,
                          _iconForKategori(kategori.nama),
                          bukuProv,
                          kategori,
                        ),
                      ],
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
                  height: 345,
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
                    childAspectRatio: 0.54,
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

  Widget _buildCategoryChip(String title, IconData icon, BukuProvider provider, Kategori? kategori) {
    final isSelected = kategori == null
        ? provider.kategoriId == null
        : provider.kategoriId == kategori.id;
    return InkWell(
      onTap: () => provider.pilihKategori(kategori?.id),
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

  IconData _iconForKategori(String nama) {
    final lower = nama.toLowerCase();
    if (lower.contains('rpl') || lower.contains('it') || lower.contains('teknologi') || lower.contains('software')) {
      return Icons.code_rounded;
    }
    if (lower.contains('sains') || lower.contains('fisika') || lower.contains('matematika')) {
      return Icons.science_outlined;
    }
    if (lower.contains('novel') || lower.contains('fiksi')) {
      return Icons.auto_stories_outlined;
    }
    if (lower.contains('sejarah') || lower.contains('sosial')) {
      return Icons.history_edu_rounded;
    }
    return Icons.category_rounded;
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
                    width: 140,
                    height: 195,
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
            // Cover
            Stack(
              children: [
                Center(
                  child: BookCoverWidget(
                    judul: buku.judul,
                    penulis: buku.namaPenulis,
                    sampulUrl: buku.sampul,
                    width: 140,
                    height: 195,
                    borderRadius: 10,
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
