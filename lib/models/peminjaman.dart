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
    this.sampul,
    required this.tanggalPinjam,
    this.tanggalAmbil,
    required this.tanggalJatuhTempo,
    this.jumlahPerpanjangan = 0,
    required this.status,
    this.rating,
    this.sisaHari = 3,
    this.hariBerjalan = 0,
    this.durasiHariTotal = 3,
    this.bisaPerpanjang = true,
    this.jamPinjam,
    this.waktuJatuhTempo,
    this.sisaJam,
    this.isHampirTenggat = false,
    this.fotoBuktiUrl,
    this.tipeKembali,
    this.catatanKembali,
    this.statusReservasi,
    this.isBooking = false,
    this.buktiPendingKonfirmasi = false,
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
    final pengembalian = json['pengembalian'] is Map<String, dynamic>
        ? (json['pengembalian'] as Map<String, dynamic>)
        : null;

    int durasiHariTotal = (json['durasi_hari_total'] as num?)?.toInt() ??
        (json['durasi_pinjam'] as num?)?.toInt() ??
        3;

    final tglPinjamDt = DateTime.tryParse(json['tanggal_pinjam']?.toString() ?? '');
    final tglTempoDt = DateTime.tryParse(json['tanggal_jatuh_tempo']?.toString() ?? '');
    if (tglPinjamDt != null && tglTempoDt != null) {
      final diff = tglTempoDt.difference(tglPinjamDt).inDays;
      if (diff > 0) {
        durasiHariTotal = diff;
      }
    }
    final status = json['status']?.toString() ?? 'dipinjam';
    final sisaJam = (json['sisa_jam'] as num?)?.toInt();
    final sisaHari = (json['sisa_hari'] as num?)?.toInt() ?? (status == 'dikembalikan' ? 0 : 3);
    final isHampirTenggat = json['hampir_tenggat'] == true ||
        (status != 'dikembalikan' && ((sisaJam != null && sisaJam <= 5) || sisaHari <= 0));

    final id = (json['id'] as num?)?.toInt() ?? 0;
    final trxId = json['trx_id']?.toString() ?? 'TRX-2024-${1090 + id}';

    return Peminjaman(
      id: id,
      trxId: trxId,
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
      sampul: buku?['sampul_url']?.toString() ??
          buku?['sampul']?.toString() ??
          json['sampul_url']?.toString() ??
          json['sampul']?.toString(),
      tanggalPinjam: json['tanggal_pinjam']?.toString() ?? 'Hari ini',
      tanggalAmbil: json['tanggal_ambil']?.toString(),
      tanggalJatuhTempo: json['tanggal_jatuh_tempo']?.toString() ?? '3 Hari ke depan',
      jumlahPerpanjangan: (json['jumlah_perpanjangan'] as num?)?.toInt() ?? 0,
      status: status,
      sisaHari: sisaHari,
      hariBerjalan: (json['hari_berjalan'] as num?)?.toInt() ?? 0,
      durasiHariTotal: (json['durasi_hari_total'] as num?)?.toInt() ??
          (json['durasi_pinjam'] as num?)?.toInt() ??
          3,
      bisaPerpanjang: json['bisa_perpanjang'] != false && status != 'dikembalikan',
      rating: (json['ulasan'] is Map ? ((json['ulasan'] as Map)['rating'] as num?)?.toDouble() : null),
      jamPinjam: json['jam_pinjam']?.toString(),
      waktuJatuhTempo: json['waktu_jatuh_tempo']?.toString(),
      sisaJam: sisaJam,
      isHampirTenggat: isHampirTenggat,
      fotoBuktiUrl: pengembalian?['foto_bukti_url']?.toString() ?? json['foto_bukti_url']?.toString(),
      tipeKembali: pengembalian?['tipe_kembali']?.toString() ?? json['tipe_kembali']?.toString(),
      catatanKembali: pengembalian?['catatan']?.toString() ?? json['catatan']?.toString(),
      statusReservasi: json['status_reservasi']?.toString(),
      isBooking: json['is_booking'] == true || json['status_reservasi'] == 'booking',
      buktiPendingKonfirmasi: json['bukti_pending_konfirmasi'] == true,
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
      tanggalPinjam: 'Hari ini',
      tanggalJatuhTempo: '3 Hari ke depan',
      status: 'dipinjam',
      sisaHari: 3,
      hariBerjalan: 0,
      durasiHariTotal: 3,
      bisaPerpanjang: true,
      jamPinjam: '09:00',
      isHampirTenggat: false,
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

  final String? jamPinjam;
  final String? waktuJatuhTempo;
  final int? sisaJam;
  final bool isHampirTenggat;
  final String? fotoBuktiUrl;
  final String? tipeKembali;
  final String? catatanKembali;
  final String? statusReservasi;
  final bool isBooking;
  final bool buktiPendingKonfirmasi;

  bool get sudahDikembalikan => status == 'dikembalikan';
  bool get isKembaliMandiri => sudahDikembalikan && (fotoBuktiUrl != null || tipeKembali == 'mandiri');
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
      sampul: sampul,
      tanggalPinjam: tanggalPinjam,
      tanggalAmbil: tanggalAmbil,
      tanggalJatuhTempo: _tambahHariKeTanggal(tanggalJatuhTempo, 1),
      jumlahPerpanjangan: jumlahPerpanjangan + 1,
      status: status,
      rating: rating,
      sisaHari: sisaHari + 1,
      hariBerjalan: hariBerjalan,
      durasiHariTotal: durasiHariTotal + 1,
      bisaPerpanjang: false,
      jamPinjam: jamPinjam,
      waktuJatuhTempo: waktuJatuhTempo,
      sisaJam: (sisaJam ?? 0) + 24,
      isHampirTenggat: false,
    );
  }

  Peminjaman tandaiKembaliMandiri({String? fotoUrl, String? catatan}) {
    return Peminjaman(
      id: id,
      trxId: trxId,
      namaPeminjam: namaPeminjam,
      nis: nis,
      bukuId: bukuId,
      judulBuku: judulBuku,
      pengarang: pengarang,
      kategoriNama: kategoriNama,
      sampul: sampul,
      tanggalPinjam: tanggalPinjam,
      tanggalAmbil: tanggalAmbil,
      tanggalJatuhTempo: tanggalJatuhTempo,
      jumlahPerpanjangan: jumlahPerpanjangan,
      status: status, // status tetap dipinjam sampai admin konfirmasi
      rating: rating,
      sisaHari: sisaHari,
      hariBerjalan: hariBerjalan,
      durasiHariTotal: durasiHariTotal,
      bisaPerpanjang: false,
      jamPinjam: jamPinjam,
      waktuJatuhTempo: waktuJatuhTempo,
      sisaJam: sisaJam,
      isHampirTenggat: false,
      fotoBuktiUrl: fotoUrl ?? fotoBuktiUrl,
      tipeKembali: 'mandiri',
      catatanKembali: catatan ?? 'Dikembalikan mandiri oleh siswa di perpustakaan',
      statusReservasi: statusReservasi,
      isBooking: isBooking,
      buktiPendingKonfirmasi: true,
    );
  }
}
