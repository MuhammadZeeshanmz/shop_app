import 'package:ags/customer_detail/customer_data.dart';
import 'package:ags/customer_detail/customer_service.dart';
import 'package:flutter/material.dart';
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
  final amountController = TextEditingController(); // Total
  final paidAmountController = TextEditingController(); // Paid

  final _customerService = CustomerService();

  bool _hovering = false;
  bool _pressed = false;

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    amountController.dispose();
    paidAmountController.dispose();
    super.dispose();
  }

  String _calculateRemaining() {
    final total = int.tryParse(amountController.text) ?? 0;
    final paid = int.tryParse(paidAmountController.text) ?? 0;
    final remaining = total - paid;
    return remaining >= 0 ? remaining.toString() : '0';
  }

  Future<void> sendWhatsAppMessage(String phoneNumber, String message) async {
    final url =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Purchase',
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
                hint: 'Enter customer name',
                icon: Icons.person,
                textCapitalization: TextCapitalization.words,
                validator:
                    (value) => value!.isEmpty ? 'Enter customer name' : null,
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
                label: 'Total Amount',
                hint: 'Enter total amount',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Enter a valid positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              buildTextField(
                controller: paidAmountController,
                label: 'Paid Amount',
                hint: 'Enter amount paid',
                icon: Icons.payment,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Enter paid amount';
                  final total = int.tryParse(amountController.text) ?? 0;
                  final paid = int.tryParse(value) ?? -1;
                  if (paid < 0) return 'Enter valid amount';
                  if (paid > total) return 'Paid cannot exceed total';
                  return null;
                },
              ),
              const SizedBox(height: 10),

              /// Remaining Amount Display
              const SizedBox(height: 20),

              /// Save Button
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
                      final totalAmount = int.parse(
                        amountController.text.trim(),
                      );
                      final paidAmount = int.parse(
                        paidAmountController.text.trim(),
                      );
                      final remainingAmount = totalAmount - paidAmount;

                      /// ✨ Call new method with partial payment
                      customerManager.addPurchaseWithPartialPayment(
                        name,
                        number,
                        totalAmount,
                        paidAmount,
                      );

                      final updatedCustomer = customerManager.customers
                          .firstWhere((c) => c.number == number);

                      await _customerService.addOrUpdateCustomer(
                        updatedCustomer,
                      );

                      final fullPhoneNumber = "92${number.substring(1)}";
                      final message = '''
💰 *Abu Bakar General Store - Battal Bazar*

Dear $name,

🧾 Purchase: Rs. $totalAmount
✅ Paid: Rs. $paidAmount
⏳ Remaining: Rs. $remainingAmount

Thank you for your purchase.

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
                    child: const Center(
                      child: Text(
                        'Save',
                        style: TextStyle(
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: (_) => setState(() {}), // Update remaining amount live
      keyboardType: keyboardType,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
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
