import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stateapp/helpers/custom_routes.dart';
import 'package:stateapp/providers/auth.dart';
import 'package:stateapp/providers/orders.dart';
import 'package:stateapp/screens/auth_screen.dart';
import 'package:stateapp/screens/cart_screen.dart';
import 'package:stateapp/screens/edit_product_screen.dart';
import 'package:stateapp/screens/orders_screen.dart';
import 'package:stateapp/screens/splash_screen.dart';
import 'package:stateapp/screens/user_products_screen.dart';
import './providers/cart.dart';
import './providers/products.dart';
import './screens/product_overview_screen.dart';
import './screens/products_detail_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (ctx) => Products('hell', []),
            update: (ctx, auth, previousProduccts) => Products(auth.token,
                previousProduccts == null ? [] : previousProduccts.items),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders('hell', []),
            update: (ctx, auth, previousProduccts) => Orders(auth.token,
                previousProduccts == null ? [] : previousProduccts.orders),
          ),
          // ChangeNotifierProvider(
          //   create: (ctx) => Products(),
          // ),
          ChangeNotifierProvider(create: (ctx) => Cart()),
          // ChangeNotifierProvider(create: (ctx) => Orders()),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'MyShop',
            home: auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            theme: ThemeData(
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransistionBuilder(),
                TargetPlatform.iOS: CustomPageTransistionBuilder(),
              }),
              primaryColor: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
            ),
            routes: {
              CartScreen.routeName: (ctx) => CartScreen(),
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            },
          ),
        ));
  }
}
