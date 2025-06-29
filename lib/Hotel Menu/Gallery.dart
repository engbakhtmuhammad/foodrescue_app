// ignore_for_file: file_names, must_be_immutable, prefer_const_constructors, use_key_in_widget_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:foodrescue_app/Getx_Controller/Gallery_controller.dart';
import 'package:foodrescue_app/Hotel%20Menu/Menu.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/String.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/Custom_widegt.dart';
import '../Utils/dark_light_mode.dart';

class Gallery extends StatefulWidget {
  String? galleryid;
  Gallery({this.galleryid, super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    getDarkMode();
    super.initState();
    // controller = TabController(length: 2, vsync: this);
    gallery.galleryview(id: widget.galleryid);
  }

  GalleryController gallery = Get.put(GalleryController());
  late ColorNotifier notifier;
  getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setIsDark");
    if (previousState == null) {
      notifier.setIsDark = false;
    } else {
      notifier.setIsDark = previousState;
    }
  }

  List<Widget> tab = [];
  int selectedIndex1 = 0;
  TabController? controller;
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      bottomNavigationBar: SizedBox(
        height: Get.height * 0.15,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 80, vertical: 35),
          child: InkWell(
            onTap: () {
              Get.to(() => Menu(viewmenuid: widget.galleryid));
            },
            child: Container(
              alignment: Alignment.center,
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: orangeColor,
              ),
              width: Get.width * 0.30,
              child: Text(
                provider.viewmenu.tr,
                style: TextStyle(
                    fontSize: 16, color: WhiteColor, fontFamily: "Gilroy Bold"),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: notifier.background,
      appBar: AppBar(
          leading: BackButton(color: notifier.textColor),
          backgroundColor: transparent,
          elevation: 0,
          title: Text(
            "Gallery".tr,
            style: TextStyle(
                fontFamily: "Gilroy Bold", fontSize: 18, color: notifier.textColor),
          )),
      body: GetBuilder<GalleryController>(builder: (context) {
        return gallery.isLoading
            ? Column(
                children: [
                  SizedBox(
                    height: Get.height * 0.05,
                    child: ListView.builder(
                      itemExtent: 150,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: gallery.galleryData.length,
                      // padding: const EdgeInsets.only(left: 30),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            gallery.changeindex(index);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              gallery.galleryData[index]['title'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Gilroy Bold",
                                  fontSize: 16,
                                  color: gallery.currentindex == index
                                      ? orangeColor
                                      : notifier.textColor),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: Get.height * 0.02),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: (1.6),
                    shrinkWrap: true,
                    children: List.generate(gallery.galleryData.isNotEmpty ? (gallery.galleryData[gallery.currentindex]['imglist'] as List).length : 0, (index) {
                      return InkWell(
                        onTap: () {
                          Get.to(PhotoViewPage(photos: List<String>.from(gallery.galleryData[gallery.currentindex]['imglist'] ?? []), index: index,),);
                        },
                        child: Container(
                          color: transparent,
                          child: FadeInImage.assetNetwork(
                            fadeInCurve: Curves.easeInCirc,
                            placeholder: "assets/ezgif.com-crop.gif",
                            height: 160,
                            width: 130,
                            placeholderCacheHeight: 160,
                            placeholderCacheWidth: 130,
                            placeholderFit: BoxFit.fill,
                            // placeholderScale: 1.0,
                            image: gallery.galleryData.isNotEmpty
                                ? (gallery.galleryData[gallery.currentindex]['imglist'] as List)[index]
                                : '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              )
            : Center(
                child: Padding(
                padding: EdgeInsets.only(top: Get.height * 0.4),
                child:  CircularProgressIndi(),
              ));
      }),
    );
  }
}

class PhotoViewPage extends StatefulWidget {
  final List<String> photos;
  final int index;

  const PhotoViewPage({
    super.key,
    required this.photos,
    required this.index,
  });

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  GalleryController gallery = Get.put(GalleryController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.photos.length,
        builder: (context, index) => PhotoViewGalleryPageOptions.customChild(
          child: CachedNetworkImage(
            height: Get.height,
            width: Get.width,
            filterQuality: FilterQuality.high,
            fit: BoxFit.contain,
            imageUrl: widget.photos[index],
            placeholder: (context, url) => Container(
              height: Get.height,
              width: Get.width,
              decoration: BoxDecoration(
                color: WhiteColor,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                "assets/ezgif.com-crop.gif",
                fit: BoxFit.cover,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.white,
              child: Center(child: Text(error.toString(),style: TextStyle(color: Colors.black),)),
            ),
          ),
          minScale: PhotoViewComputedScale.covered,
          heroAttributes: PhotoViewHeroAttributes(tag: widget.photos[index]),
        ),
        pageController: PageController(initialPage: widget.index),
        enableRotation: false,
      ),
    );
  }
}


class FullScreenImage extends StatelessWidget {
  String? imageUrl;
  String? tag;
  FullScreenImage({this.imageUrl, this.tag});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: tag ?? "",
            child: CachedNetworkImage(
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
              imageUrl: imageUrl ?? "",
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
