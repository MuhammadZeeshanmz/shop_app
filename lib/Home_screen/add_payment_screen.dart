import 'package:flutter/material.dart';
import 'package:shop_app/customer_detail/customer_data.dart';

class AddSellScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final amountController = TextEditingController();

  AddSellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Sell'),
        backgroundColor: const Color.fromARGB(255, 196, 152, 136),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  labelStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
                  hintText: "Enter your name",
                  prefixIcon: Icon(Icons.near_me, color: Colors.indigo),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: numberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
                  hintText: "Enter your Phone number",
                  prefixIcon: Icon(Icons.phone, color: Colors.indigo),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) => value!.isEmpty ? 'Enter number' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Sell Amount',
                  labelStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
                  hintText: "Enter Sell Amount",
                  prefixIcon: Icon(Icons.attach_money, color: Colors.indigo),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (int.tryParse(value) == null) return 'Invalid amount';
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final name = nameController.text.trim();
                    final number = numberController.text.trim();
                    final amount = int.parse(amountController.text.trim());

                    customerManager.addSale(
                      name,
                      number,
                      amount,
                    ); // Sale recorded

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Sale Added')));
                    Navigator.pop(context);
                  }
                },

                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
