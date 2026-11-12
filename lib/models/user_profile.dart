class UserProfile {
  const UserProfile({
    required this.nama,
    required this.nis,
    required this.kelas,
    required this.sekolah,
    this.email,
    this.telepon,
    this.isVerified = true,
    this.badge = 'Peminjam Teladan',
    this.bukuDibacaCount = 12,
    this.bukuAktifCount = 1,
    this.dendaCount = 0,
    this.avatarUrl,
  });

  final String nama;
  final String nis;
  final String kelas;
  final String sekolah;
  final String? email;
  final String? telepon;
  final bool isVerified;
  final String badge;
  final int bukuDibacaCount;
  final int bukuAktifCount;
  final int dendaCount;
  final String? avatarUrl;

  UserProfile copyWith({
    String? nama,
    String? nis,
    String? kelas,
    String? sekolah,
    String? email,
    String? telepon,
    bool? isVerified,
    String? badge,
    int? bukuDibacaCount,
    int? bukuAktifCount,
    int? dendaCount,
    String? avatarUrl,
  }) {
    return UserProfile(
      nama: nama ?? this.nama,
      nis: nis ?? this.nis,
      kelas: kelas ?? this.kelas,
      sekolah: sekolah ?? this.sekolah,
      email: email ?? this.email,
      telepon: telepon ?? this.telepon,
      isVerified: isVerified ?? this.isVerified,
      badge: badge ?? this.badge,
      bukuDibacaCount: bukuDibacaCount ?? this.bukuDibacaCount,
      bukuAktifCount: bukuAktifCount ?? this.bukuAktifCount,
      dendaCount: dendaCount ?? this.dendaCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
