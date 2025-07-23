import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionEntry {
  final String type; // 'Purchase' or 'Sell'
  final int amount;
  final DateTime date;

  TransactionEntry({
    required this.type,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {'type': type, 'amount': amount, 'date': date.toIso8601String()};
  }

  factory TransactionEntry.fromMap(Map<String, dynamic> map) {
    return TransactionEntry(
      type: map['type'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }
}

class Customer {
  String name;
  String number;
  int purchased;
  int paid;
  List<TransactionEntry> transactions;

  Customer({
    required this.name,
    required this.number,
    this.purchased = 0,
    this.paid = 0,
    this.transactions = const [],
  });

  int get balance => paid - purchased;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'number': number,
      'purchased': purchased,
      'paid': paid,
      'balance': balance,
      'transactions': transactions.map((e) => e.toMap()).toList(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      name: map['name'] ?? '',
      number: map['number'] ?? '',
      purchased: map['purchased'] ?? 0,
      paid: map['paid'] ?? 0,
      transactions:
          map['transactions'] != null
              ? List<TransactionEntry>.from(
                (map['transactions'] as List).map(
                  (e) => TransactionEntry.fromMap(e),
                ),
              )
              : [],
    );
  }
}

class CustomerManager extends ChangeNotifier {
  final List<Customer> _customers = [];
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    'customers',
  );

  List<Customer> get customers => _customers;

  Future<void> loadCustomersFromFirestore() async {
    final snapshot = await _collection.get();
    _customers.clear();
    for (var doc in snapshot.docs) {
      _customers.add(Customer.fromMap(doc.data() as Map<String, dynamic>));
    }
    notifyListeners();
  }

  Future<void> addPurchase(String name, String number, int amount) async {
    final index = _customers.indexWhere((c) => c.number == number);
    final txn = TransactionEntry(
      type: 'Purchase',
      amount: amount,
      date: DateTime.now(),
    );

    if (index != -1) {
      _customers[index].purchased += amount;
      _customers[index].transactions.add(txn);
    } else {
      _customers.add(
        Customer(
          name: name,
          number: number,
          purchased: amount,
          transactions: [txn],
        ),
      );
    }
    await _syncToFirestore(number);
    notifyListeners();
  }

  Future<void> addSale(String name, String number, int amount) async {
    final index = _customers.indexWhere((c) => c.number == number);
    final txn = TransactionEntry(
      type: 'Sell',
      amount: amount,
      date: DateTime.now(),
    );

    if (index != -1) {
      _customers[index].paid += amount;
      _customers[index].transactions.add(txn);
    } else {
      _customers.add(
        Customer(name: name, number: number, paid: amount, transactions: [txn]),
      );
    }
    await _syncToFirestore(number);
    notifyListeners();
  }

  Future<void> _syncToFirestore(String number) async {
    final customer = _customers.firstWhere((c) => c.number == number);
    await _collection.doc(number).set(customer.toMap());
  }
}

final customerManager = CustomerManager();
