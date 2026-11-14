import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../core/offline_cache.dart';
import '../models/buku.dart';
import '../models/peminjaman.dart';

class PinjamanProvider extends ChangeNotifier {
  PinjamanProvider();

  int selectedTab = 0; // 0: Sedang Dipinjam, 1: Riwayat Selesai, 2: Denda & Telat
  bool loading = false;
  String? error;

  List<Peminjaman> activeLoans = <Peminjaman>[];
  List<Peminjaman> historyLoans = <Peminjaman>[];
  List<Peminjaman> dendaLoans = <Peminjaman>[];

  /*
  void _initDefaultLoans() {
    activeLoans = [
      Peminjaman.dummyUtama(),
    ];

    historyLoans = [
      const Peminjaman(
        id: 11,
        trxId: 'TRX-2024-1080',
        namaPeminjam: 'Muhammad Irsyadul I.',
        nis: '2122.10.490',
        bukuId: 101,
        judulBuku: 'Clean Architecture in Action',
        pengarang: 'Oleh: Robert C. Martin',
        kategoriNama: 'Informatika / 005.1',
        lokasiRak: 'Rak 3B - Kampus Utama',
        tanggalPinjam: '01 Okt 2024',
        tanggalJatuhTempo: '08 Okt 2024',
        status: 'dikembalikan',
        sisaHari: 0,
        hariBerjalan: 7,
        durasiHariTotal: 7,
        bisaPerpanjang: false,
      ),
      const Peminjaman(
        id: 12,
        trxId: 'TRX-2024-1075',
        namaPeminjam: 'Muhammad Irsyadul I.',
        nis: '2122.10.490',
        bukuId: 102,
        judulBuku: 'Atomic Habits',
        pengarang: 'Oleh: James Clear',
        kategoriNama: 'Psikologi / 158.1',
        lokasiRak: 'Rak PSI-02',
        tanggalPinjam: '15 Sep 2024',
        tanggalJatuhTempo: '22 Sep 2024',
        status: 'dikembalikan',
        sisaHari: 0,
        hariBerjalan: 7,
        durasiHariTotal: 7,
        bisaPerpanjang: false,
      ),
      const Peminjaman(
        id: 13,
        trxId: 'TRX-2024-1060',
        namaPeminjam: 'Muhammad Irsyadul I.',
        nis: '2122.10.490',
        bukuId: 201,
        judulBuku: 'Machine Learning dengan Python',
        pengarang: 'Oleh: Dr. Indrajit & Tim',
        kategoriNama: 'Informatika / 006.3',
        lokasiRak: 'Rak-04',
        tanggalPinjam: '01 Sep 2024',
        tanggalJatuhTempo: '08 Sep 2024',
        status: 'dikembalikan',
        sisaHari: 0,
        hariBerjalan: 7,
        durasiHariTotal: 7,
        bisaPerpanjang: false,
      ),
      const Peminjaman(
        id: 14,
        trxId: 'TRX-2024-1052',
        namaPeminjam: 'Muhammad Irsyadul I.',
        nis: '2122.10.490',
        bukuId: 203,
        judulBuku: 'UI/UX Design Praktis',
        pengarang: 'Oleh: Doni Prasetyo',
        kategoriNama: 'Desain / 741.6',
        lokasiRak: 'Rak-04',
        tanggalPinjam: '12 Agu 2024',
        tanggalJatuhTempo: '19 Agu 2024',
        status: 'dikembalikan',
        sisaHari: 0,
        hariBerjalan: 7,
        durasiHariTotal: 7,
        bisaPerpanjang: false,
      ),
      const Peminjaman(
        id: 15,
        trxId: 'TRX-2024-1044',
        namaPeminjam: 'Muhammad Irsyadul I.',
        nis: '2122.10.490',
        bukuId: 204,
        judulBuku: 'Revolusi Digital RI',
        pengarang: 'Oleh: Hendro Wibowo',
        kategoriNama: 'Sejarah / 959.8',
        lokasiRak: 'Rak-04',
        tanggalPinjam: '20 Jul 2024',
        tanggalJatuhTempo: '27 Jul 2024',
        status: 'dikembalikan',
        sisaHari: 0,
        hariBerjalan: 7,
        durasiHariTotal: 7,
        bisaPerpanjang: false,
      ),
    ];

    dendaLoans = [];
  }

  */

  void setTab(int tabIndex) {
    selectedTab = tabIndex;
    notifyListeners();
  }

