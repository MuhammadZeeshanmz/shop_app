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
                  style: TextStyle(color: Color(0xFFF44336)),
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
            content: Text("Failed to delete account. Try logging in again."),
            backgroundColor: Color(0xFFF44336),
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
      body: Padding(
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
              // animate: true,
            ),
            SizedBox(height: 16),
            HomeCard(
              title: 'Add Sell',
              icon: Icons.payment,
              route: AddSellScreen(),
              cardColor: Colors.white,
              textColor: Color(0xFF212121),
              iconColor: Color(0xFF4CAF50),
            ),
            SizedBox(height: 16),
            HomeCard(
              title: 'View Khata',
              icon: Icons.receipt_long,
              route: KhataListScreen(),
              cardColor: Colors.white,
              textColor: Color(0xFF212121),
              iconColor: Color(0xFF4CAF50),
            ),
            SizedBox(height: 16),
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
