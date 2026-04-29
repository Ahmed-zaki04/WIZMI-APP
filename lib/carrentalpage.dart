import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CarRentalPage extends StatefulWidget {
  const CarRentalPage({super.key});

  @override
  State<CarRentalPage> createState() => _CarRentalPageState();
}

class _CarRentalPageState extends State<CarRentalPage> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryColor = const Color(0xFF0D47A1); // Navy Blue from homepage

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _pickupLocationController = TextEditingController();
  final TextEditingController _dropoffLocationController = TextEditingController();

  String? _selectedCarType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _withDriver = false;
  bool _withInsurance = true;

  final List<Map<String, dynamic>> _carTypes = [
    {
      'name': 'Economy',
      'price': 50,
      'description': 'Efficient and a reliable car',
      'features': ['Fuel Efficient', '4 Seats', 'Bluetooth', 'USB Charging', 'Smart Display', 'Cruise Control'],
      'amenities': ['GPS Navigation', 'Backup Camera', 'Smart Key'],
    },
    {
      'name': 'Premium Sedan',
      'price': 75,
      'description': 'Comfortable mid-size luxury sedan',
      'features': ['Leather Seats', '5 Seats', 'Premium Audio', 'Wireless Charging', 'Climate Control'],
      'amenities': ['360° Camera', 'Lane Assist', 'Parking Sensors'],
    },
    {
      'name': 'Luxury SUV',
      'price': 120,
      'description': 'Premium SUV with advanced features',
      'features': ['7 Seats', 'Panoramic Roof', 'Premium Sound', '4x4 Available', 'Adaptive Cruise'],
      'amenities': ['Night Vision', 'Massage Seats', 'Head-up Display'],
    },
    {
      'name': 'Executive',
      'price': 200,
      'description': 'Ultra-luxury executive vehicle',
      'features': ['Premium Interior', 'Rear Entertainment', 'Executive Seats', 'Mini Bar', 'WiFi'],
      'amenities': ['Chauffeur Option', 'VIP Access', 'Concierge Service'],
    },
    {
      'name': 'Sports Car',
      'price': 250,
      'description': 'High-performance sports vehicle',
      'features': ['High Performance', '2 Seats', 'Sport Mode', 'Carbon Fiber', 'Launch Control'],
      'amenities': ['Track GPS', 'Performance Data', 'Race Seats'],
    },
    {
      'name': 'Electric',
      'price': 100,
      'description': 'Eco-friendly electric vehicle',
      'features': ['Zero Emissions', 'Long Range', 'Fast Charging', 'Auto Pilot', 'Silent Drive'],
      'amenities': ['Charging Network', 'Smart App', 'Battery Monitor'],
    },
  ];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCarType != null && _startDate != null && _endDate != null) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          if (mounted) {
            _showErrorDialog(context, 'Please login to submit a request.');
          }
          return;
        }

        await FirebaseFirestore.instance.collection('car_rental_requests').add({
          'name': user.displayName ?? _nameController.text,
          'phone': user.phoneNumber ?? _phoneController.text,
          'license': _licenseController.text,
          'pickupLocation': _pickupLocationController.text,
          'dropoffLocation': _dropoffLocationController.text,
          'carType': _selectedCarType,
          'startDate': Timestamp.fromDate(_startDate!),
          'endDate': Timestamp.fromDate(_endDate!),
          'withDriver': _withDriver,
          'withInsurance': _withInsurance,
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user.uid
        });

        if (mounted) {
          _showSuccessDialog(context, 'Your car rental request has been submitted. We will confirm shortly.');
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog(context, 'There was an error submitting your request: $e');
        }
      }
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a start date first'),
          backgroundColor: _primaryColor,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!.add(const Duration(days: 1)),
      lastDate: _startDate!.add(const Duration(days: 30)),
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
        _endDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _pickupLocationController.dispose();
    _dropoffLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elite Car Rentals'),
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
                    "Premium Fleet Selection",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choose from our luxury vehicle collection",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
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
                      "Select Car Type",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _carTypes.length,
                        itemBuilder: (context, index) {
                          final carType = _carTypes[index];
                          final isSelected = _selectedCarType == carType['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCarType = carType['name'];
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
                                    color: Colors.grey.withOpacity(0.1),
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
                                    Icons.directions_car,
                                    size: 32,
                                    color: isSelected ? Colors.white : _primaryColor,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    carType['name'],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
                                      color: isSelected ? Colors.white.withOpacity(0.2) : _primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '\$${carType['price']}/day',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : _primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    carType['description'],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white70 : Colors.grey,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                      "Rental Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectStartDate(context),
                            icon: const Icon(Icons.calendar_today_outlined, size: 20),
                            label: Text(
                              _startDate == null
                                  ? 'Start Date'
                                  : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                              style: TextStyle(fontSize: 14,color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectEndDate(context),
                            icon: const Icon(Icons.calendar_today_outlined, size: 20),
                            label: Text(
                              _endDate == null
                                  ? 'End Date'
                                  : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                              style: TextStyle(fontSize: 14,color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Personal Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                      Icons.person_outline,
                      "Full Name",
                      controller: _nameController,
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                      Icons.phone_outlined,
                      "Phone Number",
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                      Icons.credit_card_outlined,
                      "Driver's License",
                      controller: _licenseController,
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Location Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                      Icons.location_on_outlined,
                      "Pickup Location",
                      controller: _pickupLocationController,
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                      Icons.location_off_outlined,
                      "Drop-off Location",
                      controller: _dropoffLocationController,
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Additional Services",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: _withDriver ? _primaryColor.withOpacity(0.1) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _withDriver ? _primaryColor : Colors.grey.shade300,
                        ),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          "Professional Driver",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: const Text(
                          "Experienced chauffeur service",
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _withDriver,
                        activeColor: _primaryColor,
                        onChanged: (bool value) {
                          setState(() {
                            _withDriver = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: _withInsurance ? _primaryColor.withOpacity(0.1) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _withInsurance ? _primaryColor : Colors.grey.shade300,
                        ),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          "Premium Insurance",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: const Text(
                          "Comprehensive coverage package",
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _withInsurance,
                        activeColor: _primaryColor,
                        onChanged: (bool value) {
                          setState(() {
                            _withInsurance = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "BOOK NOW",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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