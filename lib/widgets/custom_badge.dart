import 'package:flutter/material.dart';
import '../core/app_theme.dart';

enum BadgeType {
  tersedia,
  dipinjam,
  activeUser,
  warning,
  info,
  tag,
  danger,
}

class CustomBadge extends StatelessWidget {
  const CustomBadge({
    super.key,
    required this.label,
    this.type = BadgeType.info,
    this.icon,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  final String label;
  final BadgeType type;
  final IconData? icon;
  final double fontSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Border? border;

    switch (type) {
      case BadgeType.tersedia:
        bg = AppTheme.mintBackground;
        fg = AppTheme.mintGreen;
        break;
      case BadgeType.dipinjam:
        bg = const Color(0xFFE2E8F0);
        fg = const Color(0xFF475569);
        break;
      case BadgeType.activeUser:
        bg = const Color(0xFFE0F7F6);
        fg = const Color(0xFF0F766E);
        break;
      case BadgeType.warning:
        bg = AppTheme.amberBackground;
        fg = const Color(0xFFB45309);
        break;
      case BadgeType.danger:
        bg = AppTheme.dangerBackground;
        fg = AppTheme.dangerRed;
        break;
      case BadgeType.tag:
        bg = AppTheme.softBlueBackground;
        fg = AppTheme.primaryNavy;
        break;
      case BadgeType.info:
        bg = const Color(0xFFEFF6FF);
        fg = AppTheme.accentBlue;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
