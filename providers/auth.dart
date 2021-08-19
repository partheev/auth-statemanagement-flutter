import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stateapp/config.dart';
import 'package:stateapp/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _token != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  Future<void> signup(String email, String password) async {
    final url = Uri.parse(Config.firebaseUrl);

    final response = await http.post(
      url,
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
    final extractedData = json.decode(response.body);
    try {
      _token = extractedData['idToken'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(extractedData['expiresIn'])));

      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
      if (extractedData['error'] != null) {
        throw HttpException(extractedData['error']['message']);
      }
    } catch (error) {
      throw error;
    }
  }

  void logout() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timetoexpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timetoexpiry), logout);
  }

  Future<void> signin(String email, String password) async {
    final url = Uri.parse(Config.firebaseUrl);
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {'email': email, 'password': password, 'returnSecureToken': true},
        ),
      );
      final extractedData = json.decode(response.body);
      _token = extractedData['idToken'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(extractedData['expiresIn'])));

      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
      if (extractedData['error'] != null) {
        throw HttpException(extractedData['error']['message']);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    print(!prefs.containsKey('userData'));
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    // print('$_token $_userId first');
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    // print('$_token $_userId second');

    // _token = 'helloworld';
    // _userId = 'helloworld';
    // _expiryDate = DateTime.now();

    notifyListeners();

    _autoLogout();
    return true;
  }
}
