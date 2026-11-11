import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/network_service.dart';

/// Badge status API ringkas: `● API Aktif`.
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
        text = 'API Aktif';
        break;
      case ConnectionStatus.apiOffline:
        bg = const Color(0xFFFFFBEB);
        border = const Color(0xFFFDE68A);
        dot = AppTheme.amberWarning;
        textColor = const Color(0xFF92400E);
        text = 'Mode Offline';
        break;
      case ConnectionStatus.noInternet:
        bg = const Color(0xFFFEF2F2);
        border = const Color(0xFFFECACA);
        dot = AppTheme.dangerRed;
        textColor = const Color(0xFF991B1B);
        text = 'Tidak Ada Internet';
        break;
    }

    final busy = _checking || network.isChecking;

    return InkWell(
      onTap: () => _refresh(network),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 132),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            busy
                ? SizedBox(
                    width: 7,
                    height: 7,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: dot),
                  )
                : Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                  ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                busy ? 'Memeriksa...' : text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
