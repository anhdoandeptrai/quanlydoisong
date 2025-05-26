import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFF4CAF50),
  scaffoldBackgroundColor: Color(0xFFF5F5F5),
  colorScheme: ColorScheme.light(
    primary: Color(0xFF4CAF50),
    secondary: Color(0xFFFFC107),
    background: Color(0xFFF5F5F5),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFF44336),
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: Colors.black,
    onSurface: Colors.black,
    onError: Colors.white,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF212121)),
    bodyMedium: TextStyle(color: Color(0xFF757575)),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFF81C784),
  scaffoldBackgroundColor: Color(0xFF121212),
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF81C784),
    secondary: Color(0xFFFFD54F),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    error: Color(0xFFEF5350),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onBackground: Colors.white,
    onSurface: Colors.white,
    onError: Colors.black,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
    bodyMedium: TextStyle(color: Color(0xFFBDBDBD)),
  ),
);
