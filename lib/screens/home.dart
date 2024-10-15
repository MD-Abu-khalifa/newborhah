import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/presenter/home_presenter.dart';
import 'package:active_ecommerce_flutter/screens/filter.dart';
import 'package:active_ecommerce_flutter/screens/flash_deal/flash_deal_list.dart';
import 'package:active_ecommerce_flutter/screens/product/todays_deal_products.dart';
import 'package:active_ecommerce_flutter/screens/top_sellers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../custom/feature_categories_widget.dart';
import '../custom/featured_product_horizontal_list_widget.dart';
import '../custom/home_all_products_2.dart';
import '../custom/home_banner_one.dart';
import '../custom/home_banner_two.dart';
import '../custom/home_carousel_slider.dart';
import '../custom/home_search_box.dart';
import '../custom/pirated_widget.dart';

class Home extends StatefulWidget {
  final String? title;
  final bool showBackButton;
  final bool goBack;

  const Home({
    Key? key,
    this.title,
    this.showBackButton = false,
    this.goBack = true,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final HomePresenter homeData = HomePresenter();

  @override
  void initState() {
    super.initState();
    _initializeHomeData();
  }

  void _initializeHomeData() {
    homeData.onRefresh();
    homeData.mainScrollListener();
    homeData.initPiratedAnimation(this);
  }

  @override
  void dispose() {
    homeData.pirated_logo_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () async => widget.goBack,
      child: Directionality(
        textDirection:
        app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Scaffold(
            appBar: buildAppBar(statusBarHeight, context),
            body: AnimatedBuilder(
              animation: homeData,
              builder: (context, child) {
                return Stack(
                  children: [
                    _buildCustomScrollView(context),
                    if (homeData.showAllLoadingContainer)
                      _buildLoadingIndicator(homeData),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Filter())),
          child: HomeSearchBox(),
        ),
      ),
    );
  }

  Widget _buildCustomScrollView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: homeData.onRefresh,
      color: MyTheme.accent_color,
      backgroundColor: Colors.white,
      child: CustomScrollView(
        controller: homeData.mainScrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: <Widget>[
          _buildMainContent(context),
          _buildFeaturedCategories(),
          _buildBannerSection(),
          _buildAllProductsSection(context),
        ],
      ),
    );
  }

  SliverList _buildMainContent(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        if (AppConfig.purchase_code.isEmpty) PiratedWidget(homeData: homeData),
        HomeCarouselSlider(context: context, homeData: homeData),
        _buildMenuRow(context),
        HomeBannerOne(context: context, homeData: homeData),
      ]),
    );
  }

  Widget _buildMenuRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          if (homeData.isTodayDeal)
            _buildMenuItem(
              context,
              "assets/todays_deal.png",
              AppLocalizations.of(context)!.todays_deal_ucf,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => TodaysDealProducts())),
            ),
          if (homeData.isFlashDeal && homeData.isTodayDeal) const SizedBox(width: 14.0),
          if (homeData.isFlashDeal)
            _buildMenuItem(
              context,
              "assets/flash_deal.png",
              AppLocalizations.of(context)!.flash_deal_ucf,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => FlashDealList())),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String iconPath, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 90,
          decoration: BoxDecorations.buildBoxDecoration_1(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconPath, height: 20, width: 20),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color.fromRGBO(132, 132, 132, 1), fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildFeaturedCategories() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 154,
        child: FeaturedCategoriesWidget(homeData: homeData),
      ),
    );
  }

  SliverList _buildBannerSection() {
    return SliverList(
      delegate: SliverChildListDelegate([
        HomeBannerTwo(context: context, homeData: homeData),
      ]),
    );
  }

  SliverList _buildAllProductsSection(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.fromLTRB(18.0, 18.0, 20.0, 0.0),
          child: Text(
            AppLocalizations.of(context)!.all_products_ucf,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        HomeAllProducts2(homeData: homeData),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _buildLoadingIndicator(HomePresenter homeData) {
    return Positioned(
      bottom: 0,
      child: Container(
        height: 36,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Center(
          child: Text(
            homeData.totalAllProductData == homeData.allProductList.length
                ? AppLocalizations.of(context)!.no_more_products_ucf
                : AppLocalizations.of(context)!.loading_more_products_ucf,
          ),
        ),
      ),
    );
  }
}
