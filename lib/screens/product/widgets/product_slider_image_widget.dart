import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../helpers/shimmer_helper.dart';
import '../../../my_theme.dart';

class ProductSliderImageWidget extends StatefulWidget {
  final List? productImageList;
  final CarouselSliderController? carouselController;
  int? currentImage;
  ProductSliderImageWidget({
    Key? key,
    this.productImageList,
    this.carouselController,
    this.currentImage,
  }) : super(key: key);

  @override
  State<ProductSliderImageWidget> createState() =>
      _ProductSliderImageWidgetState();
}

class _ProductSliderImageWidgetState extends State<ProductSliderImageWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.productImageList!.length == 0) {
      return ShimmerHelper().buildBasicShimmer(
        height: 190.0,
      );
    } else {
      return CarouselSlider(
        carouselController: widget.carouselController,
        options: CarouselOptions(
            aspectRatio: 355 / 375,
            viewportFraction: 1,
            initialPage: 0,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 5),
            autoPlayAnimationDuration: Duration(milliseconds: 1000),
            autoPlayCurve: Curves.easeInExpo,
            enlargeCenterPage: false,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              print(index);
              setState(() {
                widget.currentImage = index;
              });
            }),
        items: widget.productImageList!.map(
          (i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  child: Stack(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          openPhotoDialog(context,
                              widget.productImageList![widget.currentImage!]);
                        },
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder_rectangle.png',
                            image: i,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.productImageList!.length,
                            (index) => Container(
                              width: 7.0,
                              height: 7.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.currentImage == index
                                    ? MyTheme.font_grey
                                    : Colors.grey.withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ).toList(),
      );
    }
  }

  openPhotoDialog(BuildContext context, path) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
                child: Stack(
              children: [
                PhotoView(
                  enableRotation: true,
                  heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
                  imageProvider: NetworkImage(path),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: ShapeDecoration(
                      color: MyTheme.medium_grey_50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                          topRight: Radius.circular(25),
                          topLeft: Radius.circular(25),
                        ),
                      ),
                    ),
                    width: 40,
                    height: 40,
                    child: IconButton(
                      icon: Icon(Icons.clear, color: MyTheme.white),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                  ),
                ),
              ],
            )),
          );
        },
      );
}
