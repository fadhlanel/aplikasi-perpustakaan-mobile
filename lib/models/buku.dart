/// Model data Buku (kompatibel dengan response API /buku & tampilan Figma)
class Buku {
  const Buku({
    required this.id,
    required this.judul,
    this.deskripsi,
    this.sinopsis,
    this.ringkasan,
    required this.tahunTerbit,
    this.isbn,
    this.sampul,
    required this.stok,
    required this.stokTersedia,
    this.kategori,
    this.penulis,
    this.penerbit,
    this.tags = const <String>[],
    this.rating = 0,
    this.ulasanCount = 0,
    this.isBookmarked = false,
  });

  factory Buku.fromJson(Map<String, dynamic> json) {
    return Buku(
      id: (json['id'] as num?)?.toInt() ?? 0,
      judul: json['judul']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString(),
      sinopsis: json['sinopsis']?.toString(),
      ringkasan: json['ringkasan']?.toString(),
      tahunTerbit: (json['tahun_terbit'] as num?)?.toInt() ?? 0,
      isbn: json['isbn']?.toString(),
      sampul: json['sampul_url']?.toString() ?? json['sampul']?.toString(),
      stok: (json['stok'] as num?)?.toInt() ?? 0,
      stokTersedia: (json['stok_tersedia'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((tag) => tag is Map<String, dynamic>
                  ? tag['nama']?.toString() ?? ''
                  : tag?.toString() ?? '')
              .where((tag) => tag.isNotEmpty)
              .toList() ??
          const <String>[],
      kategori: json['kategori'] is Map<String, dynamic>
          ? (json['kategori'] as Map<String, dynamic>)
          : null,
      penulis: json['penulis'] is Map<String, dynamic>
          ? (json['penulis'] as Map<String, dynamic>)
          : null,
      penerbit: json['penerbit'] is Map<String, dynamic>
          ? (json['penerbit'] as Map<String, dynamic>)
          : null,
      rating: (json['rating_rata_rata'] as num? ?? json['rating'] as num?)?.toDouble() ?? 0,
      ulasanCount: (json['total_rating'] as num? ?? json['ulasan_count'] as num?)?.toInt() ?? 0,
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
  final String? sinopsis;
  final String? ringkasan;
  final int tahunTerbit;
  final String? isbn;
  final String? sampul;
  final int stok;
  final int stokTersedia;
  final Map<String, dynamic>? kategori;
  final Map<String, dynamic>? penulis;
  final Map<String, dynamic>? penerbit;
  final List<String> tags;
  final double rating;
  final int ulasanCount;
  final bool isBookmarked;

  String get namaKategori => kategori?['nama']?.toString() ?? '';
  String get namaPenulis => penulis?['nama']?.toString() ?? '';
  String get namaPenerbit => penerbit?['nama']?.toString() ?? '';

  bool get isTersedia => stokTersedia > 0;
  int get dipinjamCount => (stok - stokTersedia).clamp(0, stok);

  String get sinopsisText => sinopsis?.trim() ?? '';

  Buku copyWith({
    int? id,
    String? judul,
    String? deskripsi,
    String? sinopsis,
    String? ringkasan,
    int? tahunTerbit,
    String? isbn,
    String? sampul,
    int? stok,
    int? stokTersedia,
    Map<String, dynamic>? kategori,
    Map<String, dynamic>? penulis,
    Map<String, dynamic>? penerbit,
    List<String>? tags,
    double? rating,
    int? ulasanCount,
    bool? isBookmarked,
  }) {
    return Buku(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      sinopsis: sinopsis ?? this.sinopsis,
      ringkasan: ringkasan ?? this.ringkasan,
      tahunTerbit: tahunTerbit ?? this.tahunTerbit,
      isbn: isbn ?? this.isbn,
      sampul: sampul ?? this.sampul,
      stok: stok ?? this.stok,
      stokTersedia: stokTersedia ?? this.stokTersedia,
      kategori: kategori ?? this.kategori,
      penulis: penulis ?? this.penulis,
      penerbit: penerbit ?? this.penerbit,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      ulasanCount: ulasanCount ?? this.ulasanCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'judul': judul,
        'deskripsi': deskripsi,
        'sinopsis': sinopsis,
        'ringkasan': ringkasan,
        'tahun_terbit': tahunTerbit,
        'isbn': isbn,
        'sampul_url': sampul,
        'stok': stok,
        'stok_tersedia': stokTersedia,
        'kategori': kategori,
        'penulis': penulis,
        'penerbit': penerbit,
        'tags': tags,
        'rating_rata_rata': rating,
        'total_rating': ulasanCount,
        'is_bookmarked': isBookmarked,
      };
}
