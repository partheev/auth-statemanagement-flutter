import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stateapp/providers/orders.dart';
import 'package:stateapp/widgets/app_drawer.dart';
import '../widgets/order_item.dart' as item;

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _loading = false;
  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _loading = true;
      });
      await Provider.of<Orders>(context, listen: false).fetchOrders();
      setState(() {
        _loading = false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemBuilder: (ctx, i) => item.OrderItem(orderData.orders[i]),
              itemCount: orderData.orders.length,
            ),
    );
  }
}
