import 'package:flutter/material.dart';
import 'package:shop_app/customer_detail/customer_data.dart';

class ShopKhataScreen extends StatelessWidget {
  const ShopKhataScreen({
    super.key,
    required List<Map<String, dynamic>> customers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Shop Khata Summary'),
        backgroundColor: const Color.fromARGB(255, 196, 152, 136),
      ),
      body: AnimatedBuilder(
        animation: customerManager,
        builder: (context, _) {
          final customers = customerManager.customers;

          int totalPurchased = customers.fold(0, (sum, c) => sum + c.purchased);
          int totalPaid = customers.fold(0, (sum, c) => sum + c.paid);
          int totalBalance = totalPaid - totalPurchased;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                InfoTile(
                  label: '👥 Total Customers',
                  value: customers.length.toString(),
                ),
                InfoTile(
                  label: '🛒 Total Purchased',
                  value: 'Rs. $totalPurchased',
                ),
                InfoTile(label: '💵 Total Sell', value: 'Rs. $totalPaid'),
                InfoTile(label: '📌 Total Balance', value: 'Rs. $totalBalance'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const InfoTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
      ),
    );
  }
}
