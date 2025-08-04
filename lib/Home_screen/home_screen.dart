import 'package:ags/Home_screen/ShopKhataScreen.dart';
import 'package:ags/Home_screen/add_payment_screen.dart';
import 'package:ags/Home_screen/add_purchase_screen.dart';
import 'package:ags/Home_screen/home_card.dart';
import 'package:ags/Home_screen/khata_list_screen.dart';
import 'package:ags/login/login_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            title: Row(
              children: const [
                Icon(Icons.logout, color: Colors.redAccent),
                SizedBox(width: 10),
                Text(
                  'Logout / Delete',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Would you like to logout or permanently delete your account?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.of(ctx).pop(false),
                icon: const Icon(Icons.cancel, color: Colors.grey),
                label: const Text('Cancel'),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(ctx).pop(true),
                icon: const Icon(Icons.logout, color: Colors.green),
                label: const Text('Logout'),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(ctx).pop(null),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    final user = FirebaseAuth.instance.currentUser;

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else if (shouldLogout == null && user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
        await user.delete();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Failed to delete account. Try logging in again.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          children: [
            Image(
              image: AssetImage('assets/cwhite.png'),
              height: 40,
              width: 40,
            ),
            SizedBox(width: 8),
          ],
        ),
        backgroundColor: Color(0xFF4CAF50),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            color: Colors.white,
            onPressed: () => logoutUser(context),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double cardSpacing = constraints.maxHeight * 0.02;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  HomeCard(
                    title: 'Add Purchase',
                    icon: Icons.add_shopping_cart,
                    route: AddPurchaseScreen(),
                    cardColor: Colors.white,
                    textColor: Color(0xFF212121),
                    iconColor: Color(0xFF4CAF50),
                  ),
                  SizedBox(height: cardSpacing),
                  HomeCard(
                    title: 'Add Sell',
                    icon: Icons.payment,
                    route: AddSellScreen(),
                    cardColor: Colors.white,
                    textColor: Color(0xFF212121),
                    iconColor: Color(0xFF4CAF50),
                  ),
                  SizedBox(height: cardSpacing),
                  HomeCard(
                    title: 'View Khata',
                    icon: Icons.receipt_long,
                    route: KhataListScreen(),
                    cardColor: Colors.white,
                    textColor: Color(0xFF212121),
                    iconColor: Color(0xFF4CAF50),
                  ),
                  SizedBox(height: cardSpacing),
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
        },
      ),
    );
  }
}
