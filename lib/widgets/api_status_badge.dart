import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/network_service.dart';

/// Badge status koneksi ringkas: hanya ikon awan berwarna sesuai status.
/// Klik = refresh status (animasi spinner), tanpa dialog.
class ApiStatusBadge extends StatefulWidget {
  const ApiStatusBadge({super.key});

  @override
  State<ApiStatusBadge> createState() => _ApiStatusBadgeState();
}

class _ApiStatusBadgeState extends State<ApiStatusBadge> {
  bool _checking = false;

  Future<void> _refresh(NetworkService network) async {
    if (_checking) return;
    setState(() => _checking = true);
    await network.checkConnection();
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final network = context.watch<NetworkService>();

    Color iconColor;
    IconData iconData;
    String tooltip;

    switch (network.status) {
      case ConnectionStatus.unknown:
        iconColor = const Color(0xFF94A3B8);
        iconData = Icons.cloud_outlined;
        tooltip = 'Memeriksa koneksi...';
        break;
      case ConnectionStatus.connected:
        iconColor = AppTheme.mintGreen;
        iconData = Icons.cloud_done_rounded;
        tooltip = 'Server Terhubung';
        break;
      case ConnectionStatus.apiOffline:
        iconColor = AppTheme.amberWarning;
        iconData = Icons.cloud_off_rounded;
        tooltip = 'Mode Offline';
        break;
      case ConnectionStatus.noInternet:
        iconColor = AppTheme.dangerRed;
        iconData = Icons.cloud_off_rounded;
        tooltip = 'Tidak Ada Internet';
        break;
    }

    final busy = _checking || network.isChecking;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => _refresh(network),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: busy
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: iconColor,
                  ),
                )
              : Icon(
                  iconData,
                  size: 18,
                  color: iconColor,
                ),
        ),
      ),
    );
  }
}
