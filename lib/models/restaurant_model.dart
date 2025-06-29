import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String id;
  final String title;
  final String costTwo;
  final String sdesc;
  final String landmark;
  final String monthru;
  final String mdesc;
  final String frisun;
  final String address;
  final String latitude;
  final String longitude;
  final String popularDish;
  final String sundesc;
  final String rate;
  final String openTime;
  final String closeTime;
  final String mobile;
  final List<String> featurelist;
  final String restDistance;
  final List<String> img;
  final List<String> cuisines;
  final String status;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Restaurant({
    required this.id,
    required this.title,
    required this.costTwo,
    required this.sdesc,
    required this.landmark,
    required this.monthru,
    required this.mdesc,
    required this.frisun,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.popularDish,
    required this.sundesc,
    required this.rate,
    required this.openTime,
    required this.closeTime,
    required this.mobile,
    required this.featurelist,
    this.restDistance = '0',
    required this.img,
    required this.cuisines,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Restaurant(
      id: doc.id,
      title: data['title'] ?? '',
      costTwo: data['cost_two'] ?? '',
      sdesc: data['sdesc'] ?? '',
      landmark: data['landmark'] ?? '',
      monthru: data['monthru'] ?? '',
      mdesc: data['mdesc'] ?? '',
      frisun: data['frisun'] ?? '',
      address: data['address'] ?? '',
      latitude: data['latitude'] ?? '',
      longitude: data['longitude'] ?? '',
      popularDish: data['popular_dish'] ?? '',
      sundesc: data['sundesc'] ?? '',
      rate: data['rate'] ?? '0',
      openTime: data['open_time'] ?? '',
      closeTime: data['close_time'] ?? '',
      mobile: data['mobile'] ?? '',
      featurelist: List<String>.from(data['featurelist'] ?? []),
      restDistance: data['rest_distance'] ?? '0',
      img: List<String>.from(data['img'] ?? []),
      cuisines: List<String>.from(data['cuisines'] ?? []),
      status: data['status'] ?? 'active',
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
    );
  }

  factory Restaurant.fromMap(Map<String, dynamic> data, String id) {
    return Restaurant(
      id: id,
      title: data['title'] ?? '',
      costTwo: data['cost_two'] ?? '',
      sdesc: data['sdesc'] ?? '',
      landmark: data['landmark'] ?? '',
      monthru: data['monthru'] ?? '',
      mdesc: data['mdesc'] ?? '',
      frisun: data['frisun'] ?? '',
      address: data['address'] ?? '',
      latitude: data['latitude'] ?? '',
      longitude: data['longitude'] ?? '',
      popularDish: data['popular_dish'] ?? '',
      sundesc: data['sundesc'] ?? '',
      rate: data['rate'] ?? '0',
      openTime: data['open_time'] ?? '',
      closeTime: data['close_time'] ?? '',
      mobile: data['mobile'] ?? '',
      featurelist: List<String>.from(data['featurelist'] ?? []),
      restDistance: data['rest_distance'] ?? '0',
      img: List<String>.from(data['img'] ?? []),
      cuisines: List<String>.from(data['cuisines'] ?? []),
      status: data['status'] ?? 'active',
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'cost_two': costTwo,
      'sdesc': sdesc,
      'landmark': landmark,
      'monthru': monthru,
      'mdesc': mdesc,
      'frisun': frisun,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'popular_dish': popularDish,
      'sundesc': sundesc,
      'rate': rate,
      'open_time': openTime,
      'close_time': closeTime,
      'mobile': mobile,
      'featurelist': featurelist,
      'rest_distance': restDistance,
      'img': img,
      'cuisines': cuisines,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cost_two': costTwo,
      'sdesc': sdesc,
      'landmark': landmark,
      'monthru': monthru,
      'mdesc': mdesc,
      'frisun': frisun,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'popular_dish': popularDish,
      'sundesc': sundesc,
      'rate': rate,
      'open_time': openTime,
      'close_time': closeTime,
      'mobile': mobile,
      'featurelist': featurelist,
      'rest_distance': restDistance,
      'img': img,
      'cuisines': cuisines,
      'status': status,
    };
  }
}

class Banner {
  final String id;
  final String title;
  final String image;
  final String link;
  final int order;
  final String status;
  final Timestamp? createdAt;

  Banner({
    required this.id,
    required this.title,
    required this.image,
    this.link = '',
    this.order = 0,
    this.status = 'active',
    this.createdAt,
  });

  factory Banner.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Banner(
      id: doc.id,
      title: data['title'] ?? '',
      image: data['image'] ?? '',
      link: data['link'] ?? '',
      order: data['order'] ?? 0,
      status: data['status'] ?? 'active',
      createdAt: data['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'image': image,
      'link': link,
      'order': order,
      'status': status,
      'created_at': createdAt,
    };
  }
}

class Cuisine {
  final String id;
  final String name;
  final String image;
  final String description;
  final String status;
  final Timestamp? createdAt;

  Cuisine({
    required this.id,
    required this.name,
    required this.image,
    this.description = '',
    this.status = 'active',
    this.createdAt,
  });

  factory Cuisine.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Cuisine(
      id: doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'active',
      createdAt: data['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'description': description,
      'status': status,
      'created_at': createdAt,
    };
  }
}

class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String category;
  final double price;
  final String image;
  final bool isVeg;
  final bool isAvailable;
  final int preparationTime;
  final String status;
  final Timestamp? createdAt;

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.image = '',
    this.isVeg = true,
    this.isAvailable = true,
    this.preparationTime = 15,
    this.status = 'active',
    this.createdAt,
  });

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MenuItem(
      id: doc.id,
      restaurantId: data['restaurant_id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      isVeg: data['is_veg'] ?? true,
      isAvailable: data['is_available'] ?? true,
      preparationTime: data['preparation_time'] ?? 15,
      status: data['status'] ?? 'active',
      createdAt: data['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'image': image,
      'is_veg': isVeg,
      'is_available': isAvailable,
      'preparation_time': preparationTime,
      'status': status,
      'created_at': createdAt,
    };
  }
}