  Future<bool> pinjamBuku({
    required Buku buku,
    required String nis,
    required String nama,
    String? tanggalAmbil,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await ApiClient.postJson('/peminjaman', body: {
        'buku_id': buku.id,
        'nis': nis,
        'nama_peminjam': nama,
        'tanggal_ambil': tanggalAmbil,
      });
    } on ApiException catch (e) {
      if (!e.isNetworkError) {
        // Error HTTP (4xx/5xx): jangan buat pinjaman lokal, tampilkan pesan.
        loading = false;
        error = e.message;
        notifyListeners();
        return false;
      }
      loading = false;
      error = 'Server tidak dapat dijangkau. Data lokal tidak digunakan.';
      notifyListeners();
      return false;
    } catch (_) {
      loading = false;
      notifyListeners();
      return false;
    }

    final newLoan = Peminjaman(
      id: DateTime.now().millisecondsSinceEpoch,
      trxId: 'TRX-2024-${1100 + activeLoans.length + 1}',
      namaPeminjam: nama,
      nis: nis,
      bukuId: buku.id,
      judulBuku: buku.judul,
      pengarang: 'Oleh: ${buku.namaPenulis}',
      kategoriNama: 'Informatika / ${buku.namaKategori}',
      lokasiRak: buku.lokasiRak,
      tanggalPinjam: 'Hari ini',
      tanggalJatuhTempo: tanggalAmbil ?? '3 Hari ke depan',
      status: 'dipinjam',
      sisaHari: 7,
      hariBerjalan: 0,
      durasiHariTotal: 7,
      bisaPerpanjang: true,
    );

    activeLoans = [newLoan, ...activeLoans];
    loading = false;
    notifyListeners();
    return true;
  }

  Future<bool> perpanjangPinjaman(int peminjamanId, {int days = 1}) async {
    if (!activeLoans.any((item) => item.id == peminjamanId)) {
      return false;
    }
    try {
      final response = await ApiClient.postJson('/peminjaman/$peminjamanId/perpanjang', body: {'durasi_hari': days});
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        final updated = Peminjaman.fromJson(data);
        activeLoans = activeLoans.map((item) => item.id == peminjamanId ? updated : item).toList();
        notifyListeners();
        return true;
      }
    } catch (_) {
      // Fallback lokal saat API tidak tersedia.
    }

    bool success = false;
    activeLoans = activeLoans.map((loan) {
      if (loan.id == peminjamanId && loan.bisaPerpanjang) {
        success = true;
        // Gunakan days baru untuk perpanjangan
        // Implementasi disesuaikan jika tersedia
        return loan.perpanjangSatuHari(); // diganti nanti setelah API siap
      }
      return loan;
    }).toList();

    notifyListeners();
    return success;
  }

  Future<bool> submitRating({
    required int peminjamanId,
    required int rating,
    String? komentar,
  }) async {
    try {
      final response = await ApiClient.postJson(
        '/peminjaman/$peminjamanId/rating',
        body: {'rating': rating, if (komentar != null && komentar.trim().isNotEmpty) 'komentar': komentar.trim()},
      );
      final raw = response['data'];
      if (raw is Map<String, dynamic>) {
        final updated = Peminjaman.fromJson(raw);
        historyLoans = historyLoans.map((item) => item.id == peminjamanId ? updated : item).toList();
      }
      return true;
    } catch (e) {
      error = e is ApiException ? e.message : 'Rating gagal disimpan.';
      return false;
    }
  }

  Future<void> fetchApiLoans() async {
    activeLoans = <Peminjaman>[];
    historyLoans = <Peminjaman>[];
    dendaLoans = <Peminjaman>[];
    try {
      final res = await ApiClient.getJson('/peminjaman');
      final list = res['data'];
      if (list is List && list.isNotEmpty) {
        await OfflineCache.saveLoans(res);
        final parsed = list
            .whereType<Map<String, dynamic>>()
            .map(Peminjaman.fromJson)
            .toList();

        final active = parsed.where((p) => !p.sudahDikembalikan).toList();
        final returned = parsed.where((p) => p.sudahDikembalikan).toList();

        activeLoans = active;
        historyLoans = returned;
        notifyListeners();
      }
    } catch (_) {
      final cached = await OfflineCache.getLoans();
      final list = cached?['data'];
      if (list is List) {
        final parsed = list.whereType<Map<String, dynamic>>().map(Peminjaman.fromJson).toList();
        activeLoans = parsed.where((p) => !p.sudahDikembalikan).toList();
        historyLoans = parsed.where((p) => p.sudahDikembalikan).toList();
        error = 'Menampilkan data peminjaman terakhir yang tersimpan.';
      } else {
        error = 'Data peminjaman tidak dapat dimuat dari server.';
      }
      notifyListeners();
    }
  }
}
