import 'package:flutter/material.dart';
import 'package:shop_app/Home_screen/ShopKhataScreen.dart';
import 'package:shop_app/Home_screen/add_payment_screen.dart';
import 'package:shop_app/Home_screen/add_purchase_screen.dart';
import 'package:shop_app/Home_screen/home_card.dart';
import 'package:shop_app/Home_screen/khata_list_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final List<Map<String, dynamic>> customersList = [
    {
      'name': 'Ali Khan',
      'number': '03001234567',
      'purchased': 5000,
      'paid': 2000,
    },
    {
      'name': 'Sara Ahmed',
      'number': '03019876543',
      'purchased': 3000,
      'paid': 3000,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Khata'),
        backgroundColor: const Color.fromARGB(255, 196, 152, 136),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            HomeCard(
              title: 'Add Purchase',
              icon: Icons.add_shopping_cart,
              route: AddPurchaseScreen(),
            ),
            HomeCard(
              title: 'Add Sell',
              icon: Icons.payment,
              route: AddSellScreen(),
            ),
            HomeCard(
              title: 'View Khata',
              icon: Icons.receipt_long,
              route: KhataListScreen(),
            ),
            HomeCard(
              title: 'Shop Summary',
              icon: Icons.bar_chart,
              route: ShopKhataScreen(customers: customersList),
            ),
          ],
        ),
      ),
    );
  }
}
