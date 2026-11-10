# Pustaka Digital — Aplikasi Mobile Android Perpustakaan Sekolah (Flutter)

Aplikasi klien Android resmi untuk sistem digitalisasi perpustakaan SMK/SMA Negeri, dibangun menggunakan **Flutter** dengan implementasi **Clean Architecture**, **State Management Provider**, dan penyimpanan lokal **SharedPreferences**.

Antarmuka pengguna (UI/UX) dirancang dan direkayasa secara presisi mengacu 100% pada **6 Prototype Figma** dan sistem desain modern berstandar industri.

---

## 📱 Daftar 6 Layar UI/UX (Sesuai Mockup Figma)

| No | Layar | Deskripsi & Komponen Utama |
|---|---|---|
| **1** | **Splash Screen** | Gradient biru malam (`#0F2654` ke `#0A1B3D`), wadah icon rounded bercahaya (neon cyan book), teks brand *"Pustaka Digital"*, badge *"Akses Presensi & Katalog Cerdas"*, dynamic animated progress bar, status loading *"Menghubungkan basis data perpustakaan..."*, footer identitas *"SMK Negeri 1 Surabaya"*. |
| **2** | **Login Screen** | Hero banner foto perpustakaan modern dengan gradient overlay, label *"PustakaDigital SMK Negeri 1"*, heading *"Selamat Datang Kembali!"*, kartu putih rounded, tab pill *"Masuk dengan NIS atau Nomor Anggota"*, form NIS & PIN dengan toggle visibility sandi, checkbox *"Ingat Saya"*, tautan *"Lupa PIN / Butuh Bantuan?"*, dan tombol utama *"Masuk"*. |
| **3** | **Beranda (Home)** | Header identitas logo + lonceng + avatar, kartu sapaan siswa (*Hai, Muhammad Irsyadul I.*, badge *Anggota Aktif*, *NIS 2122.10.490 • XII RPL 3*), bar pencarian dengan filter slider, kartu gradient *"STATUS PEMINJAMAN ANDA"* (buku aktif, countdown jatuh tempo, progress bar sisa hari, link perpanjangan), filter chip kategori (*RPL & IT*, *Sains & Fisika*, *Novel & Fiksi*), carousel horizontal *"Rekomendasi Terpopuler (Top 10)"*, dan grid 2-kolom *"Koleksi Terbaru Ditambahkan"*. |
| **4** | **Detail Buku** | Cover hero elevasi 3D, judul lengkap, nama penulis berikon toga, rating sivitas (4.8 • 128 ulasan), tag chips metadata (*RPL / Software*, *Indonesia*, *Tahun 2023*, DDC Code), kartu ketersediaan stok warna hijau mint dengan progress bar ketersediaan, kartu lokasi penempatan rak biru muda dengan tombol *"Peta"*, segmented control tab (*Sinopsis*, *Detail Metadata*, *Ulasan*), 4 checklist pill keunggulan, rekomendasi buku terkait di rak yang sama, dan sticky bottom bar (*Tanya Pustakawan* + *Reservasi Pinjam*). |
| **5** | **Pinjaman Saya** | Header brand, kartu kebijakan peminjaman berbadge *"Kuota 1/3"* (maksimal 3 eksemplar, 7 hari kalender), segmented filter pills (*Sedang Dipinjam*, *Riwayat Selesai*, *Denda & Telat*), kartu transaksi peminjaman (TRX ID, cover, chip kategori, judul, pengarang, lokasi rak, box tanggal pinjam & batas kembali, progress bar waktu pinjam persentase), serta tombol aksi *"Ajukan Perpanjangan Waktu (+7 Hari)"* dengan dialog konfirmasi. |
| **6** | **Profil Siswa** | Header brand, kartu profil siswa berbadge centang terverifikasi (*Muhammad Irsyadul I.*, *NIS*, asal sekolah, badge penghargaan *Peminjam Teladan*), 3 kartu statistik metrik (*12 Buku Pernah Dibaca*, *1 Buku Sedang Aktif*, *0 Denda & Sanksi*), banner pengingat tenggat jatuh tempo buku aktif (*Tenggat 3 Hari Lagi*), kelompok menu *"AKTIVITAS & PREFERENSI"*, kelompok menu *"PUSAT BANTUAN & PENGATURAN"*, serta tombol *"Keluar Akun"* dengan konfirmasi reset sesi. |

