import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String ccode;
  final String status;
  final double walletBalance;
  final String membershipStatus;
  final Timestamp? membershipExpiry;
  final String? referralCode;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.ccode,
    this.status = 'active',
    this.walletBalance = 0.0,
    this.membershipStatus = 'none',
    this.membershipExpiry,
    this.referralCode,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      mobile: data['mobile'] ?? '',
      ccode: data['ccode'] ?? '',
      status: data['status'] ?? 'active',
      walletBalance: (data['wallet_balance'] ?? 0).toDouble(),
      membershipStatus: data['membership_status'] ?? 'none',
      membershipExpiry: data['membership_expiry'],
      referralCode: data['referral_code'],
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      mobile: data['mobile'] ?? '',
      ccode: data['ccode'] ?? '',
      status: data['status'] ?? 'active',
      walletBalance: (data['wallet_balance'] ?? 0).toDouble(),
      membershipStatus: data['membership_status'] ?? 'none',
      membershipExpiry: data['membership_expiry'],
      referralCode: data['referral_code'],
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'ccode': ccode,
      'status': status,
      'wallet_balance': walletBalance,
      'membership_status': membershipStatus,
      'membership_expiry': membershipExpiry,
      'referral_code': referralCode,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'ccode': ccode,
      'status': status,
      'wallet_balance': walletBalance,
      'membership_status': membershipStatus,
      'membership_expiry': membershipExpiry?.toDate().toIso8601String(),
      'referral_code': referralCode,
    };
  }
}

class Booking {
  final String id;
  final String userId;
  final String restaurantId;
  final String name;
  final String email;
  final String mobile;
  final String ccode;
  final String bookFor;
  final String bookTime;
  final String bookDate;
  final String numberOfPeople;
  final String status;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Timestamp? cancelledAt;

  Booking({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.name,
    required this.email,
    required this.mobile,
    required this.ccode,
    required this.bookFor,
    required this.bookTime,
    required this.bookDate,
    required this.numberOfPeople,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
    this.cancelledAt,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['user_id'] ?? '',
      restaurantId: data['restaurant_id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      mobile: data['mobile'] ?? '',
      ccode: data['ccode'] ?? '',
      bookFor: data['book_for'] ?? '',
      bookTime: data['book_time'] ?? '',
      bookDate: data['book_date'] ?? '',
      numberOfPeople: data['number_of_people'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
      cancelledAt: data['cancelled_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'restaurant_id': restaurantId,
      'name': name,
      'email': email,
      'mobile': mobile,
      'ccode': ccode,
      'book_for': bookFor,
      'book_time': bookTime,
      'book_date': bookDate,
      'number_of_people': numberOfPeople,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'cancelled_at': cancelledAt,
    };
  }
}

class WalletTransaction {
  final String id;
  final String userId;
  final double amount;
  final String type; // 'credit' or 'debit'
  final String description;
  final String? transactionId;
  final double balanceBefore;
  final double balanceAfter;
  final Timestamp? createdAt;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    this.transactionId,
    required this.balanceBefore,
    required this.balanceAfter,
    this.createdAt,
  });

  factory WalletTransaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WalletTransaction(
      id: doc.id,
      userId: data['user_id'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      transactionId: data['transaction_id'],
      balanceBefore: (data['balance_before'] ?? 0).toDouble(),
      balanceAfter: (data['balance_after'] ?? 0).toDouble(),
      createdAt: data['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'transaction_id': transactionId,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'created_at': createdAt,
    };
  }
}

class MembershipPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final List<String> features;
  final String status;
  final Timestamp? createdAt;

  MembershipPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.features,
    this.status = 'active',
    this.createdAt,
  });

  factory MembershipPlan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MembershipPlan(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      durationDays: data['duration_days'] ?? 30,
      features: List<String>.from(data['features'] ?? []),
      status: data['status'] ?? 'active',
      createdAt: data['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'duration_days': durationDays,
      'features': features,
      'status': status,
      'created_at': createdAt,
    };
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;
  final Timestamp? createdAt;
  final Timestamp? readAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type = 'general',
    this.data = const {},
    this.isRead = false,
    this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'general',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      isRead: data['is_read'] ?? false,
      createdAt: data['created_at'],
      readAt: data['read_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt,
      'read_at': readAt,
    };
  }
}
