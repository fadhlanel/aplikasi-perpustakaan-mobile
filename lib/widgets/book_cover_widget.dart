import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/app_theme.dart';

class BookCoverWidget extends StatelessWidget {
  const BookCoverWidget({
    super.key,
    required this.judul,
    this.penulis,
    this.sampulUrl,
    this.width = 100,
    this.height = 145,
    this.borderRadius = 10,
    this.gradientColors,
    this.elevation = 4,
  });

  final String judul;
  final String? penulis;
  final String? sampulUrl;
  final double width;
  final double height;
  final double borderRadius;
  final List<Color>? gradientColors;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    String? resolvedUrl = sampulUrl;
    if (resolvedUrl != null && !resolvedUrl.startsWith('http') && resolvedUrl.isNotEmpty) {
      final base = ApiClient.baseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');
      resolvedUrl = '$base/storage/$resolvedUrl';
    }

    if (resolvedUrl != null && resolvedUrl.startsWith('http')) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: elevation * 2,
              offset: Offset(0, elevation),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.network(
            resolvedUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, error, stack) => _buildStyledCover(),
          ),
        ),
      );
    }

    return _buildStyledCover();
  }

  Widget _buildStyledCover() {
    final colors = gradientColors ?? _pickGradient(judul);
    final spineWidth = width.isFinite ? (width * 0.08).clamp(6.0, 14.0) : 10.0;
    final leftPadding = width.isFinite ? (width * 0.14).clamp(10.0, 18.0) : 14.0;
    final isSmall = height < 90 || (width.isFinite && width < 70);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.28),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Spine highlight on the left
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: spineWidth,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(borderRadius)),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.12),
                  ],
                ),
              ),
            ),
          ),
          // Book Title & Content
          Padding(
            padding: EdgeInsets.fromLTRB(leftPadding, isSmall ? 6 : 10, 8, isSmall ? 6 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: isSmall ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                if (!isSmall) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PUSTAKA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
                Text(
                  judul,
                  maxLines: isSmall ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmall ? 8.5 : (width.isFinite && width < 90 ? 10 : 12),
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
                if (!isSmall && penulis != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    penulis!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: width.isFinite && width < 90 ? 8 : 9,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _pickGradient(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('flutter') || lower.contains('web')) {
      return [const Color(0xFF0F2B66), const Color(0xFF1E5BB5)];
    }
    if (lower.contains('clean') || lower.contains('architecture')) {
      return [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)];
    }
    if (lower.contains('atomic')) {
      return [const Color(0xFF1E293B), const Color(0xFFF59E0B)];
    }
    if (lower.contains('machine') || lower.contains('python')) {
      return [const Color(0xFF064E3B), const Color(0xFF10B981)];
    }
    if (lower.contains('fisika')) {
      return [const Color(0xFF312E81), const Color(0xFF6366F1)];
    }
    if (lower.contains('ui/ux') || lower.contains('design')) {
      return [const Color(0xFF4C1D95), const Color(0xFF8B5CF6)];
    }
    return [AppTheme.primaryNavy, AppTheme.accentBlue];
  }
}
