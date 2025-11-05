import 'package:flutter/material.dart';

class Constantes {
  /*
  static String appName = "Xicotepec Turismo";

  static String initialRoute = "/";
  static String homeRoute = "/inicio";

  static String appPackage = "com.xicotepec.turismo";

  static double fontSizeNormal = 15;

  static const double padding = 20;
  static const double avatarRadius = 45;

  //API

  static var protocol = "https";
  static var url = "creaticity.com.mx";
  static var ENDPOINT = protocol + "://" + url + "/cesni/";

  // static var protocol = "http";
  // static var url = "192.168.100.8";
  // static var ENDPOINT = protocol + "://" + url + "/turismo/";

  static var API_HEADERS = {"Content-Type": "application/json"};

  */

  static Color colorPrimario = Color(0xfff0ba00);
  static Color colorSecundario = Color(0xff000000);

  static Color ordenCreada = Color(0xff1976D2);
  static Color ordenPreparacion = Color(0xffEF6C00);
  static Color ordenLista = Color(0xff43A047);

  /*
    Color(0xFFC9013F),
    Color(0xFF000C48),
    Color(0xFF01916E),
    Color(0xFF004500),
    Color(0xFFF89201),
    Color(0xFF001C7D),
    Color(0xFFF45501),
    Color(0xFF037305),
    Color(0xFFF48F3D),
   */

  static ThemeData tema = ThemeData(
    // colorScheme: tema.colorScheme.copyWith(
    //     primary: Constants.colorPrimary, secondary: Constants.colorSecondary),
    primaryColor: Constantes.colorPrimario,
    useMaterial3: true, // Mantiene Material 3

    colorScheme: ColorScheme.fromSeed(
      seedColor: Constantes.colorPrimario, // Cambia aquí el color base
      brightness: Brightness.light, // O Brightness.dark si usas tema oscuro
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Constantes.colorSecundario, // Fondo por defecto
        foregroundColor: Constantes.colorPrimario, // Texto por defecto
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Bordes redondeados
        ),
      ),
    ),
  );
}
