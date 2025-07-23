import 'package:cloud_firestore/cloud_firestore.dart';
import '../customer_detail/customer_data.dart';

class CustomerService {
  final CollectionReference _customers = FirebaseFirestore.instance.collection(
    'customers',
  );

  // Add or update customer with transactions
  Future<void> addOrUpdateCustomer(Customer customer) async {
    await _customers.doc(customer.number).set({
      'name': customer.name,
      'number': customer.number,
      'purchased': customer.purchased,
      'paid': customer.paid,
      'transactions': customer.transactions.map((txn) => txn.toMap()).toList(),
    }, SetOptions(merge: true));
  }

  // Load all customers from Firestore
  Future<List<Customer>> fetchCustomers() async {
    final snapshot = await _customers.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      final rawTxns = (data['transactions'] ?? []) as List<dynamic>;
      final transactions =
          rawTxns.map((txn) {
            return TransactionEntry(
              type: txn['type'],
              amount: txn['amount'],
              date: DateTime.tryParse(txn['date'] ?? '') ?? DateTime.now(),
            );
          }).toList();

      return Customer(
        name: data['name'] ?? '',
        number: data['number'] ?? '',
        purchased: data['purchased'] ?? 0,
        paid: data['paid'] ?? 0,
        transactions: transactions,
      );
    }).toList();
  }

  // Delete a customer
  Future<void> deleteCustomer(String number) async {
    await _customers.doc(number).delete();
  }
}
