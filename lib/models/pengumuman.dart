/// Model Pengumuman sesuai response GET /pengumuman dan /pengumuman/{id}.
class Pengumuman {
  const Pengumuman({
    required this.id,
    required this.judul,
    required this.isi,
    this.diterbitkanPada,
  });

  factory Pengumuman.fromJson(Map<String, dynamic> json) {
    return Pengumuman(
      id: (json['id'] as num?)?.toInt() ?? 0,
      judul: json['judul']?.toString() ?? '',
      isi: json['isi']?.toString() ?? '',
      // Backend mengirim diterbitkan_pada nullable; created_at selalu ada.
      diterbitkanPada: DateTime.tryParse(
        (json['diterbitkan_pada'] ?? json['created_at'] ?? '').toString(),
      ),
    );
  }

  final int id;
  final String judul;
  final String isi;
  final DateTime? diterbitkanPada;
}
