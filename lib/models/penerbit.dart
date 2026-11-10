/// Model sederhana Penerbit.
class Penerbit {
  const Penerbit({
    required this.id,
    required this.nama,
    this.alamat,
  });

  factory Penerbit.fromJson(Map<String, dynamic> json) {
    return Penerbit(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nama: json['nama']?.toString() ?? '',
      alamat: json['alamat']?.toString(),
    );
  }

  final int id;
  final String nama;
  final String? alamat;
}
