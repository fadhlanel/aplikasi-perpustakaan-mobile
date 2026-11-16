import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../core/offline_cache.dart';
import '../models/pengumuman.dart';

class PengumumanProvider extends ChangeNotifier {
  PengumumanProvider();

  List<Pengumuman> items = const <Pengumuman>[];
  bool loading = false;
  bool offline = false;
  String? error;

  void ensureLoaded() {
    if (loading || items.isNotEmpty || error != null) return;
    load();
  }

  Future<void> load() async {
    if (loading) return;
    loading = true;
    offline = false;
    error = null;
    notifyListeners();

    try {
      final res = await ApiClient.getJson('/pengumuman');
      items = _parseList(res['data']);
      await OfflineCache.saveAnnouncements(res);
    } catch (e) {
      // HTTP error bukan masalah jaringan: tampilkan pesannya, jangan
      // ditutupi data cache seperti pada modul buku.
      if (e is ApiException && !e.isNetworkError) {
        error = e.message;
      } else {
        items = await _readCache();
        offline = true;
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Pengumuman> fetchDetail(int id) async {
    final res = await ApiClient.getJson('/pengumuman/$id');
    final data = res['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Detail pengumuman tidak tersedia.');
    }
    return Pengumuman.fromJson(data);
  }

  Future<List<Pengumuman>> _readCache() async {
    final cached = await OfflineCache.getAnnouncements();
    return cached == null ? const <Pengumuman>[] : _parseList(cached['data']);
  }

  List<Pengumuman> _parseList(Object? list) {
    if (list is! List) return const <Pengumuman>[];
    return list
        .whereType<Map<String, dynamic>>()
        .map(Pengumuman.fromJson)
        .toList(growable: false);
  }
}
