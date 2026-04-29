import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart';
import '../models/fuel_type.dart';

class OrderProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FuelType? selectedFuel;
  int quantity = 20;
  String address = '';
  double lat = 30.0444;
  double lng = 31.2357;
  String paymentMethod = 'Cash';

  bool _placing = false;
  bool get placing => _placing;

  double get totalPrice => selectedFuel != null
      ? selectedFuel!.pricePerLiter * quantity
      : 0.0;

  void selectFuel(FuelType fuel) {
    selectedFuel = fuel;
    notifyListeners();
  }

  void setQuantity(int val) {
    quantity = val.clamp(5, 100);
    notifyListeners();
  }

  void setAddress(String a, double lt, double ln) {
    address = a;
    lat = lt;
    lng = ln;
    notifyListeners();
  }

  void setPayment(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  void reset() {
    selectedFuel = null;
    quantity = 20;
    address = '';
    paymentMethod = 'Cash';
    notifyListeners();
  }

  Future<String?> placeOrder(String userName, String userPhone) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Not logged in.';
    if (selectedFuel == null) return 'Please select a fuel type.';
    if (address.isEmpty) return 'Please enter your address.';

    try {
      _placing = true;
      notifyListeners();

      final order = WizmiOrder(
        id: '',
        userId: user.uid,
        userName: userName,
        userPhone: userPhone,
        fuelType: selectedFuel!.name,
        quantity: quantity,
        pricePerLiter: selectedFuel!.pricePerLiter,
        totalPrice: totalPrice,
        address: address,
        lat: lat,
        lng: lng,
        paymentMethod: paymentMethod,
        status: 'Confirmed',
        createdAt: DateTime.now(),
      );

      await _db.collection('orders').add(order.toMap());

      _placing = false;
      notifyListeners();
      return null;
    } catch (e) {
      _placing = false;
      notifyListeners();
      return 'Failed to place order. Please try again.';
    }
  }

  Stream<List<WizmiOrder>> userOrders() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(WizmiOrder.fromFirestore).toList());
  }

  Stream<List<WizmiOrder>> allOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(WizmiOrder.fromFirestore).toList());
  }

  Future<void> updateOrderStatus(String orderId, String status,
      {String driverName = '', String driverPhone = ''}) async {
    final data = <String, dynamic>{'status': status};
    if (driverName.isNotEmpty) data['driverName'] = driverName;
    if (driverPhone.isNotEmpty) data['driverPhone'] = driverPhone;
    await _db.collection('orders').doc(orderId).update(data);
  }
}
