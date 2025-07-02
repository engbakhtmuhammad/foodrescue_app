import 'package:cloud_firestore/cloud_firestore.dart';

class SurpriseBagOrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String surpriseBagId;
  final String surpriseBagTitle;
  final String restaurantId;
  final String restaurantName;
  final double originalPrice;
  final double discountedPrice;
  final double totalAmount;
  final int quantity;
  final String status; // 'pending', 'confirmed', 'ready', 'completed', 'cancelled'
  final String paymentStatus; // 'pending', 'paid', 'refunded'
  final String paymentMethod;
  final String? paymentId;
  final DateTime pickupDate;
  final String pickupTimeSlot;
  final String pickupInstructions;
  final String? customerNotes;
  final String? restaurantNotes;
  final DateTime orderDate;
  final DateTime? confirmedAt;
  final DateTime? readyAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  SurpriseBagOrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.surpriseBagId,
    required this.surpriseBagTitle,
    required this.restaurantId,
    required this.restaurantName,
    required this.originalPrice,
    required this.discountedPrice,
    required this.totalAmount,
    this.quantity = 1,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.paymentMethod = '',
    this.paymentId,
    required this.pickupDate,
    this.pickupTimeSlot = '',
    this.pickupInstructions = '',
    this.customerNotes,
    this.restaurantNotes,
    required this.orderDate,
    this.confirmedAt,
    this.readyAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  // Create from Firestore document
  factory SurpriseBagOrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return SurpriseBagOrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userPhone: data['userPhone'] ?? '',
      surpriseBagId: data['surpriseBagId'] ?? '',
      surpriseBagTitle: data['surpriseBagTitle'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      originalPrice: (data['originalPrice'] ?? 0.0).toDouble(),
      discountedPrice: (data['discountedPrice'] ?? 0.0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      status: data['status'] ?? 'pending',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? '',
      paymentId: data['paymentId'],
      pickupDate: _parseDateTime(data['pickupDate']) ?? DateTime.now(),
      pickupTimeSlot: data['pickupTimeSlot'] ?? '',
      pickupInstructions: data['pickupInstructions'] ?? '',
      customerNotes: data['customerNotes'],
      restaurantNotes: data['restaurantNotes'],
      orderDate: _parseDateTime(data['orderDate']) ?? DateTime.now(),
      confirmedAt: _parseDateTime(data['confirmedAt']),
      readyAt: _parseDateTime(data['readyAt']),
      completedAt: _parseDateTime(data['completedAt']),
      cancelledAt: _parseDateTime(data['cancelledAt']),
      cancellationReason: data['cancellationReason'],
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(data['updatedAt']) ?? DateTime.now(),
      additionalData: data['additionalData'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'surpriseBagId': surpriseBagId,
      'surpriseBagTitle': surpriseBagTitle,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'totalAmount': totalAmount,
      'quantity': quantity,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'pickupDate': Timestamp.fromDate(pickupDate),
      'pickupTimeSlot': pickupTimeSlot,
      'pickupInstructions': pickupInstructions,
      'customerNotes': customerNotes,
      'restaurantNotes': restaurantNotes,
      'orderDate': Timestamp.fromDate(orderDate),
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'readyAt': readyAt != null ? Timestamp.fromDate(readyAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancellationReason': cancellationReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalData': additionalData,
    };
  }

  // Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value);
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    
    return null;
  }

  // Copy with method for updates
  SurpriseBagOrderModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? surpriseBagId,
    String? surpriseBagTitle,
    String? restaurantId,
    String? restaurantName,
    double? originalPrice,
    double? discountedPrice,
    double? totalAmount,
    int? quantity,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? paymentId,
    DateTime? pickupDate,
    String? pickupTimeSlot,
    String? pickupInstructions,
    String? customerNotes,
    String? restaurantNotes,
    DateTime? orderDate,
    DateTime? confirmedAt,
    DateTime? readyAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return SurpriseBagOrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      surpriseBagId: surpriseBagId ?? this.surpriseBagId,
      surpriseBagTitle: surpriseBagTitle ?? this.surpriseBagTitle,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTimeSlot: pickupTimeSlot ?? this.pickupTimeSlot,
      pickupInstructions: pickupInstructions ?? this.pickupInstructions,
      customerNotes: customerNotes ?? this.customerNotes,
      restaurantNotes: restaurantNotes ?? this.restaurantNotes,
      orderDate: orderDate ?? this.orderDate,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      readyAt: readyAt ?? this.readyAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Convenience getters
  bool get isPaid => paymentStatus == 'paid';
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isReady => status == 'ready';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return isPaid ? 'Awaiting Confirmation' : 'Payment Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'ready':
        return 'Ready for Pickup';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }
}
