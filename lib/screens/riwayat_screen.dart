import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/riwayat_provider.dart';

/// Riwayat peminjaman berdasarkan NIS yang tersimpan di device.
class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final riwayat = context.read<RiwayatProvider>();
      await riwayat.loadSaved();
      await riwayat.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final riwayat = context.watch<RiwayatProvider>();

    if (riwayat.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => riwayat.load(),
      child: riwayat.error != null
          ? _ErrorRiwayat(riwayat: riwayat)
          : riwayat.riwayat.isEmpty
              ? _KosongRiwayat(riwayat: riwayat)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  itemCount: riwayat.riwayat.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final item = riwayat.riwayat[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          item.sudahDikembalikan
                              ? Icons.check_circle_rounded
                              : Icons.schedule_rounded,
                          color: item.sudahDikembalikan
                              ? Colors.green
                              : Colors.orange,
                        ),
                        title: Text(
                          item.judulBuku,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Pinjam ${item.tanggalPinjam}\n'
                          'Jatuh tempo ${item.tanggalJatuhTempo}\n'
                          'NIS ${item.nis} • ${item.namaPeminjam}',
                          style: const TextStyle(height: 1.25),
                        ),
                        trailing: Chip(
                          label: Text(
                            item.sudahDikembalikan ? 'Dikembalikan' : 'Dipinjam',
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: item.sudahDikembalikan
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.orange.withValues(alpha: 0.15),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _ErrorRiwayat extends StatelessWidget {
  const _ErrorRiwayat({required this.riwayat});

  final RiwayatProvider riwayat;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Text(riwayat.error ?? 'Terjadi kesalahan.',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                await riwayat.loadSaved();
                await riwayat.load();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _KosongRiwayat extends StatelessWidget {
  const _KosongRiwayat({required this.riwayat});

  final RiwayatProvider riwayat;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              riwayat.savedNis.isEmpty
                  ? 'Belum ada riwayat peminjaman.\n'
                      'Buka tab "Buku" → Detail → Pinjam buku untuk mulai mencatat.'
                  : 'Belum ada riwayat untuk NIS ${riwayat.savedNis}.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              // Dummy diperbolehkan PDF untuk pratinjau.
              onPressed: () => riwayat.tampilkanDummy(),
              icon: const Icon(Icons.info_outline_rounded),
              label: const Text('Tampilkan data dummy'),
            ),
          ],
        ),
      ),
    );
  }
}
