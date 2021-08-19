import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stateapp/providers/products.dart';
import 'package:stateapp/screens/edit_product_screen.dart';
import 'package:stateapp/widgets/app_drawer.dart';
import 'package:stateapp/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/usersProducts';

  Future<void> _refreshProducts(BuildContext context) async {
    try {
      Provider.of<Products>(context, listen: false).fetchProducts();
    } catch (error) {
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('An error occured!'),
                content: Text('Something went wrong.'),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text('Okay'))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ListView.builder(
            itemBuilder: (_, i) => Column(
              children: [
                UserProductItem(productData.items[i].id,
                    productData.items[i].title, productData.items[i].imageUrl),
                Divider(),
              ],
            ),
            itemCount: productData.items.length,
          ),
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
