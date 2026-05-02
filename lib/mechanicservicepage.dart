import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wizmi/services/user_profile_service.dart';

class MechanicService extends StatefulWidget {
  const MechanicService({super.key});

  @override
  State<MechanicService> createState() => _MechanicServicePageState();
}

class _MechanicServicePageState extends State<MechanicService> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryColor = const Color(0xFF0D47A1); // Navy Blue from homepage

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _partController = TextEditingController();

  bool _isSubmitting = false;
  String? _selectedServiceType;

  @override
  void initState() {
    super.initState();
    _prefillFromProfile();
  }

  Future<void> _prefillFromProfile() async {
    final data = await UserProfileService.getQuickFillData();
    if (!mounted) return;
    if (data['name']?.isNotEmpty == true && _nameController.text.isEmpty) {
      _nameController.text = data['name']!;
    }
    if (data['phone']?.isNotEmpty == true && _phoneController.text.isEmpty) {
      _phoneController.text = data['phone']!;
    }
    if (data['carModel']?.isNotEmpty == true && _carModelController.text.isEmpty) {
      _carModelController.text = data['carModel']!;
    }
  }

  final List<Map<String, dynamic>> _serviceTypes = [
    {
      'name': 'Engine Repair',
      'icon': Icons.engineering,
      'price': 500,
      'description': 'Complete repair services',
      'features': ['Engine Tuning', 'Parts Replacement', '24/7 Support'],
    },
    {
      'name': 'Brake Service',
      'icon': Icons.build_circle_outlined,
      'price': 350,
      'description': 'Brake system maintenance',
      'features': ['Brake Pads', 'Rotors', 'Fluid Check'],
    },
    {
      'name': 'Oil Change',
      'icon': Icons.oil_barrel,
      'price': 200,
      'description': 'Oil change and fluid services',
      'features': ['Synthetic Oil', 'Filter Change', 'Inspection'],
    },
    {
      'name': 'Battery Service',
      'icon': Icons.battery_charging_full,
      'price': 300,
      'description': 'Battery testing and replacement',
      'features': ['Testing', 'Charging', 'Replacement'],
    },
    {
      'name': 'AC Service',
      'icon': Icons.ac_unit,
      'price': 400,
      'description': 'Complete AC maintenance',
      'features': ['Cooling Check', 'Gas Refill', 'Performance Test'],
    },
    {
      'name': 'Wheel Service',
      'icon': Icons.tire_repair,
      'price': 150,
      'description': 'Wheel alignment and balancing',
      'features': ['Alignment', 'Balancing', 'Rotation'],
    },
  ];

  Future<void> _submitForm() async {
    if (_selectedServiceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please select a service type'), backgroundColor: _primaryColor),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          if (mounted) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.bottomSlide,
              title: 'Login Required',
              desc: 'Please login to submit a request.',
              btnOkColor: _primaryColor,
              btnOkOnPress: () {},
            ).show();
          }
          return;
        }

        await FirebaseFirestore.instance.collection('mechanic_requests').add({
          'name': user.displayName ?? _nameController.text,
          'phone': user.phoneNumber ?? _phoneController.text,
          'carModel': _carModelController.text,
          'location': _locationController.text,
          'serviceType': _selectedServiceType,
          'partToFix': _partController.text,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending',
          'userId': user.uid
        });

        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.rightSlide,
            title: 'Request Submitted',
            desc: 'Your mechanic request has been submitted successfully. Our team will contact you shortly.',
            btnOkColor: _primaryColor,
            btnOkOnPress: () {},
          ).show();

          _formKey.currentState!.reset();
          _clearControllers();
        }
      } catch (e) {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Submission Failed',
            desc: 'Something went wrong: $e',
            btnOkColor: _primaryColor,
            btnOkOnPress: () {},
          ).show();
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  void _clearControllers() {
    _nameController.clear();
    _phoneController.clear();
    _carModelController.clear();
    _locationController.clear();
    _partController.clear();
    setState(() {
      _selectedServiceType = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _carModelController.dispose();
    _locationController.dispose();
    _partController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expert Mechanic Service"),
        backgroundColor: _primaryColor,
        elevation: 2,
        foregroundColor: Colors.white,
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
                    "Professional Mechanic Services",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Expert mechanics at your service",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 20,
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
                    const Text(
                      "Select Service Type",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _serviceTypes.length,
                        itemBuilder: (context, index) {
                          final service = _serviceTypes[index];
                          final isSelected = _selectedServiceType == service['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedServiceType = service['name'];
                              });
                            },
                            child: Container(
                              width: 150,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? _primaryColor : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isSelected ? _primaryColor : Colors.grey.shade300,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    service['icon'],
                                    size: 28,
                                    color: isSelected ? Colors.white : _primaryColor,
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      service['name'],
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      service['description'],
                                      style: TextStyle(
                                        color: isSelected ? Colors.white70 : Colors.grey,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 3,
                                      runSpacing: 2,
                                      children: (service['features'] as List<String>).map((feature) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.white.withValues(alpha: 0.2) : _primaryColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            feature,
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : _primaryColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Personal Information",
                      style: TextStyle(
                        fontSize: 22,
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
                    const SizedBox(height: 12),
                    buildTextField(
                      Icons.directions_car_outlined,
                      "Car Model",
                      controller: _carModelController,
                    ),
                    const SizedBox(height: 12),
                    buildTextField(
                      Icons.location_on_outlined,
                      "Location",
                      controller: _locationController,
                      hint: "Your current location",
                    ),
                    const SizedBox(height: 12),
                    buildTextField(
                      Icons.build_outlined,
                      "Issue Description",
                      controller: _partController,
                      maxLines: 2,
                      hint: "Describe the issue you're experiencing",
                    ),
                    if (_selectedServiceType != null) ...[
                      const SizedBox(height: 8),
                      Builder(builder: (context) {
                        final service = _serviceTypes.firstWhere(
                          (s) => s['name'] == _selectedServiceType,
                          orElse: () => {'price': 0},
                        );
                        return Container(
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
                                _selectedServiceType!,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'EGP ${service['price']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
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
                                "REQUEST MECHANIC",
                                style: TextStyle(
                                  fontSize: 20,
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
    int maxLines = 1,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
}
