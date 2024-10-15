import 'package:active_ecommerce_flutter/presenter/home_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../helpers/shimmer_helper.dart';
import '../my_theme.dart';
import '../screens/category_list_n_product/category_products.dart';
import 'box_decorations.dart';

class FeaturedCategoriesWidget extends StatelessWidget {
  final HomePresenter homeData;
  const FeaturedCategoriesWidget({Key? key, required this.homeData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (homeData.isCategoryInitial &&
        homeData.featuredCategoryList.isEmpty) {
      return ShimmerHelper().buildHorizontalGridShimmerWithAxisCount(
          crossAxisSpacing: 14.0,
          mainAxisSpacing: 14.0,
          item_count: 10,
          mainAxisExtent: 170.0,
          controller: homeData.featuredCategoryScrollController);
    } else if (homeData.featuredCategoryList.isNotEmpty) {
      return GridView.builder(
        padding:
        const EdgeInsets.only(left: 18, right: 18, top: 13, bottom: 20),
        scrollDirection: Axis.horizontal,
        controller: homeData.featuredCategoryScrollController,
        itemCount: homeData.featuredCategoryList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 170.0),
        itemBuilder: (context, index) {
          // تحقق من البيانات قبل عرضها
          var category = homeData.featuredCategoryList[index];
          var imageUrl = category.banner ?? 'assets/default_image.png'; // صورة افتراضية إذا كان `banner` فارغًا
          var categoryName = category.name ?? 'No Name'; // نص افتراضي إذا كان الاسم فارغًا

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return CategoryProducts(
                      slug: category.slug, // تحقق من `slug` مسبقًا إذا كان فارغًا
                    );
                  },
                ),
              );
            },
            child: Container(
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(6), right: Radius.zero),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/placeholder.png',
                      image: imageUrl, // عرض الصورة بشكل صحيح
                      fit: BoxFit.cover,
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        categoryName, // عرض الاسم مع التحقق من كونه غير فارغ
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: MyTheme.font_grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (!homeData.isCategoryInitial &&
        homeData.featuredCategoryList.isEmpty) {
      return Container(
        height: 100,
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.no_category_found,
            style: const TextStyle(color: MyTheme.font_grey),
          ),
        ),
      );
    } else {
      // حالة افتراضية: لا يوجد شيء للعرض
      return Container(
        height: 100,
      );
    }
  }
}
