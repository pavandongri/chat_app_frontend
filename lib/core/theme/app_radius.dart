import 'package:flutter/material.dart';

/// Centralized corner-radius scale. Use these instead of literal
/// `BorderRadius.circular(...)` values in feature code.
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double full = 999;

  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get fullRadius => BorderRadius.circular(full);
}
