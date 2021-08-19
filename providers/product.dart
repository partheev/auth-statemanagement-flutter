import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stateapp/config.dart';
import 'package:stateapp/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });
  Future<void> toggleFavorite(String token) async {
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(Config.getProductUrl(id, token));
    try {
      final response =
          await http.patch(url, body: json.encode({'isFavorite': isFavorite}));
      if (response.statusCode >= 400) {
        throw HttpException('unable to add into favorites');
      }
    } catch (error) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw HttpException('Unable to add into favorites!');
    }
  }
}
