/// Model data Buku (kompatibel dengan response API /buku & tampilan Figma)
class Buku {
  const Buku({
    required this.id,
    required this.judul,
    this.deskripsi,
    required this.tahunTerbit,
    this.isbn,
    this.sampul,
    required this.stok,
    required this.stokTersedia,
    this.kategori,
    this.penulis,
    this.penerbit,
    this.rating = 4.8,
    this.ulasanCount = 128,
    this.kodePanggil = '005.1 INF P',
    this.lokasiRak = 'Rak RPL-04 (Lantai 2 - Sayap Barat)',
    this.isBookmarked = false,
  });

  factory Buku.fromJson(Map<String, dynamic> json) {
    return Buku(
      id: (json['id'] as num?)?.toInt() ?? 0,
      judul: json['judul']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString(),
      tahunTerbit: (json['tahun_terbit'] as num?)?.toInt() ?? 2023,
      isbn: json['isbn']?.toString() ?? '978-602-05-1234-5',
      sampul: json['sampul']?.toString(),
      stok: (json['stok'] as num?)?.toInt() ?? 10,
      stokTersedia: (json['stok_tersedia'] as num?)?.toInt() ?? 8,
      kategori: json['kategori'] is Map<String, dynamic>
          ? (json['kategori'] as Map<String, dynamic>)
          : null,
      penulis: json['penulis'] is Map<String, dynamic>
          ? (json['penulis'] as Map<String, dynamic>)
          : null,
      penerbit: json['penerbit'] is Map<String, dynamic>
          ? (json['penerbit'] as Map<String, dynamic>)
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      ulasanCount: (json['ulasan_count'] as num?)?.toInt() ?? 128,
      kodePanggil: json['kode_panggil']?.toString() ?? '005.1 MAR C',
      lokasiRak: json['lokasi_rak']?.toString() ?? 'Rak RPL-04 (Lantai 2 - Sayap Barat)',
      isBookmarked: json['is_bookmarked'] == true,
    );
  }

  factory Buku.kosong() => const Buku(
        id: 0,
        judul: '',
        tahunTerbit: 0,
        stok: 0,
        stokTersedia: 0,
      );

  final int id;
  final String judul;
  final String? deskripsi;
  final int tahunTerbit;
  final String? isbn;
  final String? sampul;
  final int stok;
  final int stokTersedia;
  final Map<String, dynamic>? kategori;
  final Map<String, dynamic>? penulis;
  final Map<String, dynamic>? penerbit;
  final double rating;
  final int ulasanCount;
  final String kodePanggil;
  final String lokasiRak;
  final bool isBookmarked;

  String get namaKategori => kategori?['nama']?.toString() ?? 'Teknologi Informasi';
  String get namaPenulis => penulis?['nama']?.toString() ?? 'Budi Raharjo, S.Kom.';
  String get namaPenerbit => penerbit?['nama']?.toString() ?? 'Informatika Bandung';

  bool get isTersedia => stokTersedia > 0;
  int get dipinjamCount => (stok - stokTersedia).clamp(0, stok);

  String get deskripsiText {
    final d = deskripsi?.trim();
    if (d == null || d.isEmpty) {
      return 'Buku komprehensif ini menyajikan fondasi arsitektur pengembangan antarmuka modern multi-platform menggunakan Dart dan Flutter framework. Mulai dari pemahaman State Management (BLoC & Provider), integrasi REST API, caching offline SQLite, hingga pipeline deployment ke Google Playstore dan App Store.\n\nDilengkapi dengan studi kasus aplikasi nyata sistem reservasi akademik terintegrasi yang relevan untuk skripsi dan tugas akhir vokasi informatika.';
    }
    return d;
  }

  Buku copyWith({
    int? id,
    String? judul,
    String? deskripsi,
    int? tahunTerbit,
    String? isbn,
    String? sampul,
    int? stok,
    int? stokTersedia,
    Map<String, dynamic>? kategori,
    Map<String, dynamic>? penulis,
    Map<String, dynamic>? penerbit,
    double? rating,
    int? ulasanCount,
    String? kodePanggil,
    String? lokasiRak,
    bool? isBookmarked,
  }) {
    return Buku(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      tahunTerbit: tahunTerbit ?? this.tahunTerbit,
      isbn: isbn ?? this.isbn,
      sampul: sampul ?? this.sampul,
      stok: stok ?? this.stok,
      stokTersedia: stokTersedia ?? this.stokTersedia,
      kategori: kategori ?? this.kategori,
      penulis: penulis ?? this.penulis,
      penerbit: penerbit ?? this.penerbit,
      rating: rating ?? this.rating,
      ulasanCount: ulasanCount ?? this.ulasanCount,
      kodePanggil: kodePanggil ?? this.kodePanggil,
      lokasiRak: lokasiRak ?? this.lokasiRak,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
