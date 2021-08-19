import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stateapp/config.dart';
import 'package:stateapp/models/http_exception.dart';
import 'package:stateapp/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  Orders(this.authToken, this._orders);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse(Config.authUrl + authToken);
    try {
      final response = await http.get(url);
      final allOrders = json.decode(response.body) as Map<String, dynamic>;
      if (allOrders == null) {
        return;
      }
      List<OrderItem> fetchedProducts = [];
      allOrders.forEach((key, value) {
        fetchedProducts.add(OrderItem(
            id: key,
            amount: value['amount'],
            products: (value['products'] as List<dynamic>)
                .map((e) => CartItem(
                    id: e['id'],
                    price: e['price'],
                    quantity: e['quantity'],
                    title: e['title']))
                .toList(),
            dateTime: DateTime.parse(value['dateTime'])));
      });
      _orders = fetchedProducts.reversed.toList();
      notifyListeners();
    } catch (error) {}
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(Config.authUrl);
    try {
      final timestamp = DateTime.now();
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'products': [
              ...cartProducts
                  .map((e) => {
                        'id': e.id,
                        'title': e.title,
                        'quantity': e.quantity,
                        'price': e.price
                      })
                  .toList()
            ],
            'dateTime': timestamp.toIso8601String()
          }));
      _orders.insert(
          0,
          OrderItem(
            id: timestamp.toString(),
            amount: total,
            products: cartProducts,
            dateTime: timestamp,
          ));
      notifyListeners();
    } catch (error) {
      throw HttpException('Unable to order now!');
    }
  }
}
