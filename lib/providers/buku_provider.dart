import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/buku.dart';
import '../models/kategori.dart';

class BukuProvider extends ChangeNotifier {
  BukuProvider();

  List<Buku> items = <Buku>[];
  List<Kategori> kategoris = <Kategori>[];

  String query = '';
  int? kategoriId;
  String selectedCategoryName = 'RPL & IT';

  int currentPage = 1;
  int lastPage = 1;
  int total = 0;

  bool loading = false;
  bool loadingMore = false;
  String? error;

  bool get hasMore => currentPage < lastPage;

  // Daftar buku khusus untuk Beranda (Figma)
  List<Buku> popularBooks = <Buku>[];
  List<Buku> latestBooks = <Buku>[];

  List<Buku> get filteredPopularBooks => _filterCategory(popularBooks);
  List<Buku> get filteredLatestBooks => _filterCategory(latestBooks);

  List<Buku> _filterCategory(List<Buku> books) {
    if (selectedCategoryName == 'Semua') return books;
    return books.where((book) {
      final nama = book.namaKategori;
      if (nama.toLowerCase().contains(selectedCategoryName.toLowerCase())) return true;
      // Penyamaan logika dengan Katalog (katalog_screen.dart).
      return selectedCategoryName == 'RPL & IT' &&
          (nama.contains('RPL') || nama.contains('Software') || nama.contains('Teknologi'));
    }).toList();
  }

  /*
  void _initDefaultData() {
    // Data default presisi sesuai dengan 6 mockup Figma
    popularBooks = [
      const Buku(
        id: 101,
        judul: 'Clean Architecture',
        deskripsi:
            'A Craftsman\'s Guide to Software Structure and Design oleh Robert C. Martin (Uncle Bob). Memberikan panduan praktis membangun arsitektur perangkat lunak yang modular, teruji, dan mudah dipelihara.',
        tahunTerbit: 2018,
        stok: 5,
        stokTersedia: 3,
        rating: 4.9,
        ulasanCount: 94,
        kodePanggil: '005.1 MAR C',
        lokasiRak: 'Rak RPL-04 (Lantai 2 - Sayap Barat)',
        penulis: {'nama': 'Robert C. Martin'},
        kategori: {'nama': 'RPL & IT'},
      ),
      const Buku(
        id: 102,
        judul: 'Atomic Habits',
        deskripsi:
            'Perubahan Kecil yang Memberikan Hasil Luar Biasa. Panduan mudah dan terbukti untuk membentuk kebiasaan baik dan menghentikan kebiasaan buruk oleh James Clear.',
        tahunTerbit: 2019,
        stok: 4,
        stokTersedia: 0,
        rating: 4.8,
        ulasanCount: 210,
        kodePanggil: '158.1 CLE A',
        lokasiRak: 'Rak PSI-02 (Lantai 1)',
        penulis: {'nama': 'James Clear'},
        kategori: {'nama': 'Pengembangan Diri'},
      ),
      const Buku(
        id: 103,
        judul: 'Clean Code in Dart & Flutter',
        deskripsi: 'Prinsip penulisan kode bersih pada framework Flutter.',
        tahunTerbit: 2023,
        stok: 6,
        stokTersedia: 4,
        rating: 4.9,
        ulasanCount: 68,
        kodePanggil: '005.2 DAR C',
        lokasiRak: 'Rak RPL-04 (Lantai 2 - Sayap Barat)',
        penulis: {'nama': 'Robert C. Martin'},
        kategori: {'nama': 'RPL & IT'},
      ),
    ];

    latestBooks = [
      const Buku(
        id: 201,
        judul: 'Machine Learning dengan Python',
        deskripsi:
            'Dasar-dasar machine learning praktis menggunakan pustaka Scikit-Learn, Pandas, dan TensorFlow.',
        tahunTerbit: 2023,
        stok: 8,
        stokTersedia: 6,
        rating: 4.7,
        ulasanCount: 45,
        kodePanggil: '006.3 IND M',
        lokasiRak: 'Rak-04',
        penulis: {'nama': 'Dr. Indrajit & Tim'},
        kategori: {'nama': 'RPL & IT'},
      ),
      const Buku(
        id: 202,
        judul: 'Fisika Kuantum Populer',
        deskripsi:
            'Memahami dasar-dasar alam semesta dan mekanika kuantum dalam perspektif fisika modern untuk siswa SMA/SMK.',
        tahunTerbit: 2022,
        stok: 7,
        stokTersedia: 5,
        rating: 4.8,
        ulasanCount: 38,
        kodePanggil: '530.1 YOH F',
        lokasiRak: 'Rak-04',
        penulis: {'nama': 'Prof. Yohanes S.'},
        kategori: {'nama': 'Sains & Fisika'},
      ),
      const Buku(
        id: 203,
        judul: 'UI/UX Design Praktis',
        deskripsi:
            'Panduan langkah demi langkah mendesain antarmuka pengguna & pengalaman pengguna yang efektif menggunakan Figma.',
        tahunTerbit: 2023,
        stok: 10,
        stokTersedia: 8,
        rating: 4.9,
        ulasanCount: 82,
        kodePanggil: '741.6 PRA U',
        lokasiRak: 'Rak-04',
        penulis: {'nama': 'Doni Prasetyo'},
        kategori: {'nama': 'RPL & IT'},
      ),
      const Buku(
        id: 204,
        judul: 'Revolusi Digital RI',
        deskripsi:
            'Menelusuri jejak teknologi dan sejarah transformasi digital dari masa ke masa di Indonesia.',
        tahunTerbit: 2024,
        stok: 5,
        stokTersedia: 4,
        rating: 4.6,
        ulasanCount: 29,
        kodePanggil: '959.8 FIB R',
        lokasiRak: 'Rak-04',
        penulis: {'nama': 'Hendro Wibowo'},
        kategori: {'nama': 'Sejarah & Sosial'},
      ),
    ];

    items = [
      getHeroBook(),
      ...popularBooks,
      ...latestBooks,
    ];
    total = items.length;
  }

  */

