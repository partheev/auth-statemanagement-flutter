import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stateapp/providers/cart.dart';
import 'package:stateapp/providers/orders.dart';
import '../widgets/cart_item.dart' as ci;

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _orderLoading = false;
  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Card'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 20),
                ),
                Spacer(),
                Chip(
                  label: Text('\$${cart.totalAmount.toStringAsFixed(2)}'),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                FlatButton(
                  onPressed: cart.totalAmount <= 0
                      ? null
                      : () async {
                          setState(() {
                            _orderLoading = true;
                          });
                          try {
                            await Provider.of<Orders>(context, listen: false)
                                .addOrder(cart.items.values.toList(),
                                    cart.totalAmount);

                            cart.clearCart();
                            setState(() {
                              _orderLoading = false;
                            });
                          } catch (error) {
                            setState(() {
                              _orderLoading = false;
                            });
                            scaffold.showSnackBar(
                                SnackBar(content: Text('Unable to order now')));
                          }
                        },
                  child: _orderLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Text('ORDER NOW'),
                  textColor: Theme.of(context).primaryColor,
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: cart.itemCount(),
                  itemBuilder: (ctx, i) => ci.CartItem(
                        cart.items.values.toList()[i].id,
                        cart.items.keys.toList()[i],
                        cart.items.values.toList()[i].price,
                        cart.items.values.toList()[i].title,
                        cart.items.values.toList()[i].quantity,
                      )))
        ],
      ),
    );
  }
}
