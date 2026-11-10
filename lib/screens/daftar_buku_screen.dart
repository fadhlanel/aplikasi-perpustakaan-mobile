import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/buku.dart';
import '../providers/buku_provider.dart';
import 'detail_buku_screen.dart';

/// Daftar buku: support pagination (scroll ke bawah) + filter kategori.
/// Responsive: 1 kolom di ponsel, 2 kolom di tablet.
class DaftarBukuScreen extends StatefulWidget {
  const DaftarBukuScreen({super.key});

  @override
  State<DaftarBukuScreen> createState() => _DaftarBukuScreenState();
}

class _DaftarBukuScreenState extends State<DaftarBukuScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Muat ulang data dari API Laravel yang sedang berjalan.
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

    return Column(
      children: [
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
    );
  }

  Widget _buildItem(BukuProvider provider, int index) {
    final berat = index >= provider.items.length;
    if (berat) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    final buku = provider.items[index];
    return BukuCard(
      buku: buku,
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetailBukuScreen(bukuId: buku.id)),
        );
        // Saat kembali dari detail, muat ulang karena stok mungkin berubah.
        if (mounted) context.read<BukuProvider>().loadFirst();
      },
    );
  }
}

/// Kartu buku (komponen reusable juga dipakai di Search).
class BukuCard extends StatelessWidget {
  const BukuCard({
    super.key,
    required this.buku,
    this.onTap,
  });

  final Buku buku;
  final VoidCallback? onTap;

  Color get _warnaStok {
    if (buku.stokTersedia <= 0) return Colors.red.shade400;
    if (buku.stokTersedia <= 2) return Colors.orange.shade400;
    return Colors.green.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.book_rounded,
                      size: 34,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buku.judul,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${buku.namaPenulis} • ${buku.tahunTerbit}',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${buku.namaPenerbit} • ${buku.namaKategori}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    labelStyle:
                        TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                    backgroundColor: _warnaStok,
                    label: Text('Stok ${buku.stokTersedia}'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.bukuProvider});

  final BukuProvider bukuProvider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int?>(
              initialValue: bukuProvider.kategoriId,
              decoration: const InputDecoration(
                labelText: 'Filter Kategori',
                prefixIcon: Icon(Icons.category_rounded),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Semua Kategori'),
                ),
                ...bukuProvider.kategoris.map(
                  (k) => DropdownMenuItem<int?>(
                    value: k.id,
                    child: Text(k.nama),
                  ),
                ),
              ],
              onChanged: (value) => bukuProvider.pilihKategori(value),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: bukuProvider.loading
                ? null
                : () async => bukuProvider.reset(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset filter & refresh',
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.bukuProvider});

  final BukuProvider bukuProvider;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 48, color: Colors.grey.shade500),
            const SizedBox(height: 16),
            Text(
              bukuProvider.error ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => bukuProvider.loadFirst(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.teks});

  final String teks;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              teks,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
