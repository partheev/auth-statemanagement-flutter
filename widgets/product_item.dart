import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stateapp/providers/auth.dart';
import 'package:stateapp/providers/cart.dart';
import 'package:stateapp/providers/product.dart';
import 'package:stateapp/screens/products_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scaffoldmessenger = ScaffoldMessenger.of(context);
    final product = Provider.of<Product>(context);
    final auth = Provider.of<Auth>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
            icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () async {
              try {
                await product.toggleFavorite(auth.token);
              } catch (error) {
                scaffoldmessenger.showSnackBar(
                    SnackBar(content: Text('Unable to add into favorites!')));
              }
            },
            color: Theme.of(context).accentColor,
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cart.addItem(
                product.id,
                product.price,
                product.title,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Added item to cart!',
                ),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    cart.removeItem(product.id);
                  },
                ),
              ));
            },
          ),
        ),
      ),
    );
  }
}
