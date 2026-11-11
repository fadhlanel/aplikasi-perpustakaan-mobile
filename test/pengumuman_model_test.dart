import 'package:flutter_test/flutter_test.dart';
import 'package:pustaka_digital/models/pengumuman.dart';

void main() {
  test('Pengumuman.fromJson memakai field endpoint, created_at sebagai fallback', () {
    final item = Pengumuman.fromJson({
      'id': 7,
      'judul': 'Jam layanan',
      'isi': 'Perpustakaan tutup pukul 15.00.',
      'aktif': true,
      'diterbitkan_pada': null,
      'created_at': '2026-11-11T09:30:00.000000Z',
    });

    expect(item.id, 7);
    expect(item.judul, 'Jam layanan');
    expect(item.isi, 'Perpustakaan tutup pukul 15.00.');
    expect(item.diterbitkanPada, DateTime.utc(2026, 11, 11, 9, 30));

    final published = Pengumuman.fromJson({
      'id': 8,
      'judul': 'Libur',
      'isi': 'Libur semester.',
      'diterbitkan_pada': '2026-11-10T08:00:00.000000Z',
      'created_at': '2026-11-11T09:30:00.000000Z',
    });

    expect(published.diterbitkanPada, DateTime.utc(2026, 11, 10, 8));
  });
}
