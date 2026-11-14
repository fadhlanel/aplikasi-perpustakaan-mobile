/// Model data Transaksi Peminjaman (sesuai API & Tampilan Figma Layar 5)
class Peminjaman {
  const Peminjaman({
    required this.id,
    required this.trxId,
    required this.namaPeminjam,
    required this.nis,
    required this.bukuId,
    required this.judulBuku,
    this.pengarang = 'Oleh: Budi Raharjo, S.Kom.',
    this.kategoriNama = 'Informatika / 005.1',
    this.lokasiRak = 'Rak 3B - Kampus Utama',
    this.sampul,
    required this.tanggalPinjam,
    this.tanggalAmbil,
    required this.tanggalJatuhTempo,
    this.jumlahPerpanjangan = 0,
    required this.status,
    this.rating,
    this.sisaHari = 4,
    this.hariBerjalan = 3,
    this.durasiHariTotal = 7,
    this.bisaPerpanjang = true,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    final buku = json['buku'] is Map<String, dynamic>
        ? (json['buku'] as Map<String, dynamic>)
        : null;
    final penulis = buku?['penulis'] is Map<String, dynamic>
        ? (buku!['penulis'] as Map<String, dynamic>)
        : null;
    final kategori = buku?['kategori'] is Map<String, dynamic>
        ? (buku!['kategori'] as Map<String, dynamic>)
        : null;

    final id = (json['id'] as num?)?.toInt() ?? 1;
    final status = json['status']?.toString() ?? 'dipinjam';

    return Peminjaman(
      id: id,
      trxId: json['trx_id']?.toString() ?? 'TRX-2024-${1090 + id}',
      namaPeminjam: json['nama_peminjam']?.toString() ?? 'Muhammad Irsyadul I.',
      nis: json['nis']?.toString() ?? '2122.10.490',
      bukuId: (json['buku_id'] as num?)?.toInt() ?? 1,
      judulBuku: buku?['judul']?.toString() ??
          json['judul_buku']?.toString() ??
          'Pemrograman Web & Mobile dengan Flutter',
      pengarang: penulis != null
          ? 'Oleh: ${penulis['nama']}'
          : (json['pengarang']?.toString() ?? 'Oleh: Budi Raharjo, S.Kom.'),
      kategoriNama: kategori != null
          ? 'Informatika / ${kategori['nama']}'
          : (json['kategori_nama']?.toString() ?? 'Informatika / 005.1'),
      lokasiRak: json['lokasi_rak']?.toString() ?? 'Rak 3B - Kampus Utama',
      sampul: buku?['sampul_url']?.toString() ??
          buku?['sampul']?.toString() ??
          json['sampul_url']?.toString() ??
          json['sampul']?.toString(),
      tanggalPinjam: json['tanggal_pinjam']?.toString() ?? '19 Okt 2024',
      tanggalAmbil: json['tanggal_ambil']?.toString(),
      tanggalJatuhTempo: json['tanggal_jatuh_tempo']?.toString() ?? '26 Okt 2024',
      jumlahPerpanjangan: (json['jumlah_perpanjangan'] as num?)?.toInt() ?? 0,
      status: status,
      sisaHari: (json['sisa_hari'] as num?)?.toInt() ?? (status == 'dikembalikan' ? 0 : 4),
      hariBerjalan: (json['hari_berjalan'] as num?)?.toInt() ?? 3,
      durasiHariTotal: (json['durasi_hari_total'] as num?)?.toInt() ?? (json['durasi_pinjam'] as num?)?.toInt() ?? 7,
      bisaPerpanjang: json['bisa_perpanjang'] != false && status != 'dikembalikan',
      rating: (json['ulasan'] is Map ? ((json['ulasan'] as Map)['rating'] as num?)?.toDouble() : null),
    );
  }

  factory Peminjaman.dummy() => Peminjaman.dummyUtama();

  factory Peminjaman.dummyUtama() {
    return const Peminjaman(
      id: 1,
      trxId: 'TRX-2024-1095',
      namaPeminjam: 'Muhammad Irsyadul I.',
      nis: '2122.10.490',
      bukuId: 1,
      judulBuku: 'Pemrograman Web & Mobile dengan Flutter',
      pengarang: 'Oleh: Rahmat Hidayat, M.Kom',
      kategoriNama: 'Informatika / 005.1',
      lokasiRak: 'Rak 3B - Kampus Utama',
      tanggalPinjam: '19 Okt 2024',
      tanggalJatuhTempo: '26 Okt 2024',
      status: 'dipinjam',
      sisaHari: 4,
      hariBerjalan: 3,
      durasiHariTotal: 7,
      bisaPerpanjang: true,
    );
  }

  final int id;
  final String trxId;
  final String namaPeminjam;
  final String nis;
  final int bukuId;
  final String judulBuku;
  final String pengarang;
  final String kategoriNama;
  final String lokasiRak;
  final String? sampul;
  final String tanggalPinjam;
  final String? tanggalAmbil;
  final String tanggalJatuhTempo;
  final int jumlahPerpanjangan;
  final String status;
  final double? rating;
  final int sisaHari;
  final int hariBerjalan;
  final int durasiHariTotal;
  final bool bisaPerpanjang;

  bool get sudahDikembalikan => status == 'dikembalikan';
  double get persentaseWaktu =>
      durasiHariTotal > 0 ? (hariBerjalan / durasiHariTotal).clamp(0.0, 1.0) : 0.0;
  int get persentaseInt => (persentaseWaktu * 100).toInt();

  static String _tambahHariKeTanggal(String? tanggal, int hari) {
    if (tanggal == null || tanggal.isEmpty) {
      return DateTime.now().add(Duration(days: hari)).toIso8601String();
    }
    final parsed = DateTime.tryParse(tanggal);
    if (parsed == null) return tanggal;
    final baru = parsed.add(Duration(days: hari));
    return '${baru.year}-${baru.month.toString().padLeft(2, '0')}-${baru.day.toString().padLeft(2, '0')}';
  }

  Peminjaman perpanjangSatuHari() {
    return Peminjaman(
      id: id,
      trxId: trxId,
      namaPeminjam: namaPeminjam,
      nis: nis,
      bukuId: bukuId,
      judulBuku: judulBuku,
      pengarang: pengarang,
      kategoriNama: kategoriNama,
      lokasiRak: lokasiRak,
      sampul: sampul,
      tanggalPinjam: tanggalPinjam,
      tanggalAmbil: tanggalAmbil,
      tanggalJatuhTempo: _tambahHariKeTanggal(tanggalJatuhTempo, 1),
      jumlahPerpanjangan: jumlahPerpanjangan + 1,
      status: status,
      rating: rating,
      sisaHari: sisaHari + 7,
      hariBerjalan: hariBerjalan,
      durasiHariTotal: durasiHariTotal + 7,
      bisaPerpanjang: false,
    );
  }
}
