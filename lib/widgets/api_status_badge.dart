import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/app_theme.dart';
import '../core/network_service.dart';
import '../core/offline_cache.dart';

class ApiStatusBadge extends StatelessWidget {
  const ApiStatusBadge({super.key, this.isCompact = false});

  final bool isCompact;

  void _showStatusDetail(BuildContext context, NetworkService network) async {
    final lastSync = await OfflineCache.getLastSyncTimeFormatted();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Color dotColor;
            String title;
            String desc;

            switch (network.status) {
              case ConnectionStatus.connected:
                dotColor = AppTheme.mintGreen;
                title = 'REST API Terhubung Aktif';
                desc = 'Aplikasi terhubung langsung dengan server REST API perpustakaan. Data tersinkronisasi secara real-time.';
                break;
              case ConnectionStatus.apiOffline:
                dotColor = AppTheme.amberWarning;
                title = 'Mode Offline (Menampilkan Data Terakhir)';
                desc = 'Perangkat terhubung ke internet, namun server backend perpustakaan belum aktif atau tidak dapat dijangkau. Data yang Anda lihat saat ini adalah data tersimpan terakhir.';
                break;
              case ConnectionStatus.noInternet:
                dotColor = AppTheme.dangerRed;
                title = 'Tidak Ada Koneksi Internet';
                desc = 'Perangkat Anda tidak terhubung ke jaringan internet. Periksa Wi-Fi atau data seluler Anda. Data yang tampil merupakan data cache terakhir.';
                break;
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      desc,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Server API URL:', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                              Text(
                                ApiClient.baseUrl,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Sinkronisasi Terakhir:', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                              Text(
                                lastSync ?? 'Belum pernah',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: network.isChecking
                            ? null
                            : () async {
                                await network.checkConnection();
                                setModalState(() {});
                              },
                        icon: network.isChecking
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          network.isChecking ? 'Memeriksa Koneksi...' : 'Periksa Koneksi Sekarang',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final network = context.watch<NetworkService>();

    Color bg;
    Color border;
    Color dot;
    Color textColor;
    String text;

    switch (network.status) {
      case ConnectionStatus.connected:
        bg = const Color(0xFFECFDF5);
        border = const Color(0xFFA7F3D0);
        dot = AppTheme.mintGreen;
        textColor = const Color(0xFF065F46);
        text = isCompact ? 'API Aktif' : 'API Terhubung';
        break;
      case ConnectionStatus.apiOffline:
        bg = const Color(0xFFFFFBEB);
        border = const Color(0xFFFDE68A);
        dot = AppTheme.amberWarning;
        textColor = const Color(0xFF92400E);
        text = isCompact ? 'Offline' : 'Mode Offline (Data Terakhir)';
        break;
      case ConnectionStatus.noInternet:
        bg = const Color(0xFFFEF2F2);
        border = const Color(0xFFFECACA);
        dot = AppTheme.dangerRed;
        textColor = const Color(0xFF991B1B);
        text = isCompact ? 'No Internet' : 'Tidak Ada Internet';
        break;
    }

    return InkWell(
      onTap: () => _showStatusDetail(context, network),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

