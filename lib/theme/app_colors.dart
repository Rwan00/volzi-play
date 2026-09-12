import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const night = Color(0xFF05080C);
  static const ink = Color(0xFF070C12);
  static const charcoal = Color(0xFF0D161C);
  static const graphite = Color(0xFF142028);
  static const line = Color(0x334FE8D8);
  static const gold = Color(0xFF4FE8D8);
  static const goldDeep = Color(0xFF1FB8A8);
  static const goldSoft = Color(0xFFB8F8F0);
  static const cream = Color(0xFFE6F7F4);
  static const muted = Color(0xFF7A9A98);
  static const danger = Color(0xFFE07A86);

  static const wash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0C1A1E), Color(0xFF05080C), Color(0xFF081418)],
  );

  static const goldSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC4FFF6), Color(0xFF4FE8D8), Color(0xFF169A8C)],
  );
}
