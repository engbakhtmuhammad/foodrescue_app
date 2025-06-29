// ignore_for_file: file_names
// // ignore_for_file: prefer_const_constructors, unnecessary_import, file_names

// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:foodrescue_app/Utils/Colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   String latitude = "";
//   String longitude = "";
//   late GoogleMapController
//       mapController; //contrller for Google map //markers for google map
//   LatLng showLocation = LatLng(21.2423, 72.878132);
//   List<Marker> markar = [];

//   Future<Uint8List> getImages(String path, int width) async {
//     ByteData data = await rootBundle.load(path);
//     ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
//         targetHeight: width);
//     ui.FrameInfo fi = await codec.getNextFrame();
//     return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
//         .buffer
//         .asUint8List();
//   }

//   loadData() async {
//     final Uint8List markIcons = await getImages("assets/mapmarker.png", 100);
//     // makers added according to index
//     markar.add(
//       Marker(
//         // given marker id
//         markerId: MarkerId(showLocation.toString()),
//         // given marker icon
//         icon: BitmapDescriptor.fromBytes(markIcons),
//         // given position
//         position: LatLng(21.2423, 72.878132),
//         infoWindow: InfoWindow(),
//       ),
//     );
//     setState(() {});
//   }

//   @override
//   void initState() {
//     loadData();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: BlackColor,
//       body: Container(
//         height: Get.height,
//         width: double.infinity,
//         child: GoogleMap(
//           initialCameraPosition: const CameraPosition(
//             target: LatLng(21.2423, 72.878132), //initial position
//             zoom: 15.0, //initial zoom level
//           ),
//           markers: Set<Marker>.of(markar),
//           mapType: MapType.normal,
//           myLocationEnabled: true,
//           compassEnabled: true,
//           zoomGesturesEnabled: true,
//           tiltGesturesEnabled: true,
//           zoomControlsEnabled: true,
//           onMapCreated: (controller) {
//             //method called when map is created
//             setState(() {
//               mapController = controller;
//             });
//           },
//         ),
//       ),
//     );
//   }
// }
