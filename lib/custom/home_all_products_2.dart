import 'package:active_ecommerce_flutter/presenter/home_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../helpers/shimmer_helper.dart';
import '../ui_elements/product_card.dart';

class HomeAllProducts2 extends StatelessWidget {
  final HomePresenter? homeData;

  const HomeAllProducts2({
    Key? key,
    required this.homeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (homeData == null || homeData!.isAllProductInitial) {
      return _buildShimmerLoading();
    } else if (homeData!.allProductList.isNotEmpty) {
      return _buildProductGrid(context);
    } else if (homeData!.totalAllProductData == 0) {
      return _buildNoProductMessage(context);
    } else {
      return const SizedBox.shrink(); // في حال لم يكن هناك شيء يتم عرضه
    }
  }

  // بناء الـ Shimmer عند التحميل الأولي
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: ShimmerHelper().buildProductGridShimmer(
        scontroller: homeData!.allProductScrollController,
      ),
    );
  }

  // بناء الشبكة التي تعرض المنتجات
  Widget _buildProductGrid(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      itemCount: homeData!.allProductList.length,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 20.0, bottom: 10, left: 18, right: 18),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        var product = homeData!.allProductList[index];

        return ProductCard(  // تأكد من إرجاع الـ ProductCard
          id: product.id ?? 0,  // تأكد من عدم كون id null
          slug: product.slug ?? "",  // إذا كانت null قم بتمرير قيمة فارغة
          image: product.thumbnail_image ?? "default_image.png", // تأكد من عدم وجود قيمة null في الصورة
          name: product.name ?? "No name available", // إذا كان الاسم null قم بتمرير رسالة بديلة
          main_price: product.main_price ?? "N/A", // تأكد من أن السعر غير null
          stroked_price: product.stroked_price ?? "",
          has_discount: product.has_discount ?? false,
          discount: product.discount ?? 0,
          is_wholesale: product.isWholesale ?? false,
        );
      },

    );
  }

  // عرض رسالة في حالة عدم وجود منتجات
  Widget _buildNoProductMessage(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.no_product_is_available,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
