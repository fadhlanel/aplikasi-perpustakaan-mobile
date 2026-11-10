import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_constants.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    initSession();
  }

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyNis = 'student_nis';
  static const String _keyName = 'student_name';
  static const String _keyKelas = 'student_kelas';
  static const String _keyPin = 'student_pin';

  bool _isLoggedIn = false; // Default false saat baru install, harus login
  bool _isLoading = true;

  UserProfile _profile = const UserProfile(
    nama: 'Tamu Perpustakaan',
    nis: '-',
    kelas: '-',
    sekolah: AppConstants.schoolName,
    isVerified: false,
    badge: 'Anggota Baru',
    bukuDibacaCount: 0,
    bukuAktifCount: 0,
    dendaCount: 0,
  );

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  UserProfile get profile => _profile;

  Future<void> initSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

      if (_isLoggedIn) {
        final savedNis = prefs.getString(_keyNis) ?? AppConstants.defaultNis;
        final savedName = prefs.getString(_keyName) ?? AppConstants.defaultStudentName;
        final savedKelas = prefs.getString(_keyKelas) ?? AppConstants.defaultKelas;

        _profile = UserProfile(
          nis: savedNis,
          nama: savedName,
          kelas: savedKelas,
          sekolah: AppConstants.schoolName,
          isVerified: true,
          badge: 'Peminjam Teladan',
          bukuDibacaCount: 12,
          bukuAktifCount: 1,
          dendaCount: 0,
        );
      }
    } catch (_) {
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPin = prefs.getString(_keyPin) ?? AppConstants.defaultPin;
      if (oldPin.trim() != currentPin) {
        return false;
      }
      await prefs.setString(_keyPin, newPin.trim());
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login({
    required String nis,
    required String pin,
    bool rememberMe = true,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    // Validasi input
    if (nis.trim().isEmpty) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Validasi PIN
    try {
      final prefs = await SharedPreferences.getInstance();
      final validPin = prefs.getString(_keyPin) ?? AppConstants.defaultPin;
      if (pin.trim() != validPin) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (_) {}

    _isLoggedIn = true;
    final isDemoAccount = nis.trim() == AppConstants.defaultNis;
    _profile = UserProfile(
      nis: nis.trim(),
      nama: isDemoAccount ? AppConstants.defaultStudentName : 'Siswa SMKN 1 (${nis.trim()})',
      kelas: isDemoAccount ? AppConstants.defaultKelas : 'XII Rekayasa Perangkat Lunak',
      sekolah: AppConstants.schoolName,
      isVerified: true,
      badge: 'Peminjam Teladan',
      bukuDibacaCount: isDemoAccount ? 12 : 3,
      bukuAktifCount: isDemoAccount ? 1 : 0,
      dendaCount: 0,
    );

    if (rememberMe) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyNis, _profile.nis);
        await prefs.setString(_keyName, _profile.nama);
        await prefs.setString(_keyKelas, _profile.kelas);
      } catch (_) {}
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _profile = const UserProfile(
      nama: 'Tamu Perpustakaan',
      nis: '-',
      kelas: '-',
      sekolah: AppConstants.schoolName,
      isVerified: false,
      badge: 'Anggota Baru',
      bukuDibacaCount: 0,
      bukuAktifCount: 0,
      dendaCount: 0,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyNis);
      await prefs.remove(_keyName);
      await prefs.remove(_keyKelas);
    } catch (_) {}
    notifyListeners();
  }
}
