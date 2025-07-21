import 'package:flutter/material.dart';
import 'package:shop_app/customer_detail/customer_data.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      if (customer.purchased > 0)
        {
          'type': 'Purchase',
          'amount': customer.purchased,
          'date': '2025-07-10',
        },
      if (customer.paid > 0)
        {'type': 'Sell', 'amount': customer.paid, 'date': '2025-07-11'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("${customer.name}'s Khata"),
        backgroundColor: const Color.fromARGB(255, 196, 152, 136),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${customer.number}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            if (customer.purchased > 0)
              Text('Total Purchased: Rs. ${customer.purchased}'),

            if (customer.paid > 0) Text('Total Sell: Rs. ${customer.paid}'),

            Text('Balance: Rs. ${customer.purchased - customer.paid}'),

            Divider(height: 30),

            Text(
              'Transaction History:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final txn = transactions[index];
                  return ListTile(
                    leading: Icon(
                      txn['type'] == 'Purchase' ? Icons.add : Icons.remove,
                      color:
                          txn['type'] == 'Purchase' ? Colors.red : Colors.green,
                    ),
                    title: Text('${txn['type']} - Rs. ${txn['amount']}'),
                    subtitle: Text('Date: ${txn['date']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