---

## 🎨 Design System & Spesifikasi Visual

### 1. Palet Warna Utama
* **Primary Navy Dark:** `#0D1E3A` / `#0A1931` (Dominan latar tombol, card aksen, dan teks judul)
* **Navy Hero Card:** `#0F2654` — `#133678` (Latar kartu status peminjaman aktif & splash)
* **Primary Accent Blue:** `#1E5BB5` / `#2563EB` (Aksen interaktif, link, dan ikon navigasi)
* **Cyan Neon Glow:** `#00D2BA` / `#22D3EE` (Warna aksen ikon splash, progress bar, dan status aktif)
* **Mint Green (Success):** `#10B981` / background `#E8F7F0` (Badge ketersediaan buku & status anggota)
* **Amber (Warning):** `#F59E0B` / background `#FEF3C7` (Badge pengingat sisa hari pinjaman)
* **Danger Red:** `#EF4444` / background `#FEE2E2` (Tombol keluar akun & status kuota penuh)
* **Neutral Background:** `#F6F8FB` & **Card Surface:** `#FFFFFF`

### 2. Tipografi
* Hierarchy:
  * Display / Headline: 24–34 px, Bold (`FontWeight.bold`)
  * Section Title: 16–18 px, Semi-Bold / Bold
  * Body Text: 13–14 px, Regular / Medium
  * Caption & Badge: 9.5–11.5 px, Medium / Semi-Bold

### 3. Komponen Utama Reusable
* `BookCoverWidget`: Render cover buku bergradien adaptif dengan efek jahitan/spine realistis jika gambar jaringan belum dimuat, serta dukungan penuh memuat cover URL dari backend REST API.
* `CustomBadge`: Pill indikator status variatif (*Tersedia*, *Dipinjam*, *Anggota Aktif*, *Warning*, *Info*, *Danger*).
* `MainNavigation`: Container bottom bar responsif 4 destinasi (*Beranda*, *Katalog*, *Pinjaman*, *Profil*).

---

## 🏗️ Arsitektur Aplikasi

Aplikasi dibangun dengan pemisahan tanggung jawab yang modular dan terstruktur:

```
lib/
├── core/
│   ├── api_client.dart          # HTTP Client ke Backend Laravel REST API (/api/v1)
│   ├── app_constants.dart       # Konstanta kebijakan pinjam & data sekolah
│   └── app_theme.dart           # Design system, tema Material 3, dan token warna
├── models/
│   ├── buku.dart                # Model entitas Buku, Penulis, Penerbit, Kategori
│   ├── peminjaman.dart          # Model transaksi peminjaman & kalkulasi durasi
│   ├── user_profile.dart        # Model profil anggota & statistik baca
│   ├── kategori.dart
│   ├── penulis.dart
│   └── penerbit.dart
├── providers/
│   ├── auth_provider.dart       # State session login & data siswa (SharedPreferences)
│   ├── buku_provider.dart       # State katalog buku, filter kategori, search, detail
│   ├── pinjaman_provider.dart   # State sirkulasi, pinjam buku, & perpanjangan +7 hari
│   └── riwayat_provider.dart    # Kompatibilitas modul riwayat
├── screens/
│   ├── splash_screen.dart       # Layar 1
│   ├── login_screen.dart        # Layar 2
│   ├── main_navigation.dart     # Navigasi utama 4 Tab
│   ├── home_screen.dart         # Layar 3 (Beranda)
│   ├── katalog_screen.dart      # Tab 2 (Katalog & Pencarian Buku)
│   ├── detail_buku_screen.dart  # Layar 4 (Detail Buku)
│   ├── pinjaman_screen.dart     # Layar 5 (Pinjaman Saya)
│   └── profil_screen.dart       # Layar 6 (Profil Siswa)
└── widgets/
    ├── book_cover_widget.dart   # Cover buku bergradien & spine 3D
    └── custom_badge.dart        # Badge pill status serbaguna
```

