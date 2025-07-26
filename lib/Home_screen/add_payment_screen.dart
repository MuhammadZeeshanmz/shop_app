import 'package:ags/customer_detail/customer_data.dart';
import 'package:ags/customer_detail/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AddSellScreen extends StatefulWidget {
  const AddSellScreen({super.key});

  @override
  State<AddSellScreen> createState() => _AddSellScreenState();
}

class _AddSellScreenState extends State<AddSellScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final amountController = TextEditingController();

  final _customerService = CustomerService();

  bool _hovering = false;
  bool _pressed = false;

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
        title: const Text(
          'Add Sell',
          style: TextStyle(
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

              // Custom Hover Save Button
              MouseRegion(
                onEnter: (_) => setState(() => _hovering = true),
                onExit: (_) => setState(() => _hovering = false),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapUp: (_) => setState(() => _pressed = false),
                  onTapCancel: () => setState(() => _pressed = false),
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      final name = nameController.text.trim();
                      final number = numberController.text.trim();
                      final amount = int.parse(amountController.text.trim());

                      customerManager.addSale(name, number, amount);

                      final updatedCustomer = customerManager.customers
                          .firstWhere((c) => c.number == number);

                      await _customerService.addOrUpdateCustomer(
                        updatedCustomer,
                      );

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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform:
                        _pressed
                            ? (Matrix4.identity()..scale(0.97))
                            : Matrix4.identity(),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _hovering ? Colors.indigo.shade700 : Colors.indigo,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow:
                          _hovering
                              ? [
                                BoxShadow(
                                  color: Colors.indigo.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                              : [],
                    ),
                    child: Center(
                      child: Text(
                        _hovering ? 'Save' : 'Save',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
