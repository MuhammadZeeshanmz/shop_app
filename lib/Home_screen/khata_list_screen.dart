import 'package:flutter/material.dart';
import 'package:shop_app/customer_detail/customer_detail_screen.dart';
import 'package:shop_app/customer_detail/customer_data.dart';

class KhataListScreen extends StatelessWidget {
  const KhataListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Khata List'),
        backgroundColor: const Color.fromARGB(255, 196, 152, 136),
      ),
      body: AnimatedBuilder(
        animation: customerManager,
        builder: (context, _) {
          return ListView.builder(
            itemCount: customerManager.customers.length,
            itemBuilder: (context, index) {
              final customer = customerManager.customers[index];
              final balance = customer.purchased - customer.paid;
              return ListTile(
                title: Text(customer.name),
                subtitle: Text('Balance: Rs. $balance'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerDetailScreen(customer: customer),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
