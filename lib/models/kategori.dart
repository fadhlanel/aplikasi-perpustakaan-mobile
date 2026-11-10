/// Model sederhana Kategori (untuk dropdown filter).
class Kategori {
  const Kategori({
    required this.id,
    required this.nama,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nama: json['nama']?.toString() ?? '',
    );
  }

  final int id;
  final String nama;
}
