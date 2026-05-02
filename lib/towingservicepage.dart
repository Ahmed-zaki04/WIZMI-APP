import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TowingServicePage extends StatefulWidget {
  const TowingServicePage({super.key});

  @override
  State<TowingServicePage> createState() => _TowingServicePageState();
}

class _TowingServicePageState extends State<TowingServicePage> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryColor = const Color(0xFF0D47A1); // Navy Blue from homepage

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _carModelController = TextEditingController();
  final _plateNumberController = TextEditingController();
  bool _urgentRequest = false;
  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        debugPrint('Current user: ${user?.uid}'); // Log user ID
        
        if (user == null) {
          if (mounted) {
            _showErrorDialog(context, 'Please login to submit a request.');
          }
          return;
        }

        debugPrint('Creating towing request for user: ${user.uid}'); // Log before creating request
        
        final requestData = {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
          'carModel': _carModelController.text,
          'plateNumber': _plateNumberController.text,
          'urgent': _urgentRequest,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending',
          'userId': user.uid
        };
        
        debugPrint('Request data to be submitted: $requestData'); // Log request data
        
        await FirebaseFirestore.instance.collection('towing_requests').add(requestData);

        if (mounted) {
          _showSuccessDialog(context, 'Your towing request has been submitted successfully! Our team will contact you shortly.');
          _formKey.currentState!.reset();
          setState(() {
            _urgentRequest = false;
          });
          _nameController.clear();
          _phoneController.clear();
          _locationController.clear();
          _carModelController.clear();
          _plateNumberController.clear();
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog(context, 'There was an error submitting your request: $e');
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _carModelController.dispose();
    _plateNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Towing Service'),
        backgroundColor: _primaryColor,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "24/7 Emergency Towing",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Professional assistance whenever you need it",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information
                    const Text(
                      "Personal Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    buildTextField(
                      Icons.person_outline,
                      "Full Name",
                      controller: _nameController,
                    ),
                    const SizedBox(height: 12),
                    buildTextField(
                      Icons.phone_outlined,
                      "Phone Number",
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),

                    // Vehicle Information
                    const Text(
                      "Vehicle Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    buildTextField(
                      Icons.directions_car_outlined,
                      "Car Model",
                      controller: _carModelController,
                    ),
                    const SizedBox(height: 12),
                    buildTextField(
                      Icons.numbers_outlined,
                      "Plate Number",
                      controller: _plateNumberController,
                    ),
                    const SizedBox(height: 18),

                    // Location Information
                    const Text(
                      "Location Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    buildTextField(
                      Icons.location_on_outlined,
                      "Current Location",
                      controller: _locationController,
                      hint: "Enter your exact location",
                    ),
                    const SizedBox(height: 15),

                    // Urgent Request Switch
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _urgentRequest ? _primaryColor.withValues(alpha: 0.1) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _urgentRequest ? _primaryColor : Colors.grey.shade300,
                        ),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          "Urgent Request",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          "Priority assistance · Standard EGP 150 / Urgent EGP 250",
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _urgentRequest,
                        activeColor: _primaryColor,
                        onChanged: (bool value) {
                          setState(() {
                            _urgentRequest = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _urgentRequest ? 'Urgent Towing' : 'Standard Towing',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _urgentRequest ? 'EGP 250' : 'EGP 150',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text(
                                "REQUEST TOWING",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    IconData icon,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => value == null || value.isEmpty ? "Please enter $label" : null,
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Success',
      desc: message,
      btnOkOnPress: () {
        Navigator.pop(context);
      },
      btnOkColor: const Color(0xFF0D47A1),
    ).show();
  }

  void _showErrorDialog(BuildContext context, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {},
      btnOkColor: Colors.red,
    ).show();
  }
}