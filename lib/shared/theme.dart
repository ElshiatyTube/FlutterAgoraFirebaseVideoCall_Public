import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Colors
const MaterialColor defaultColor = MaterialColor(
  0xffE23D73,
  <int, Color>{
    50: Color(0xffE23D73),
    100: Color(0xffE23D73),
    200: Color(0xffE23D73),
    300: Color(0xffE23D73),
    400: Color(0xffE23D73),
    500: Color(0xffE23D73),
    600: Color(0xffE23D73),
    700: Color(0xffE23D73),
    800: Color(0xffE23D73),
    900: Color(0xffE23D73),
  },
);

ThemeData appTheme = ThemeData(
  buttonTheme: const ButtonThemeData(
    buttonColor: defaultColor,
    textTheme: ButtonTextTheme.primary,
  ),
  primarySwatch: defaultColor,
  scaffoldBackgroundColor: Colors.white,
  canvasColor: Colors.transparent,
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 19.0,
      fontFamily: 'MonstMid',

    ),
    titleSpacing: 19.0,
    backwardsCompatibility: false,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    elevation: 0.0,
  ),
  textTheme: const TextTheme(
    bodyText1: TextStyle(
      fontSize: 17.0,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    subtitle1: TextStyle(
      fontSize: 13.0,
      fontWeight: FontWeight.w600,
      color: Colors.black,
      height: 1.3,
    ),
  ),
);