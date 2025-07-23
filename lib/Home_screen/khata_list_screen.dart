import 'package:flutter/material.dart';
import 'package:shop_app/customer_detail/customer_detail_screen.dart';
import 'package:shop_app/customer_detail/customer_data.dart';

class KhataListScreen extends StatelessWidget {
  const KhataListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khata List'),
        backgroundColor: const Color.fromARGB(255, 196, 152, 136),
      ),
      body: AnimatedBuilder(
        animation: customerManager,
        builder: (context, _) {
          final customers = customerManager.customers;

          if (customers.isEmpty) {
            return const Center(child: Text("No customers yet."));
          }

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              final balance = customer.paid - customer.purchased;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.indigo),
                  title: Text(customer.name),
                  subtitle: Text(
                    'Balance: Rs. ${balance.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: balance >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => CustomerDetailScreen(customer: customer),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
