import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wizmi/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController       = TextEditingController();
  final _phoneController      = TextEditingController();
  final _addressController    = TextEditingController();
  final _carBrandController   = TextEditingController();
  final _carModelController   = TextEditingController();
  final _plateController      = TextEditingController();

  bool _isLoading = true;
  bool _docExists = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _carBrandController.dispose();
    _carModelController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text       = data['name']        ?? data['firstName'] ?? '';
        _phoneController.text      = data['phone']       ?? '';
        _addressController.text    = data['address']     ?? '';
        _carBrandController.text   = data['carBrand']    ?? '';
        _carModelController.text   = data['carModel']    ?? '';
        _plateController.text      = data['plateNumber'] ?? '';
        setState(() {
          _photoUrl  = data['photoUrl'] as String?;
          _isLoading = false;
          _docExists = true;
        });
      } else {
        _nameController.text = user.displayName ?? '';
        setState(() { _isLoading = false; _docExists = false; });
      }
    } catch (_) {
      if (!mounted) return;
      _nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
      setState(() { _isLoading = false; _docExists = false; });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name':        _nameController.text.trim(),
        'phone':       _phoneController.text.trim(),
        'address':     _addressController.text.trim(),
        'carBrand':    _carBrandController.text.trim(),
        'carModel':    _carModelController.text.trim(),
        'plateNumber': _plateController.text.trim(),
        'email':       user.email ?? '',
        'updatedAt':   FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() => _docExists = true);
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Saved',
        desc: 'Profile updated successfully!',
        btnOkOnPress: () {},
        btnOkColor: AppTheme.primary,
      ).show();
    } catch (_) {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: 'Could not save profile. Check your connection.',
        btnOkOnPress: () {},
        btnOkColor: Colors.red,
      ).show();
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final ref = FirebaseStorage.instance.ref('user_photos/${user.uid}.jpg');
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'photoUrl': url}, SetOptions(merge: true));
      setState(() => _photoUrl = url);
    } catch (e) {
      debugPrint('Photo upload error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, 'log');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _signOut,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatarHeader(),
                    const SizedBox(height: 28),
                    if (!_docExists) _buildInfoBanner(),
                    // ── Personal Info ─────────────────────────────────────
                    _buildField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Enter your phone' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.location_on_outlined,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Enter your address' : null,
                    ),
                    const SizedBox(height: 28),
                    // ── My Car ────────────────────────────────────────────
                    Text('My Car',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildField(
                              controller: _carBrandController,
                              label: 'Car Brand',
                              icon: Icons.directions_car_outlined,
                              validator: null, // optional
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _carModelController,
                              label: 'Car Model',
                              icon: Icons.car_repair_outlined,
                              validator: null,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _plateController,
                              label: 'Plate Number',
                              icon: Icons.numbers_outlined,
                              validator: null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // ── Buttons ───────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('SAVE PROFILE'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, 'my_bookings'),
                        child: const Text('My Bookings →'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'LOGOUT',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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

  Widget _buildAvatarHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final initial = _nameController.text.isNotEmpty
        ? _nameController.text[0].toUpperCase()
        : '?';

    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppTheme.primary,
              child: _photoUrl != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: _photoUrl!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                        errorWidget: (_, __, ___) => Text(
                          initial,
                          style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : Text(
                      initial,
                      style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickAndUploadPhoto,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nameController.text.isNotEmpty
                    ? _nameController.text
                    : 'New User',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(email,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Complete your profile to use all services.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary),
      ),
    );
  }
}
