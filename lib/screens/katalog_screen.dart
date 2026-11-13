import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../providers/buku_provider.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/custom_badge.dart';
import 'detail_buku_screen.dart';

class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BukuProvider>().loadKategoris();
      context.read<BukuProvider>().loadFirst();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BukuProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bukuProvider = context.watch<BukuProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(bukuProvider: bukuProvider),
            _FilterBar(bukuProvider: bukuProvider),
            Expanded(
              child: bukuProvider.loading && bukuProvider.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : bukuProvider.error != null
                      ? _ErrorView(bukuProvider: bukuProvider)
                      : bukuProvider.items.isEmpty
                          ? _EmptyView(
                              teks: 'Belum ada buku yang cocok dengan filter. '
                                  'Coba reset filter dan refresh.')
                          : Consumer<BukuProvider>(
                              builder: (context, provider, _) {
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isTablet = constraints.maxWidth >= 600;
                                    if (isTablet) {
                                      return GridView.builder(
                                        controller: _scrollController,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 6),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.95,
                                        ),
                                        itemCount: provider.items.length +
                                            (provider.hasMore ? 1 : 0),
                                        itemBuilder: (context, index) =>
                                            _buildItem(provider, index),
                                      );
                                    }
                                    return ListView.separated(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 6),
                                      itemCount: provider.items.length +
                                          (provider.hasMore ? 1 : 0),
                                      separatorBuilder: (_, index) =>
                                          const SizedBox(height: 4),
                                      itemBuilder: (context, index) =>
                                          _buildItem(provider, index),
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BukuProvider provider, int index) {
    if (index >= provider.items.length) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    final buku = provider.items[index];
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailBukuScreen(bukuId: buku.id),
          ),
        );
      },
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
                  top: 6,
                  left: 6,
                  child: CustomBadge(
                    label: buku.isTersedia ? 'Tersedia' : 'Dipinjam',
                    type: buku.isTersedia ? BadgeType.tersedia : BadgeType.dipinjam,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
            Text(
              buku.namaPenulis,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text(
                      '${buku.rating}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Sisa ${buku.stokTersedia}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final BukuProvider bukuProvider;
  const _Header({required this.bukuProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                'Katalog Buku',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.softBlueBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${bukuProvider.items.length} Koleksi',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final BukuProvider bukuProvider;
  const _FilterBar({required this.bukuProvider});

  @override
  Widget build(BuildContext context) {
    final prov = bukuProvider;
    final categories = <DropdownMenuItem<int>>[
      const DropdownMenuItem<int>(value: -1, child: Text('Semua Kategori')),
      ...prov.kategoris.map((k) => DropdownMenuItem<int>(value: k.id, child: Text(k.nama))),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEF2F6)),
              ),
              child: TextField(
                onChanged: (val) {
                  if (val.trim().isEmpty) {
                    prov.setQuery('');
                  } else {
                    prov.setQuery(val.trim());
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Cari judul, penulis, atau kata kunci...',
                  hintStyle: TextStyle(color: AppTheme.textSubtle, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEF2F6)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: prov.kategoriId ?? -1,
                items: categories,
                onChanged: (v) {
                  if (v == -1) {
                    prov.pilihKategori(null);
                  } else {
                    prov.pilihKategori(v);
                  }
                },
                icon: const Icon(Icons.filter_list_rounded, color: AppTheme.primaryNavy),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDark,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (prov.query.isNotEmpty || prov.kategoriId != null)
            IconButton(
              onPressed: prov.reset,
              icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryNavy),
              tooltip: 'Reset filter',
            ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final BukuProvider bukuProvider;
  const _ErrorView({required this.bukuProvider});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 6),
            Text(
              bukuProvider.error ?? 'Terjadi kesalahan tidak diketahui.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => bukuProvider.loadFirst(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String teks;
  const _EmptyView({required this.teks});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              teks,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}