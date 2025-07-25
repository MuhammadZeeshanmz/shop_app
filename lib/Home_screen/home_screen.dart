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
            title: Text('Logout', style: TextStyle(color: Color(0xFF212121))),
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
                onPressed: () => Navigator.of(ctx).pop(null),
                child: Text(
                  'Delete Account',
                  style: TextStyle(color: Color(0xFFF44336)), // Error Red
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
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();
        print("🗑️ User document deleted");

        await user.delete();
        print("🗑️ User account deleted");
      } catch (e) {
        print("❌ Failed to delete account: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete account. Try logging in again."),
            backgroundColor: Color(0xFFF44336),
          ),
        );
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        title: Text(
          'A G S',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white, // Dark text
          ),
        ),
        backgroundColor: Color(0xFF4CAF50), // Primary Green
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            color: Colors.white,
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
              cardColor: Colors.white,
              textColor: Color(0xFF212121),
              iconColor: Color(0xFF4CAF50),
            ),
            HomeCard(
              title: 'Add Sell',
              icon: Icons.payment,
              route: AddSellScreen(),
              cardColor: Colors.white,
              textColor: Color(0xFF212121),
              iconColor: Color(0xFF4CAF50),
            ),
            HomeCard(
              title: 'View Khata',
              icon: Icons.receipt_long,
              route: KhataListScreen(),
              cardColor: Colors.white,
              textColor: Color(0xFF212121),
              iconColor: Color(0xFF4CAF50),
            ),
            HomeCard(
              title: 'Shop Summary',
              icon: Icons.bar_chart,
              route: ShopKhataScreen(customers: customersList),
              cardColor: Colors.white,
              textColor: Color(0xFF212121),
              iconColor: Color(0xFF4CAF50),
            ),
          ],
        ),
      ),
    );
  }
}
