import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiagnosticService extends StatefulWidget {
  const DiagnosticService({super.key});

  @override
  State<DiagnosticService> createState() => _DiagnosticServiceState();
}

class _DiagnosticServiceState extends State<DiagnosticService> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryColor = const Color(0xFF0D47A1); // Navy Blue from homepage
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();

  TimeOfDay? _startTime;
  DateTime? _selectedDate;

  String? _selectedCategory;
  final List<Map<String, dynamic>> _diagnosticCategories = [
    {
      'name': 'Check Engine Light',
      'icon': Icons.warning_amber_outlined,
      'description': 'Advanced diagnostics',
      'features': ['Error Code Reading', 'System Analysis', 'Quick Fix Options'],
    },
    {
      'name': 'Performance Issues',
      'icon': Icons.speed_outlined,
      'description': 'performance analysis',
      'features': ['Power Testing', 'Fuel Efficiency', 'Acceleration Check'],
    },
    {
      'name': 'Electrical System',
      'icon': Icons.electrical_services_outlined,
      'description': 'Full electrical diagnostics',
      'features': ['Battery Test', 'Circuit Check', 'Sensor Analysis'],
    },
    {
      'name': 'Transmission',
      'icon': Icons.settings_outlined,
      'description': 'Transmission system check',
      'features': ['Gear Analysis', 'Fluid Check', 'Clutch Testing'],
    },
    {
      'name': 'Fuel System',
      'icon': Icons.local_gas_station_outlined,
      'description': 'Fuel delivery analysis',
      'features': ['Injection Test', 'Pressure Check', 'Efficiency Analysis'],
    },
    {
      'name': 'Cooling System',
      'icon': Icons.ac_unit_outlined,
      'description': 'Temperature check',
      'features': ['Coolant Test', 'Radiator Check', 'Fan Analysis'],
    },
    {
      'name': 'Brake System',
      'icon': Icons.report_outlined,
      'description': 'Complete brake analysis',
      'features': ['Pad Inspection', 'Rotor Check', 'Fluid Analysis'],
    },
    {
      'name': 'Suspension',
      'icon': Icons.car_repair_outlined,
      'description': 'Ride comfort analysis',
      'features': ['Shock Test', 'Alignment Check', 'Balance Analysis'],
    },
  ];

  final List<Map<String, dynamic>> _warningSigns = [
    {
      'name': 'Warning Lights',
      'icon': Icons.warning_outlined,
    },
    {
      'name': 'Unusual Sounds',
      'icon': Icons.volume_up_outlined,
    },
    {
      'name': 'Vibrations',
      'icon': Icons.vibration_outlined,
    },
    {
      'name': 'Smoke Issues',
      'icon': Icons.cloud_outlined,
    },
    {
      'name': 'Fluid Leaks',
      'icon': Icons.opacity_outlined,
    },
    {
      'name': 'Starting Problems',
      'icon': Icons.power_settings_new_outlined,
    },
    {
      'name': 'Poor Fuel Economy',
      'icon': Icons.local_gas_station_outlined,
    },
  ];
  final List<String> _selectedWarningSigns = [];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null && _selectedDate != null) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          if (mounted) {
            _showErrorDialog(context, 'Please login to submit a request.');
          }
          return;
        }

        await FirebaseFirestore.instance.collection('diagnostic_requests').add({
          'name': user.displayName ?? _nameController.text,
          'phone': user.phoneNumber ?? _phoneController.text,
          'location': _locationController.text,
          'carModel': _carModelController.text,
          'category': _selectedCategory,
          'symptoms': _symptomsController.text,
          'warningSigns': _selectedWarningSigns,
          'appointmentDate': Timestamp.fromDate(_selectedDate!),
          'startTime': _startTime?.format(context),
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user.uid
        });

        if (mounted) {
          _showSuccessDialog(context, 'Your diagnostic service request has been submitted successfully. We will contact you shortly.');
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog(context, 'There was an error submitting your request: $e');
        }
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

  Future<void> _selectStartTime(BuildContext context) async {
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
        _startTime = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _carModelController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Diagnostics'),
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
                    "Professional Diagnostic Services",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Advanced vehicle diagnostics at your service",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
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
                      "Select Diagnostic Category",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
              ),
              const SizedBox(height: 8),
                    Container(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _diagnosticCategories.length,
                        itemBuilder: (context, index) {
                          final category = _diagnosticCategories[index];
                          final isSelected = _selectedCategory == category['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category['name'];
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
                                    category['icon'],
                                    size: 28,
                                    color: isSelected ? Colors.white : _primaryColor,
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      category['name'],
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
                                      category['description'],
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
                                      children: (category['features'] as List<String>).map((feature) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 1,
                                          ),
                decoration: BoxDecoration(
                                            color: isSelected ? Colors.white.withOpacity(0.2) : _primaryColor.withOpacity(0.1),
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

              const SizedBox(height: 16),
              const Text(
                      "Warning Signs",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
              ),
              const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _warningSigns.length,
                      itemBuilder: (context, index) {
                        final sign = _warningSigns[index];
                        final isSelected = _selectedWarningSigns.contains(sign['name']);
                        return GestureDetector(
                          onTap: () {
                      setState(() {
                              if (isSelected) {
                                _selectedWarningSigns.remove(sign['name']);
                        } else {
                                _selectedWarningSigns.add(sign['name']);
                        }
                      });
                    },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? _primaryColor.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? _primaryColor : Colors.grey.shade300,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  sign['icon'],
                                  color: isSelected ? _primaryColor : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  sign['name'],
                                  style: TextStyle(
                                    color: isSelected ? _primaryColor : Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Personal Information",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                      Icons.directions_car_outlined,
                      "Car Model",
                      controller: _carModelController,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      Icons.location_on_outlined,
                      "Location",
                      controller: _locationController,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      Icons.description_outlined,
                      "Symptoms Description",
                      controller: _symptomsController,
                      maxLines: 2,
                      hint: "Describe any unusual behavior or symptoms",
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
                    ElevatedButton.icon(
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
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                  Expanded(
                    child: ElevatedButton.icon(
                            onPressed: () => _selectStartTime(context),
                            icon: const Icon(Icons.access_time_outlined, color: Colors.white),
                            label: Text(
                              _startTime == null
                                  ? 'Start Time'
                                  : _startTime!.format(context),
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

                    const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                      height: 50,
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
                          "REQUEST DIAGNOSTIC",
                    style: TextStyle(
                            fontSize: 18,
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