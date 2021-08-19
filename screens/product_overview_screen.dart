import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stateapp/providers/cart.dart';
import 'package:stateapp/providers/products.dart';
import 'package:stateapp/screens/cart_screen.dart';
import 'package:stateapp/widgets/app_drawer.dart';
import 'package:stateapp/widgets/badge.dart';
import 'package:stateapp/widgets/product_item.dart';
import 'package:stateapp/widgets/products_grid.dart';

enum FilterOptions { All, Favorites }

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _loading = false;
  var _showOnlyFavorites = false;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _loading = true;
      });
      await Provider.of<Products>(context, listen: false).fetchProducts();
      setState(() {
        _loading = false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
              onSelected: (selectedValue) {
                setState(() {
                  if (selectedValue == FilterOptions.All)
                    _showOnlyFavorites = false;
                  else {
                    _showOnlyFavorites = true;
                  }
                });
              },
              itemBuilder: (_) => [
                    PopupMenuItem(child: Text('All'), value: FilterOptions.All),
                    PopupMenuItem(
                        child: Text('Show Favorites'),
                        value: FilterOptions.Favorites)
                  ]),
          Consumer<Cart>(
            builder: (_, cart, child) => Badge(
              child: child,
              value: cart.itemCount().toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
