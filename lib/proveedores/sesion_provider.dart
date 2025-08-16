import 'package:ordenes/modelos/usuario.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SesionProvider extends ChangeNotifier {
  Usuario? _session;
  static const String _sessionKey = 'session_data';

  Usuario? get session => _session;
  bool get isLoggedIn => _session != null;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionKey);
    if (jsonString != null) {
      final data = Usuario.fromJson(json.decode(jsonString));
      _session = data;
      notifyListeners();
    }
  }

  Future<void> setSession(Usuario data) async {
    _session = data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, json.encode(data.toJson()));
    notifyListeners();
  }

  Future<void> clearSession() async {
    _session = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }
}
