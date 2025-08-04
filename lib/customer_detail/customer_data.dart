import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionEntry {
  final String type; // 'Purchase', 'Sell', or 'Payment'
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
      type: map['type'] ?? '',
      amount: map['amount'] ?? 0,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }
}

class Customer {
  String name;
  String number;
  int purchased; // Interpreted as "Total Sell"
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
          (map['transactions'] as List<dynamic>? ?? [])
              .map(
                (e) => TransactionEntry.fromMap(Map<String, dynamic>.from(e)),
              )
              .toList(),
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
    try {
      print("🔄 Loading customers from Firestore...");
      final snapshot = await _collection.get();
      _customers.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final customer = Customer.fromMap(data);
        _customers.add(customer);
        print("✅ Loaded customer: ${customer.name} (${customer.number})");
      }

      notifyListeners();
      print("📢 All customers loaded and listeners notified");
    } catch (e) {
      print("❌ Error loading customers: $e");
    }
  }

  /// Old: Simple Purchase
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

  /// New: Purchase with Partial Payment
  Future<void> addPurchaseWithPartialPayment(
    String name,
    String number,
    int totalAmount,
    int paidAmount,
  ) async {
    final index = _customers.indexWhere((c) => c.number == number);

    final purchaseTxn = TransactionEntry(
      type: 'Purchase',
      amount: totalAmount,
      date: DateTime.now(),
    );

    final paidTxn = TransactionEntry(
      type: 'Payment',
      amount: paidAmount,
      date: DateTime.now(),
    );

    if (index != -1) {
      final customer = _customers[index];
      customer.purchased += totalAmount;
      customer.paid += paidAmount;
      customer.transactions.addAll([purchaseTxn, paidTxn]);
    } else {
      _customers.add(
        Customer(
          name: name,
          number: number,
          purchased: totalAmount,
          paid: paidAmount,
          transactions: [purchaseTxn, paidTxn],
        ),
      );
    }

    await _syncToFirestore(number);
    notifyListeners();
  }

  /// Old: Simple Sale (not used now)
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

  /// ✅ New: Sale with Partial Payment (Fix: Add totalAmount to `purchased`)
  Future<void> addSaleWithPartialPayment(
    String name,
    String number,
    int totalAmount,
    int paidAmount,
  ) async {
    final index = _customers.indexWhere((c) => c.number == number);

    final sellTxn = TransactionEntry(
      type: 'Sell',
      amount: totalAmount,
      date: DateTime.now(),
    );

    final paidTxn = TransactionEntry(
      type: 'Payment',
      amount: paidAmount,
      date: DateTime.now(),
    );

    if (index != -1) {
      final customer = _customers[index];
      customer.purchased += totalAmount; // ✅ Add this to count as sell
      customer.paid += paidAmount;
      customer.transactions.addAll([sellTxn, paidTxn]);
    } else {
      _customers.add(
        Customer(
          name: name,
          number: number,
          purchased: totalAmount, // ✅ Track sale in "purchased"
          paid: paidAmount,
          transactions: [sellTxn, paidTxn],
        ),
      );
    }

    await _syncToFirestore(number);
    notifyListeners();
  }

  /// 🔁 Sync to Firestore
  Future<void> _syncToFirestore(String number) async {
    final customer = _customers.firstWhere((c) => c.number == number);
    await _collection.doc(number).set(customer.toMap());
    print("📤 Synced customer ${customer.name} to Firestore");
  }
}

final customerManager = CustomerManager();