  Buku getHeroBook() {
    return const Buku(
      id: 1,
      judul: 'Pemrograman Web & Mobile dengan Flutter',
      deskripsi:
          'Buku komprehensif ini menyajikan fondasi arsitektur pengembangan antarmuka modern multi-platform menggunakan Dart dan Flutter framework. Mulai dari pemahaman State Management (BLoC & Provider), integrasi REST API, caching offline SQLite, hingga pipeline deployment ke Google Playstore dan App Store.\n\nDilengkapi dengan studi kasus aplikasi nyata sistem reservasi akademik terintegrasi yang relevan untuk skripsi dan tugas akhir vokasi informatika.',
      tahunTerbit: 2023,
      isbn: '978-602-05-2345-6',
      stok: 10,
      stokTersedia: 8,
      rating: 4.8,
      ulasanCount: 128,
      kodePanggil: 'code 121-323-232',
      lokasiRak: 'Rak RPL-04 (Lantai 2 - Sayap Barat)',
      penulis: {'nama': 'Dr. Irfan Mahendra, M.Kom.'},
      kategori: {'nama': 'RPL / Software'},
      penerbit: {'nama': 'Informatika Bandung'},
    );
  }

  void selectCategory(String categoryName) {
    selectedCategoryName = categoryName;
    notifyListeners();
  }

  void setQuery(String q) {
    query = q;
    loadFirst();
  }

  void pilihKategori(int? id) {
    kategoriId = id;
    loadFirst();
  }

  void reset() {
    query = '';
    kategoriId = null;
    loadFirst();
  }

  void decrementStock(int bukuId) {
    Buku update(Buku buku) => buku.id == bukuId && buku.stokTersedia > 0
        ? buku.copyWith(stokTersedia: buku.stokTersedia - 1)
        : buku;

    items = items.map(update).toList();
    popularBooks = popularBooks.map(update).toList();
    latestBooks = latestBooks.map(update).toList();
    notifyListeners();
  }

