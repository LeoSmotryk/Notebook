import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.indigo;
  static const Color background = Colors.white;
  static const Color border = Colors.indigo;
  static const Color error = Colors.red;
}

class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle noteTag = TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: Colors.grey,
  );

  static const TextStyle dialogTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle dialogContent = TextStyle(
    color: Colors.black,
    fontSize: 16,
  );
}

class AppDecorations {
  static BoxDecoration borderBottom = BoxDecoration(
    color: AppColors.background,
    border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
  );

  static BoxDecoration borderLeft = BoxDecoration(
    color: AppColors.background,
    border: Border(left: BorderSide(color: AppColors.border, width: 2)),
  );
}

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.indigo,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.primary),
    titleTextStyle: AppTextStyles.appBarTitle,
  ),
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.primary,
    selectionColor: AppColors.primary.withOpacity(0.3),
    selectionHandleColor: AppColors.primary,
  ),
);