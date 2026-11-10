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

  bool _isLoggedIn = true; // Default true agar bisa langsung eksplorasi, dapat logout
  bool _isLoading = true;

  UserProfile _profile = const UserProfile(
    nama: AppConstants.defaultStudentName,
    nis: AppConstants.defaultNis,
    kelas: AppConstants.defaultKelas,
    sekolah: AppConstants.schoolName,
  );

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  UserProfile get profile => _profile;

  Future<void> initSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? true;
      final savedNis = prefs.getString(_keyNis) ?? AppConstants.defaultNis;
      final savedName = prefs.getString(_keyName) ?? AppConstants.defaultStudentName;
      final savedKelas = prefs.getString(_keyKelas) ?? AppConstants.defaultKelas;

      _profile = _profile.copyWith(
        nis: savedNis,
        nama: savedName,
        kelas: savedKelas,
      );
    } catch (_) {
      _isLoggedIn = true;
    } finally {
      _isLoading = false;
      notifyListeners();
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

    // Validasi input sederhana
    if (nis.trim().isEmpty) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoggedIn = true;
    _profile = _profile.copyWith(
      nis: nis.trim(),
      nama: nis.contains('2122') ? AppConstants.defaultStudentName : 'Siswa SMKN 1',
    );

    if (rememberMe) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyNis, _profile.nis);
        await prefs.setString(_keyName, _profile.nama);
      } catch (_) {}
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
    } catch (_) {}
    notifyListeners();
  }
}
