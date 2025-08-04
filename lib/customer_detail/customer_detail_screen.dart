import 'package:ags/customer_detail/customer_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final remaining = customer.purchased - customer.paid;

    final remainingColor =
        remaining > 0
            ? Colors.red
            : remaining < 0
            ? Colors.green
            : Colors.grey;

    final transactions = [...customer.transactions];
    transactions.sort((a, b) => b.date.compareTo(a.date)); // newest first

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${customer.name} Khata",
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
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
            Text('💵 Total Sell: Rs. ${customer.purchased.toStringAsFixed(0)}'),
            Text('💰 Total Paid: Rs. ${customer.paid.toStringAsFixed(0)}'),
            Text(
              '📊 Remaining Amount: Rs. ${remaining.abs().toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: remainingColor,
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
                          final formattedDate = DateFormat(
                            'yyyy-MM-dd',
                          ).format(txn.date);

                          String label;
                          IconData icon;
                          Color iconColor;

                          switch (txn.type) {
                            case 'Purchase':
                              label = '💵 Sold';
                              icon = Icons.sell;
                              iconColor = Colors.red;
                              break;
                            case 'Payment':
                              label = '💰 Paid';
                              icon = Icons.payments_outlined;
                              iconColor = Colors.green;
                              break;
                            case 'Sell':
                              label = '💵 Sold';
                              icon = Icons.sell;
                              iconColor = Colors.indigo;
                              break;
                            default:
                              label = '🔁 ${txn.type}';
                              icon = Icons.swap_horiz;
                              iconColor = Colors.grey;
                          }

                          return Card(
                            elevation: 1,
                            child: ListTile(
                              leading: Icon(icon, color: iconColor),
                              title: Text('$label - Rs. ${txn.amount}'),
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
