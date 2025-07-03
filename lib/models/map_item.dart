import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapItem with ClusterItem {
  final String id;
  final String title;
  final String subtitle;
  final LatLng position;
  final String type; // 'restaurant' or 'bag'
  final String? logoUrl;
  final String? imageUrl;
  final double? rating;
  final String? price;
  final Map<String, dynamic>? data;

  MapItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.position,
    required this.type,
    this.logoUrl,
    this.imageUrl,
    this.rating,
    this.price,
    this.data,
  });

  @override
  LatLng get location => position;

  @override
  String get geohash => '${location.latitude}_${location.longitude}';
}
