import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
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
  static const String _keySekolah = 'student_sekolah';

  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _errorMessage;
  UserProfile _profile = const UserProfile(
    nama: 'Tamu Perpustakaan', nis: '-', kelas: '-', sekolah: AppConstants.schoolName,
    isVerified: false, badge: 'Anggota Baru', bukuDibacaCount: 0, bukuAktifCount: 0, dendaCount: 0,
  );

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProfile get profile => _profile;

  Future<void> initSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final nis = prefs.getString(_keyNis);
      final name = prefs.getString(_keyName);
      final kelas = prefs.getString(_keyKelas);
      _isLoggedIn = prefs.getBool(_keyIsLoggedIn) == true &&
          nis != null && nis.isNotEmpty && name != null && name.isNotEmpty;
      if (_isLoggedIn) {
        _profile = UserProfile(
          nis: nis!, nama: name!, kelas: kelas ?? '-',
          sekolah: prefs.getString(_keySekolah) ?? AppConstants.schoolName,
        );
      }
    } catch (_) {
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String nis, required String pin, bool rememberMe = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await ApiClient.postJson('/siswa/login', body: {
        'nis': nis.trim(),
        'pin': pin.trim(),
      });
      final raw = response['data'] is Map ? response['data'] : response;
      final member = raw['siswa'] is Map ? raw['siswa'] : raw['anggota'] is Map ? raw['anggota'] : raw['user'] is Map ? raw['user'] : raw;
      if (member is! Map || _text(member['nis']).isEmpty || _text(member['nama']).isEmpty) {
        throw ApiException('Respons login siswa tidak valid.');
      }
      _profile = UserProfile(
        nis: _text(member['nis']), nama: _text(member['nama']), kelas: _text(member['kelas'], fallback: '-'),
        sekolah: _text(member['sekolah'], fallback: AppConstants.schoolName),
        isVerified: true,
        bukuDibacaCount: _number(member['buku_dibaca'] ?? member['bukuDibacaCount']),
        bukuAktifCount: _number(member['buku_aktif'] ?? member['bukuAktifCount']),
        dendaCount: _number(member['denda'] ?? member['dendaCount']),
      );
      _isLoggedIn = true;
      if (rememberMe) {
        await _saveSession();
      } else {
        final prefs = await SharedPreferences.getInstance();
        for (final key in [_keyIsLoggedIn, _keyNis, _keyName, _keyKelas, _keySekolah]) {
          await prefs.remove(key);
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _isLoggedIn = false;
      _errorMessage = e.isNetworkError ? 'Tidak dapat terhubung ke server. Periksa koneksi internet.' : e.message;
    } catch (_) {
      _isLoggedIn = false;
      _errorMessage = 'Login gagal. Coba lagi.';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyNis, _profile.nis);
    await prefs.setString(_keyName, _profile.nama);
    await prefs.setString(_keyKelas, _profile.kelas);
    await prefs.setString(_keySekolah, _profile.sekolah);
  }

  Future<bool> changePin(String oldPin, String newPin) async => false;

  Future<void> logout() async {
    _isLoggedIn = false;
    _profile = const UserProfile(nama: 'Tamu Perpustakaan', nis: '-', kelas: '-', sekolah: AppConstants.schoolName, isVerified: false, badge: 'Anggota Baru', bukuDibacaCount: 0, bukuAktifCount: 0, dendaCount: 0);
    final prefs = await SharedPreferences.getInstance();
    for (final key in [_keyIsLoggedIn, _keyNis, _keyName, _keyKelas, _keySekolah]) await prefs.remove(key);
    notifyListeners();
  }

  static String _text(dynamic value, {String fallback = ''}) => value?.toString().trim().isNotEmpty == true ? value.toString().trim() : fallback;
  static int _number(dynamic value) => value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
}
