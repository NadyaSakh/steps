import 'package:flutter/material.dart';

class AppColors {
  static const Color defaultBackground = Color(0xFFF6FBFF);
  static const Color accent = Color(0xFF476BF0);
  static const Color red = Color(0xFFEB2525);
  static const Color darkGrey = Color(0xFF97A0AF);
  static const Color grey = Color(0xFFD6D9E2);
  static const Color lightGrey = Color(0xFFEFF4F8);
  static const Color slateGray = Color(0xFF97A0AF);

  static const Color greyBorder = Color(0xFFD9D9D9);
  static const Color denim = Color(0xFF1056B7);
  static const Color thirdAccent = Color(0xFFC12E9C);
  static const Color limitBackground = Color(0xFFFFEEEB);
  static const Color shadow = Color(0x1A033767);
  static const Color blue = Color(0xFF164194);
  static const Color greyBlue = Color(0xFF6FA8D0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightOrange = Color(0xFFFFEEEB);
  static const Color lightBlue = Color(0xFF2B9BF4);
  static const Color captionText = Color(0xFF9B9B9B);
  static const Color greyF4 = Color(0xFFF4F4F4);

  static const Color black = Color(0xFF000000);
  static const Color black15 = Color(0x26000000);

  static const Color gradientBlueLight = Color(0xFF90E9FF);
  static const Color gradientBlueHard = Color(0xFF3D8AFF);
  static const Color gradientPurpleLight = Color(0xFFF89AFA);
  static const Color gradientPurpleHard = Color(0xFF926BFF);
  static const Color gradientGreenLight = Color(0xFF54F88B);
  static const Color gradientGreenHard = Color(0xFF33E8F3);
  static const Color gradientOrangeLight = Color(0xFFFFC062);
  static const Color gradientOrangeHard = Color(0xFFFF7777);
}

class AppGradients {
  static const Map<String, List<Color>> _colorsMap = {
    'blue': [AppColors.gradientBlueLight, AppColors.gradientBlueHard],
    'purple': [AppColors.gradientPurpleLight, AppColors.gradientPurpleHard],
    'green': [AppColors.gradientGreenLight, AppColors.gradientGreenHard],
    'orange': [AppColors.gradientOrangeLight, AppColors.gradientOrangeHard]
  };
  static const List<String> _colorsOrder = ['blue', 'purple', 'green', 'orange'];

  /// Возвращает значение по умолчанию, если подходящее не найдено
  static List<Color> bordersByName(String name) {
    return _colorsMap[name] ?? [AppColors.gradientBlueLight, AppColors.gradientBlueHard];
  }

  static List<Color> bordersByIndex(int index) {
    return bordersByName(_colorsOrder[index % _colorsOrder.length]);
  }
}

class AppMaterialColors {
  static const MaterialColor accent = MaterialColor(0xFF164194, <int, Color>{
    50: Color.fromRGBO(19, 56, 126, .1),
    100: Color.fromRGBO(19, 56, 126, .2),
    200: Color.fromRGBO(19, 56, 126, .3),
    300: Color.fromRGBO(19, 56, 126, .4),
    400: Color.fromRGBO(19, 56, 126, .5),
    500: Color.fromRGBO(19, 56, 126, .6),
    600: Color.fromRGBO(19, 56, 126, .7),
    700: Color.fromRGBO(19, 56, 126, .8),
    800: Color.fromRGBO(19, 56, 126, .9),
    900: Color.fromRGBO(19, 56, 126, 1),
  });
}

ThemeData makeAppTheme() {
  final defaultInputBorder = OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: BorderRadius.circular(6),
  );

  final focusedInputBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: AppColors.grey),
    borderRadius: BorderRadius.circular(6),
  );

  final errorInputBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: AppColors.red),
    borderRadius: BorderRadius.circular(6),
  );

  final theme = ThemeData(
    primaryColor: Colors.black87,
    scaffoldBackgroundColor: AppColors.defaultBackground,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      iconTheme: IconThemeData(color: AppColors.accent),
      elevation: 15,
      shadowColor: Colors.black26,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black87,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(color: AppColors.darkGrey),
      hintStyle: const TextStyle(color: AppColors.darkGrey),
      errorStyle: const TextStyle(color: AppColors.red),
      fillColor: AppColors.lightGrey,
      filled: true,
      border: defaultInputBorder,
      focusedBorder: focusedInputBorder,
      enabledBorder: defaultInputBorder,
      errorBorder: errorInputBorder,
      focusedErrorBorder: errorInputBorder,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          height: 17,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Inter',
          height: 1.7,
        ),
        elevation: 0,
      ),
    ),
    cardTheme: const CardTheme(
      elevation: 8,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
    ),
  );

  return theme.copyWith(
    textTheme: theme.textTheme.apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
  );
}
