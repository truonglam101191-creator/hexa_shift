import 'package:flutter/material.dart';

/// Curated color palette for Hexa Shift.
/// Dark theme with vibrant hex tile gradients and glassmorphism overlays.
class AppColors {
  AppColors._();

  // ── Background & Scaffold ──────────────────────────────────────────────
  static const Color scaffoldDark = Color(0xFF0A0E1A);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color cardDark = Color(0xFF1A2235);

  // ── Primary Accent ─────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryGlow = Color(0x406C63FF);

  // ── Hex Tile Colors (one hue per ArrowDirection) ───────────────────────
  /// Up → Cool cyan
  static const Color tileUp = Color(0xFF00D4AA);
  static const Color tileUpGlow = Color(0xFF00FFD0);

  /// Down → Warm coral
  static const Color tileDown = Color(0xFFFF6B6B);
  static const Color tileDownGlow = Color(0xFFFF8A8A);

  /// UpLeft → Electric purple
  static const Color tileUpLeft = Color(0xFFA855F7);
  static const Color tileUpLeftGlow = Color(0xFFC084FC);

  /// UpRight → Vivid amber
  static const Color tileUpRight = Color(0xFFFBBF24);
  static const Color tileUpRightGlow = Color(0xFFFCD34D);

  /// DownLeft → Ocean blue
  static const Color tileDownLeft = Color(0xFF3B82F6);
  static const Color tileDownLeftGlow = Color(0xFF60A5FA);

  /// DownRight → Hot pink
  static const Color tileDownRight = Color(0xFFEC4899);
  static const Color tileDownRightGlow = Color(0xFFF472B6);

  // ── Tile States ────────────────────────────────────────────────────────
  static const Color tileCleared = Color(0x33FFFFFF);
  static const Color tileClearedBorder = Color(0x22FFFFFF);
  static const Color tileBorder = Color(0x55FFFFFF);
  static const Color tileSelected = Color(0xFFFFFFFF);
  static const Color tileHighlight = Color(0xAAFFFFFF);
  static const Color arrowColor = Color(0xEEFFFFFF);

  // ── Glassmorphism ──────────────────────────────────────────────────────
  static const Color glassFill = Color(0x18FFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);

  // ── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // ── Utility ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  /// Returns the fill color for a tile based on its [directionIndex].
  /// Index mapping: 0=up, 1=down, 2=upLeft, 3=upRight, 4=downLeft, 5=downRight.
  static Color tileColorForDirection(int directionIndex) {
    return switch (directionIndex) {
      0 => tileUp,
      1 => tileDown,
      2 => tileUpLeft,
      3 => tileUpRight,
      4 => tileDownLeft,
      5 => tileDownRight,
      _ => tileUp,
    };
  }

  /// Returns the glow color for a tile based on its [directionIndex].
  static Color tileGlowForDirection(int directionIndex) {
    return switch (directionIndex) {
      0 => tileUpGlow,
      1 => tileDownGlow,
      2 => tileUpLeftGlow,
      3 => tileUpRightGlow,
      4 => tileDownLeftGlow,
      5 => tileDownRightGlow,
      _ => tileUpGlow,
    };
  }
}
