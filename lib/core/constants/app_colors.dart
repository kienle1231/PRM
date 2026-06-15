/// Centralized color palette for KienCare app.
/// DO NOT use raw Color() values in widgets. Always use these constants.
import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0A0A0A); // Sleek Black
  static const Color primaryLight = Color(0xFF262626); // Dark Gray
  static const Color primarySurface = Color(0xFFF5F5F7); // Apple-like light gray
  static const Color secondary = Color(0xFFD4AF37); // KienCare Premium Gold
  static const Color accent = Color(0xFFD4AF37);
  static const Color accentYellow = Color(0xFFFFC107);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF34C759); // iOS Green
  static const Color error = Color(0xFFFF3B30); // iOS Red
  static const Color warning = Color(0xFFFF9500); // iOS Orange
  static const Color info = Color(0xFF007AFF); // iOS Blue

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1D1D1F); // Apple text dark
  static const Color textSecondary = Color(0xFF86868B); // Apple text light
  static const Color textHint = Color(0xFFC7C7CC);

  // ── Background / Surface ──────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color cardLight = Color(0xFFFBFBFD);
  static const Color cardDark = Color(0xFF1C1C1E);

  // ── Border ─────────────────────────────────────────────────────────────────
  static const Color borderLight = Color(0xFFE5E5EA);
  static const Color borderDark = Color(0xFF38383A);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2C2C2E), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient hotDealGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF3E5AB)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
