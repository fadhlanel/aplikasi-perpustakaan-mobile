/// Model sederhana Penulis.
class Penulis {
  const Penulis({
    required this.id,
    required this.nama,
    this.biografi,
  });

  factory Penulis.fromJson(Map<String, dynamic> json) {
    return Penulis(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nama: json['nama']?.toString() ?? '',
      biografi: json['biografi']?.toString(),
    );
  }

  final int id;
  final String nama;
  final String? biografi;
}
