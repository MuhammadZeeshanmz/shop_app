import 'package:flutter/material.dart';
import 'package:shop_app/customer_detail/customer_data.dart';
import 'package:intl/intl.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final balance = customer.paid - customer.purchased;

    final status =
        balance > 0
            ? 'Advance'
            : balance < 0
            ? 'Due'
            : 'Cleared';

    final balanceColor =
        balance > 0
            ? Colors.green
            : balance < 0
            ? Colors.red
            : Colors.grey;

    final transactions = [...customer.transactions]; // clone the list
    transactions.sort((a, b) => b.date.compareTo(a.date)); // newest first

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${customer.name}'s Khata",
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📞 Phone: ${customer.number}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '🛒 Total Purchased: Rs. ${customer.purchased.toStringAsFixed(0)}',
            ),
            Text('💵 Total Sell: Rs. ${customer.paid.toStringAsFixed(0)}'),
            Text(
              '📊 $status: Rs. ${balance.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: balanceColor,
              ),
            ),
            const Divider(height: 30),
            const Text(
              '🧾 Transaction History:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  transactions.isEmpty
                      ? const Center(child: Text('No transactions yet.'))
                      : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final txn = transactions[index];
                          final isPurchase = txn.type == 'Purchase';
                          final formattedDate = DateFormat(
                            'yyyy-MM-dd',
                          ).format(txn.date);

                          return Card(
                            elevation: 1,
                            child: ListTile(
                              leading: Icon(
                                isPurchase
                                    ? Icons.add_circle_outline
                                    : Icons.remove_circle_outline,
                                color: isPurchase ? Colors.red : Colors.green,
                              ),
                              title: Text(
                                '${isPurchase ? '🛒 Purchased' : '💵 Sell'} - Rs. ${txn.amount}',
                              ),
                              subtitle: Text('Date: $formattedDate'),
                            ),
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
