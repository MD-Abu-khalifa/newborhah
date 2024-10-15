import 'package:active_ecommerce_flutter/presenter/home_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../helpers/shimmer_helper.dart';
import '../ui_elements/product_card.dart';

class HomeAllProducts extends StatelessWidget {
  final BuildContext? context;
  final HomePresenter? homeData;
  const HomeAllProducts({
    Key? key,
    this.context,
    this.homeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (homeData!.isAllProductInitial && homeData!.allProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: homeData!.allProductScrollController));
    } else if (homeData!.allProductList.length > 0) {
      //snapshot.hasData

      return GridView.builder(
        // 2
        //addAutomaticKeepAlives: true,
        itemCount: homeData!.allProductList.length,
        controller: homeData!.allProductScrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.618),
        padding: EdgeInsets.all(16.0),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ProductCard(
            id: homeData!.allProductList[index].id,
            slug: homeData!.allProductList[index].slug ?? "",  // إذا كانت null قم بتمرير قيمة فارغة
            image: homeData!.allProductList[index].thumbnail_image ?? "default_image.png", // تأكد من عدم وجود قيمة null في الصورة
            name: homeData!.allProductList[index].name ?? "No name available", // إذا كان الاسم null قم بتمرير رسالة بديلة
            main_price: homeData!.allProductList[index].main_price ?? "N/A", // تأكد من أن السعر غير null
            stroked_price: homeData!.allProductList[index].stroked_price ?? "",
            has_discount: homeData!.allProductList[index].has_discount ?? false,
            discount: homeData!.allProductList[index].discount ?? 0,
            is_wholesale: homeData!.allProductList[index].isWholesale ?? false,  // تعيين false إذا كانت null
          );
        },

      );
    } else if (homeData!.totalAllProductData == 0) {
      return Center(
          child: Text(AppLocalizations.of(context)!.no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }
}
