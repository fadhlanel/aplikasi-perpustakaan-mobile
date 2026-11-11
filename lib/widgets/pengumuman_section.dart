import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/app_theme.dart';
import '../models/pengumuman.dart';
import '../providers/pengumuman_provider.dart';

/// Section pengumuman Beranda. Semua state (memuat, kosong, error, offline)
/// berasal dari GET /pengumuman, bukan data contoh.
class PengumumanSection extends StatelessWidget {
  const PengumumanSection({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PengumumanProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengumuman',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Informasi terbaru dari perpustakaan',
          style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 10),
        if (prov.loading && prov.items.isEmpty)
          const _StatusCard(
            icon: Icons.campaign_outlined,
            title: 'Memuat pengumuman',
            message: 'Mengambil pengumuman terbaru dari server.',
            showProgress: true,
          )
        else ...[
          if (prov.offline && prov.items.isNotEmpty) ...[
            _StatusCard(
              icon: Icons.cloud_off_rounded,
              title: 'Mode offline',
              message:
                  'Menampilkan ${prov.items.length} pengumuman tersimpan. Tarik ke bawah untuk menyegarkan.',
              tone: _Tone.warning,
            ),
            const SizedBox(height: 8),
          ],
          if (prov.error != null)
            _StatusCard(
              icon: Icons.error_outline_rounded,
              title: 'Pengumuman gagal dimuat',
              message: prov.error!,
              tone: _Tone.danger,
              actionLabel: 'Coba lagi',
              onAction: () => prov.load(),
            )
          else if (prov.items.isEmpty)
            _StatusCard(
              icon: Icons.inbox_rounded,
              title: prov.offline
                  ? 'Pengumuman tidak tersimpan'
                  : 'Belum ada pengumuman',
              message: prov.offline
                  ? 'Perangkat offline dan belum ada pengumuman yang pernah dimuat.'
                  : 'Pengumuman dari perpustakaan akan muncul di sini.',
              actionLabel: 'Muat ulang',
              onAction: () => prov.load(),
            )
          else
            for (final item in prov.items) ...[
              _PengumumanCard(item: item),
              const SizedBox(height: 8),
            ],
        ],
      ],
    );
  }
}

enum _Tone { neutral, warning, danger }

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.message,
    this.tone = _Tone.neutral,
    this.showProgress = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final _Tone tone;
  final bool showProgress;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final (background, border, titleColor, bodyColor) = switch (tone) {
      _Tone.danger => (
          const Color(0xFFFEF2F2),
          const Color(0xFFFECACA),
          const Color(0xFF991B1B),
          const Color(0xFF7F1D1D),
        ),
      _Tone.warning => (
          const Color(0xFFFFFBEB),
          const Color(0xFFFDE68A),
          const Color(0xFF92400E),
          const Color(0xFF78350F),
        ),
      _Tone.neutral => (
          Colors.white,
          const Color(0xFFEEF2F6),
          AppTheme.textDark,
          AppTheme.textMuted,
        ),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tone == _Tone.neutral
                        ? AppTheme.softBlueBackground
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: showProgress
                      ? const Padding(
                          padding: EdgeInsets.all(9),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.accentBlue,
                          ),
                        )
                      : Icon(icon, size: 19, color: AppTheme.primaryNavy),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.35,
                          color: bodyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (actionLabel != null && onAction != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    foregroundColor: tone == _Tone.danger
                        ? const Color(0xFF991B1B)
                        : AppTheme.primaryBlue,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PengumumanCard extends StatelessWidget {
  const _PengumumanCard({required this.item});

  final Pengumuman item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetail(context, item),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEF2F6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.softBlueBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.campaign_outlined,
                size: 20,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.isi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  if (item.diterbitkanPada != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.event_outlined,
                            size: 12, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(item.diterbitkanPada!),
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PengumumanDetailSheet extends StatefulWidget {
  const _PengumumanDetailSheet({required this.item});

  final Pengumuman item;

  @override
  State<_PengumumanDetailSheet> createState() => _PengumumanDetailSheetState();
}

class _PengumumanDetailSheetState extends State<_PengumumanDetailSheet> {
  late Future<Pengumuman> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<PengumumanProvider>().fetchDetail(widget.item.id);
  }

  void _retry() {
    setState(() {
      _future = context.read<PengumumanProvider>().fetchDetail(widget.item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: FutureBuilder<Pengumuman>(
            future: _future,
            builder: (context, snapshot) {
              // Isi dari daftar tetap tampil saat detail sedang dimuat.
              final data = snapshot.data ?? widget.item;
              final failed = snapshot.hasError;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.judul,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.event_outlined,
                            size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(data.diterbitkanPada),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) ...[
                          const SizedBox(width: 12),
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.accentBlue,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Memuat detail',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      data.isi,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: AppTheme.textDark,
                      ),
                    ),
                    if (failed) ...[
                      const SizedBox(height: 14),
                      _StatusCard(
                        icon: Icons.error_outline_rounded,
                        title: 'Detail terbaru gagal dimuat',
                        message: switch (snapshot.error) {
                          ApiException e => e.message,
                          final Object e => e.toString(),
                          _ => 'Periksa koneksi lalu coba lagi.',
                        },
                        tone: _Tone.danger,
                        actionLabel: 'Coba lagi',
                        onAction: _retry,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void _showDetail(BuildContext context, Pengumuman item) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) => _PengumumanDetailSheet(item: item),
  );
}

String _formatDate(DateTime? dt) {
  if (dt == null) return 'Tanggal belum tersedia';
  final local = dt.toLocal();
  return '${local.day}/${local.month}/${local.year}';
}
