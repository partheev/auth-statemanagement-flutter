import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stateapp/config.dart';
import 'package:stateapp/models/http_exception.dart';
import 'product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];
  final String authtoken;
  Products(this.authtoken, this._items);
  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse(
        'https://flutter-38d91-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authtoken');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return null;
      final List<Product> loadedProducts = [];
      extractedData.forEach((key, value) {
        loadedProducts.add(Product(
            id: key,
            isFavorite: value['isFavorite'],
            title: value['title'],
            description: value['description'],
            price: value['price'],
            imageUrl: value['imageUrl']));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw HttpException('message');
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://flutter-38d91-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authtoken');

    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavorite': product.isFavorite,
          }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }

    // }).catchError((error) {
    //   throw error;
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    final url = Uri.parse(Config.getProductUrl(id, authtoken));
    await http.patch(url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl
        }));
    _items[productIndex] = newProduct;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[productIndex];

    _items.removeAt(productIndex);
    notifyListeners();
    final url = Uri.parse(Config.getProductUrl(id, authtoken));
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.add(existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    } else {
      existingProduct = null;
    }
  }
}
