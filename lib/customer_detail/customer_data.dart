import 'package:flutter/material.dart';

class Customer {
  String name;
  String number;
  int purchased;
  int paid;

  Customer({
    required this.name,
    required this.number,
    this.purchased = 0,
    this.paid = 0,
  });
}

class CustomerManager extends ChangeNotifier {
  final List<Customer> _customers = [];

  List<Customer> get customers => _customers;

  void addPurchase(String name, String number, int amount) {
    final index = _customers.indexWhere((c) => c.number == number);
    if (index != -1) {
      _customers[index].purchased += amount;
    } else {
      _customers.add(Customer(name: name, number: number, purchased: amount));
    }
    notifyListeners();
  }

  void addSale(String name, String number, int amount) {
    final index = _customers.indexWhere((c) => c.number == number);
    if (index != -1) {
      _customers[index].purchased += amount; // Customer buys more → shop earns
      _customers[index].paid += amount; // Sale is paid immediately
    } else {
      _customers.add(
        Customer(name: name, number: number, purchased: amount, paid: amount),
      );
    }
    notifyListeners();
  }
}

final customerManager = CustomerManager();
