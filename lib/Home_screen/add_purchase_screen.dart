import 'package:flutter/material.dart';
import 'package:shop_app/customer_detail/customer_data.dart';
import 'package:shop_app/customer_detail/customer_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({super.key});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final amountController = TextEditingController();
  final _customerService = CustomerService(); // ✅ NEW

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
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Purchase'),
        backgroundColor: const Color.fromARGB(255, 196, 152, 136),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              buildTextField(
                controller: nameController,
                label: 'Customer Name',
                hint: 'Enter your name',
                icon: Icons.person,
                textCapitalization: TextCapitalization.words,
                validator:
                    (value) => value!.isEmpty ? 'Enter customer name' : null,
              ),
              const SizedBox(height: 10),
              buildTextField(
                controller: numberController,
                label: 'Phone Number',
                hint: 'Enter your phone number',
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
                label: 'Purchase Amount',
                hint: 'Enter purchase amount',
                icon: Icons.shopping_cart,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Enter a valid positive amount';
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

                      customerManager.addPurchase(name, number, amount);

                      final updatedCustomer = customerManager.customers
                          .firstWhere((c) => c.number == number);

                      await _customerService.addOrUpdateCustomer(
                        updatedCustomer,
                      ); // ✅ Firestore Sync

                      final fullPhoneNumber = "92${number.substring(1)}";
                      final message = '''
💰 *Abu Bakar General Store - Battal Bazar*

Dear $name,

Thank you for your payment of *Rs. $amount*.

🧾 Your purchase has been recorded successfully.

We appreciate your business and look forward to serving you again!

📍 Battal Bazar
''';

                      try {
                        await sendWhatsAppMessage(fullPhoneNumber, message);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Purchase Added & WhatsApp Sent'),
                          ),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Could not launch WhatsApp"),
                          ),
                        );
                      }
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
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
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
          vertical: 16.0,
          horizontal: 12.0,
        ),
      ),
      validator: validator,
    );
  }
}
