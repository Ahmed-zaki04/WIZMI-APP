import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CarWashingPage extends StatefulWidget {
  const CarWashingPage({super.key});

  @override
  State<CarWashingPage> createState() => _CarWashingPageState();
}

class _CarWashingPageState extends State<CarWashingPage> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryColor = const Color(0xFF0D47A1); // Navy Blue from homepage

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();

  String? _selectedPackage;
  final List<String> _selectedAddOns = [];
  bool _isSubmitting = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<Map<String, dynamic>> _packages = [
    {
      'name': 'Express Clean',
      'price': 25,
      'description': 'Quick but thorough cleaning service',
      'icon': Icons.wash_outlined,
      'features': ['Exterior Wash', 'Tire Shine', 'Interior Vacuum', 'Windows Cleaning'],
      'duration': '30 mins',
    },
    {
      'name': 'Premium Detail',
      'price': 55,
      'description': 'Comprehensive cleaning and protection',
      'icon': Icons.auto_awesome_outlined,
      'features': ['Express Clean +', 'Interior Detailing', 'Wax Protection', 'Leather Care', 'Air Freshener'],
      'duration': '1.5 hours',
    },
    {
      'name': 'Ultimate Luxury',
      'price': 95,
      'description': 'Complete luxury car care experience',
      'icon': Icons.stars_outlined,
      'features': ['Premium Detail +', 'Ceramic Coating', 'Paint Correction', 'Premium Wax', 'Fabric Protection'],
      'duration': '3 hours',
    },
    {
      'name': 'Executive VIP',
      'price': 150,
      'description': 'Exclusive detailing with premium products',
      'icon': Icons.diamond_outlined,
      'features': ['Ultimate Luxury +', 'Nano Ceramic Seal', 'Glass Treatment', 'Engine Bay Detail', 'Ozone Treatment'],
      'duration': '4+ hours',
    },
  ];

  final List<Map<String, dynamic>> _addOns = [
    {
      'name': 'Paint Protection',
      'price': 40,
      'icon': Icons.format_paint_outlined,
      'description': 'Long-lasting paint sealant',
    },
    {
      'name': 'Interior Sanitization',
      'price': 25,
      'icon': Icons.cleaning_services_outlined,
      'description': 'Deep clean and sanitize',
    },
    {
      'name': 'Leather Treatment',
      'price': 35,
      'icon': Icons.airline_seat_recline_extra_outlined,
      'description': 'Premium leather care',
    },
    {
      'name': 'Wheel Restoration',
      'price': 45,
      'icon': Icons.tire_repair_outlined,
      'description': 'Deep clean and protect wheels',
    },
    {
      'name': 'Headlight Restoration',
      'price': 50,
      'icon': Icons.light_mode_outlined,
      'description': 'Restore clarity and shine',
    },
    {
      'name': 'Pet Hair Removal',
      'price': 30,
      'icon': Icons.pets_outlined,
      'description': 'Thorough pet hair cleanup',
    },
  ];

  Future<void> _submitForm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorDialog(context, 'Please login first.');
      return;
    }
    if (_formKey.currentState!.validate() && _selectedPackage != null && _selectedDate != null && _selectedTime != null) {
      setState(() => _isSubmitting = true);
      try {
        await FirebaseFirestore.instance.collection('car_wash_requests').add({
          'userId': user.uid,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
          'carModel': _carModelController.text,
          'package': _selectedPackage,
          'addOns': _selectedAddOns,
          'appointmentDate': Timestamp.fromDate(_selectedDate!),
          'appointmentTime': '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          _showSuccessDialog(context, 'Your car wash appointment has been scheduled. We will confirm shortly.');
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog(context, 'There was an error scheduling your appointment: $e');
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _carModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luxury Car Wash'),
        backgroundColor: _primaryColor,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
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
                    "Premium Car Care Services",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Professional detailing for your vehicle",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Package",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _packages.length,
                        itemBuilder: (context, index) {
                          final package = _packages[index];
                          final isSelected = _selectedPackage == package['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPackage = package['name'];
                              });
                            },
                            child: Container(
                              width: 130,
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
                                    package['icon'],
                                    size: 32,
                                    color: isSelected ? Colors.white : _primaryColor,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    package['name'],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white.withValues(alpha: 0.2) : _primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'EGP ${package['price']}',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : _primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    package['duration'],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white70 : Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 15),
                    const Text(
                      "Add-on Services",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _addOns.length,
                      itemBuilder: (context, index) {
                        final addOn = _addOns[index];
                        final isSelected = _selectedAddOns.contains(addOn['name']);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedAddOns.remove(addOn['name']);
                              } else {
                                _selectedAddOns.add(addOn['name']);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? _primaryColor.withValues(alpha: 0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? _primaryColor : Colors.grey.shade300,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? _primaryColor.withValues(alpha: 0.1) : Colors.grey.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    addOn['icon'],
                                    color: isSelected ? _primaryColor : Colors.grey,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  addOn['name'],
                                  style: TextStyle(
                                    color: isSelected ? _primaryColor : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.blue.shade900.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.blue.shade900,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'EGP ${addOn['price']}',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.blue.shade900,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    addOn['description'],
                                    style: TextStyle(
                                      color: isSelected ? _primaryColor.withValues(alpha: 0.8) : Colors.grey,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Personal Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      Icons.person_outline,
                      "Full Name",
                      controller: _nameController,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      Icons.phone_outlined,
                      "Phone Number",
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      Icons.location_on_outlined,
                      "Location",
                      controller: _locationController,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      Icons.directions_car_outlined,
                      "Car Model",
                      controller: _carModelController,
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Schedule Appointment",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_today_outlined, color: Colors.white),
                            label: Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectTime(context),
                            icon: const Icon(Icons.access_time_outlined, color: Colors.white),
                            label: Text(
                              _selectedTime == null
                                  ? 'Select Time'
                                  : _selectedTime!.format(context),
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    _buildCostSummary(),
                    const SizedBox(height: 12),
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
                                "BOOK APPOINTMENT",
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

  int get _packagePrice {
    if (_selectedPackage == null) return 0;
    final pkg = _packages.firstWhere(
      (p) => p['name'] == _selectedPackage,
      orElse: () => {'price': 0},
    );
    return pkg['price'] as int;
  }

  int get _addOnsTotal {
    int total = 0;
    for (final name in _selectedAddOns) {
      final addOn = _addOns.firstWhere(
        (a) => a['name'] == name,
        orElse: () => {'price': 0},
      );
      total += addOn['price'] as int;
    }
    return total;
  }

  Widget _buildCostSummary() {
    if (_selectedPackage == null) return const SizedBox.shrink();
    final int pkgPrice = _packagePrice;
    final int addOns = _addOnsTotal;
    final int total = pkgPrice + addOns;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cost Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_selectedPackage', style: const TextStyle(fontSize: 13)),
              Text('EGP $pkgPrice', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          if (_selectedAddOns.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add-ons (${_selectedAddOns.length})',
                    style: const TextStyle(fontSize: 13)),
                Text('EGP $addOns',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('EGP $total',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _primaryColor)),
            ],
          ),
        ],
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