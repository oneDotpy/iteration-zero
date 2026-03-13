// lib/theme/app_text_styles.dart
import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle display(Color c) => TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: c,
        height: 1.1,
      );

  static TextStyle heading1(Color c) => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: c,
        height: 1.2,
      );

  static TextStyle heading2(Color c) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: c,
        height: 1.25,
      );

  static TextStyle heading3(Color c) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: c,
        height: 1.3,
      );

  static TextStyle body(Color c) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: c,
        height: 1.5,
      );

  static TextStyle bodyMed(Color c) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: c,
        height: 1.5,
      );

  static TextStyle small(Color c) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: c,
        height: 1.4,
      );

  static TextStyle button(Color c) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: c,
        height: 1.0,
      );
}
