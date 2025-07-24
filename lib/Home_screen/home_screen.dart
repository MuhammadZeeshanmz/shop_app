import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_app/login/login_view.dart';
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

  Future<void> logoutUser(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Logout'),
            content: Text('Do you want to logout or delete your account?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('Logout'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.of(ctx).pop(null), // Special case: delete
                child: Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    final user = FirebaseAuth.instance.currentUser;

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      print("✅ User signed out");
    } else if (shouldLogout == null && user != null) {
      try {
        final uid = user.uid;

        // Delete Firestore document
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();
        print("🗑️ User document deleted");

        // Delete Firebase Auth account
        await user.delete();
        print("🗑️ User account deleted");
      } catch (e) {
        print("❌ Failed to delete account: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete account. Try logging in again."),
          ),
        );
      }
    }

    // Navigate to login in all cases
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Khata'),
        backgroundColor: const Color.fromARGB(255, 196, 152, 136),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => logoutUser(context),
          ),
        ],
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
