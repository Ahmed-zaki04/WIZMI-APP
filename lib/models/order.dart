import 'package:cloud_firestore/cloud_firestore.dart';

class WizmiOrder {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String fuelType;
  final int quantity;
  final double pricePerLiter;
  final double totalPrice;
  final String address;
  final double lat;
  final double lng;
  final String paymentMethod;
  final String status;
  final String driverName;
  final String driverPhone;
  final DateTime createdAt;

  WizmiOrder({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.fuelType,
    required this.quantity,
    required this.pricePerLiter,
    required this.totalPrice,
    required this.address,
    required this.lat,
    required this.lng,
    required this.paymentMethod,
    required this.status,
    this.driverName = '',
    this.driverPhone = '',
    required this.createdAt,
  });

  factory WizmiOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WizmiOrder(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      fuelType: data['fuelType'] ?? '',
      quantity: (data['quantity'] ?? 0).toInt(),
      pricePerLiter: (data['pricePerLiter'] ?? 0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      address: data['address'] ?? '',
      lat: (data['lat'] ?? 0).toDouble(),
      lng: (data['lng'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      status: data['status'] ?? 'Confirmed',
      driverName: data['driverName'] ?? '',
      driverPhone: data['driverPhone'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'fuelType': fuelType,
      'quantity': quantity,
      'pricePerLiter': pricePerLiter,
      'totalPrice': totalPrice,
      'address': address,
      'lat': lat,
      'lng': lng,
      'paymentMethod': paymentMethod,
      'status': status,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static const List<String> statuses = [
    'Confirmed',
    'Assigned',
    'En Route',
    'Delivered',
    'Cancelled',
  ];
}
