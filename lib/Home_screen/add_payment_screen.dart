import 'package:flutter/material.dart';
import 'package:shop_app/customer_detail/customer_data.dart';
import 'package:shop_app/customer_detail/customer_service.dart'; // 🔹 NEW
import 'package:url_launcher/url_launcher.dart';

class AddSellScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final amountController = TextEditingController();

  final _customerService = CustomerService(); // 🔹 NEW

  AddSellScreen({super.key});

  Future<void> sendWhatsAppMessage(String phoneNumber, String message) async {
    final url =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ Could not launch: $url');
      throw Exception('Could not launch WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Sell'),
        backgroundColor: const Color.fromARGB(255, 196, 152, 136),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField(
                controller: nameController,
                label: 'Customer Name',
                hint: 'Enter your name',
                icon: Icons.person,
                keyboardType: TextInputType.name,
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 10),
              buildTextField(
                controller: numberController,
                label: 'Phone Number',
                hint: 'Enter phone number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter number';
                  if (value.length != 11 ||
                      !RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Enter valid 11-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              buildTextField(
                controller: amountController,
                label: 'Sell Amount',
                hint: 'Enter sell amount',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Invalid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final name = nameController.text.trim();
                      final number = numberController.text.trim();
                      final amount = int.parse(amountController.text.trim());

                      // 🟡 Add sale in memory
                      customerManager.addSale(name, number, amount);

                      // 🔵 Sync updated customer to Firestore
                      final updatedCustomer = customerManager.customers
                          .firstWhere((c) => c.number == number);
                      await _customerService.addOrUpdateCustomer(
                        updatedCustomer,
                      );

                      // ✅ WhatsApp
                      final fullPhoneNumber = "92${number.substring(1)}";
                      final message = '''
🛍️ *Abu Bakar General Store - Battal Bazar*

Dear $name,

Thank you for shopping with us!

🧾 We’ve recorded your purchase of *Rs. $amount*.

We appreciate your business and look forward to serving you again!

📍 Battal Bazar
''';

                      try {
                        await sendWhatsAppMessage(fullPhoneNumber, message);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sale Added & WhatsApp Sent'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Could not launch WhatsApp"),
                          ),
                        );
                      }

                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.indigo),
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.indigo, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
      validator: validator,
    );
  }
}