  void toggleBookmark(int bukuId) {
    items = items.map((buku) {
      if (buku.id == bukuId) {
        return buku.copyWith(isBookmarked: !buku.isBookmarked);
      }
      return buku;
    }).toList();

    popularBooks = popularBooks.map((buku) {
      if (buku.id == bukuId) {
        return buku.copyWith(isBookmarked: !buku.isBookmarked);
      }
      return buku;
    }).toList();

    notifyListeners();
  }

  Future<void> loadFirst() async {
    _setLoading(true, error: null);
    notifyListeners();

    try {
      final res = await ApiClient.getJson('/buku', query: {
        'per_page': '20',
        if (query.trim().isNotEmpty) 'search': query.trim(),
        if (kategoriId != null) 'kategori_id': '$kategoriId',
      });
      final apiItems = _parseBukuList(res);
      // Respons API sukses tetap menjadi sumber kebenaran, termasuk saat kosong.
      items = apiItems;
      popularBooks = apiItems.take(3).toList(growable: false);
      latestBooks = apiItems.reversed.take(4).toList(growable: false);
      if (apiItems.isNotEmpty) {
        final meta = res['meta'] as Map<String, dynamic>? ?? const {};
        currentPage = (meta['current_page'] as num?)?.toInt() ?? 1;
        lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
        total = (meta['total'] as num?)?.toInt() ?? items.length;
        // API adalah satu-satunya sumber data production.
      }
      _setLoading(false, error: null);
    } catch (e) {
      // HTTP error (4xx/5xx) bukan masalah jaringan: tampilkan pesan,
      // jangan sembunyikan di balik data cache.
      if (e is ApiException && !e.isNetworkError) {
        _setLoading(false, error: e.message);
      } else {
        items = <Buku>[];
        popularBooks = <Buku>[];
        latestBooks = <Buku>[];
        total = 0;
        _setLoading(false, error: 'Data buku tidak dapat dimuat dari server.');
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || loadingMore || loading) return;
    loadingMore = true;
    notifyListeners();

    try {
      final res = await ApiClient.getJson('/buku', query: {
        'per_page': '20',
        'page': '${currentPage + 1}',
        if (query.trim().isNotEmpty) 'search': query.trim(),
        if (kategoriId != null) 'kategori_id': '$kategoriId',
      });
      final tambahan = _parseBukuList(res);
      final idLama = items.map((e) => e.id).toSet();
      items = [
        ...items,
        ...tambahan.where((e) => !idLama.contains(e.id)),
      ];
      final meta = res['meta'] as Map<String, dynamic>? ?? const {};
      currentPage = (meta['current_page'] as num?)?.toInt() ?? currentPage;
      lastPage = (meta['last_page'] as num?)?.toInt() ?? lastPage;
      total = (meta['total'] as num?)?.toInt() ?? total;
    } catch (_) {
    } finally {
      loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadKategoris() async {
    try {
      final res = await ApiClient.getJson('/kategori', query: {'per_page': '50', 'page': '1'});
      final data = res['data'];
      if (data is List) {
        kategoris = data
            .whereType<Map<String, dynamic>>()
            .map(Kategori.fromJson)
            .toList(growable: false);
      }
    } catch (_) {
    } finally {
      notifyListeners();
    }
  }

  Future<Buku> fetchDetail(int id) async {
    try {
      final res = await ApiClient.getJson('/buku/$id');
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        return Buku.fromJson(data);
      }
    } catch (_) {
      // Fallback lokal jika backend tidak aktif
    }

    // Jangan kembalikan mock untuk aksi online; ID mock menyebabkan 404 saat reservasi.
    return Buku.kosong();
  }

  void _setLoading(bool value, {String? error}) {
    loading = value;
    this.error = error;
  }

  List<Buku> _parseBukuList(Map<String, dynamic> res) {
    final list = res['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(Buku.fromJson)
        .toList(growable: false);
  }
}
