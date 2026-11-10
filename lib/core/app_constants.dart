/// Data konstanta default dan konfigurasi aplikasi
class AppConstants {
  AppConstants._();

  static const String appName = 'Pustaka Digital';
  static const String appTagline = 'Sistem Perpustakaan Pintar SMK / SMA';
  static const String schoolName = 'SMK Negeri 1 Surabaya';

  // Default Student Data (Sesuai Desain Figma)
  static const String defaultStudentName = 'Muhammad Irsyadul I.';
  static const String defaultNis = '2122.10.490';
  static const String defaultKelas = 'XII RPL 3';
  static const String defaultStatus = 'Anggota Aktif';
  static const String defaultPin = '123456';

  // Kebijakan Peminjaman
  static const int maxLoanQuota = 3;
  static const int loanDurationDays = 7;
  static const String loanPolicyText =
      'Maksimal peminjaman 3 eksemplar buku dengan durasi pinjam 7 hari kalender. Perpanjangan mandiri berlaku 1x per transaksi.';
}