---

## 🚀 Panduan Menjalankan Project

### 1. Prasyarat
* Flutter SDK versi 3.20+ (Dart 3.x)
* Emulator Android atau perangkat fisik Android dengan USB Debugging aktif
* (Opsional) Backend REST API Laravel berjalan di local host

### 2. Menjalankan Backend Laravel (Tugas A)
Buka terminal pada folder `Website/rest-api-perpustakaan`:
```bash
cd "../Website/rest-api-perpustakaan"
composer install
php artisan migrate --seed
php artisan serve
```
*Base URL backend:* `http://127.0.0.1:8000/api/v1` (atau `http://10.0.2.2:8000/api/v1` untuk Android Emulator).

### 3. Menjalankan Aplikasi Flutter (Tugas B)
Buka terminal pada direktori `Anodor`:
```bash
# Ambil dependencies
flutter pub get

# Jalankan pengujian otomatis (Semua 6 layar)
flutter test

# Jalankan pemeriksaan kualitas kode (0 warning / 0 error)
flutter analyze

# Jalankan pada emulator / perangkat fisik
flutter run
```

> **Catatan Mode Resiliensi:**  
> Aplikasi dilengkapi dengan penanganan offline anggun (*graceful fallback*). Jika backend Laravel belum dinyalakan, aplikasi tetap menampilkan data katalog realistis, kartu pinjaman aktif, serta statistik profil secara penuh tanpa kendala koneksi.

---

## 🤖 Tugas E — Dokumentasi Pemanfaatan AI

Proyek ini memanfaatkan bantuan AI (Antigravity AI Agent) untuk mempercepat siklus rekayasa perangkat lunak pada beberapa aspek kunci:

| Aspek Pekerjaan | Peran Bantuan AI | Contoh Prompt yang Digunakan |
|---|---|---|
| **1. UI/UX Reverse-Engineering** | Menganalisis secara visual 6 foto mockup Figma, mengekstrak palet warna heksadesimal, menyusun hierarki tipografi, serta mendesain ulang tata letak widget agar 100% presisi dengan desain asli. | *"media foto yang saya lampirkan merupakan design ui/ux dari aplikasi android yang mau di buat di Anodor jika ui/ux nya tidak sesuai maka perbaiki keseluruhannya"* |
| **2. Perbaikan Bug & Layout Constraints** | Mengidentifikasi dan memperbaiki masalah infinite width constraints pada `Stack` dan overflow pada `RenderFlex` pada layar kecil/widget test sehingga kode lulus pengujian dengan 0 issues. | *"Jalankan flutter test dan perbaiki semua error kompilasi dan render overflow"* |
| **3. State Management & Storage** | Merancang integrasi `MultiProvider` (`AuthProvider`, `BukuProvider`, `PinjamanProvider`) dan persistensi `SharedPreferences` untuk menyimpan status autentikasi siswa dan riwayat transaksi. | *"Implementasikan session management siswa menggunakan SharedPreferences dengan fallback profil"* |
| **4. Penyusunan Automated Tests** | Membuat 6 skenario widget test komprehensif pada `test/widget_test.dart` yang memverifikasi keberadaan komponen kunci dari setiap layar Figma. | *"Buatkan widget test lengkap untuk memvalidasi keberadaan elemen pada 6 layar prototype"* |
| **5. Dokumentasi Terpadu** | Mengompilasi dokumentasi arsitektur, panduan instalasi, dan laporan deliverable Tugas A hingga E secara rapi dan profesional. | *"Buatkan dokumentasi README lengkap yang memetakan Tugas A-E secara mendetail"* |
