import 'dart:async';
import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/data_model/category_response.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CategoryProducts extends StatefulWidget {
  final String slug;

  const CategoryProducts({Key? key, required this.slug}) : super(key: key);

  @override
  _CategoryProductsState createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _xcrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int _page = 1;
  int? _totalData = 0;
  bool _isInitial = true;
  String _searchKey = "";
  Category? categoryInfo;
  bool _showSearchBar = false;
  List<dynamic> _productList = [];
  bool _showLoadingContainer = false;
  List<Category> _subCategoryList = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _xcrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _setupScrollListener() {
    _xcrollController.addListener(() {
      if (_xcrollController.position.pixels == _xcrollController.position.maxScrollExtent && !_showLoadingContainer) {
        _page++;
        _showLoadingContainer = true;
        _fetchData();
      }
    });
  }

  Future<void> _fetchInitialData() async {
    try {
      await Future.wait([_fetchCategoryInfo(), _fetchSubCategories(), _fetchData()]);
    } catch (e) {
      // Handle errors and show relevant messages (optional)
    }
  }

  Future<void> _fetchSubCategories() async {
    try {
      var res = await CategoryRepository().getCategories(parent_id: widget.slug);
      setState(() {
        _subCategoryList.addAll(res.categories ?? []);
      });
    } catch (e) {
      // Handle fetch error here
    }
  }

  Future<void> _fetchCategoryInfo() async {
    try {
      var res = await CategoryRepository().getCategoryInfo(widget.slug);
      setState(() {
        categoryInfo = res.categories?.isNotEmpty ?? false ? res.categories!.first : null;
      });
    } catch (e) {
      // Handle fetch error here
    }
  }

  Future<void> _fetchData() async {
    try {
      var productResponse = await ProductRepository().getCategoryProducts(
        id: widget.slug,
        page: _page,
        name: _searchKey,
      );
      setState(() {
        _productList.addAll(productResponse.products ?? []);
        _isInitial = false;
        _totalData = productResponse.meta?.total ?? 0;
        _showLoadingContainer = false;
      });
    } catch (e) {
      // Handle fetch error here
    }
  }

  void _resetData() {
    setState(() {
      _subCategoryList.clear();
      _productList.clear();
      _isInitial = true;
      _totalData = 0;
      _page = 1;
      _showLoadingContainer = false;
    });
  }

  Future<void> _onRefresh() async {
    _resetData();
    await _fetchInitialData();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchKey = query;
      _resetData();
      _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildProductList(),
          Align(alignment: Alignment.bottomCenter, child: _buildLoadingContainer()),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: _subCategoryList.isEmpty
          ? DeviceInfo(context).height! / 10
          : DeviceInfo(context).height! / 6.5,
      flexibleSpace: _buildAppBarFlexibleSpace(context),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AnimatedContainer(
          height: _subCategoryList.isEmpty ? 0 : 60,
          duration: const Duration(milliseconds: 500),
          child: !_isInitial ? _buildSubCategory() : const SizedBox.shrink(),
        ),
      ),
      title: _buildAppBarTitle(context),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget _buildAppBarFlexibleSpace(BuildContext context) {
    return Container(
      height: DeviceInfo(context).height! / 4,
      width: DeviceInfo(context).width,
      color: MyTheme.accent_color,
      alignment: Alignment.topRight,
      child: Image.asset("assets/background_1.png"),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: _buildAppBarTitleOption(context),
      secondChild: _buildAppBarSearchOption(context),
      firstCurve: Curves.fastOutSlowIn,
      secondCurve: Curves.fastOutSlowIn,
      crossFadeState: _showSearchBar ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildAppBarTitleOption(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          UsefulElements.backButton(context, color: "white"),
          const SizedBox(width: 10),
          Text(
            categoryInfo?.name ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, size: 25),
            onPressed: () {
              setState(() {
                _showSearchBar = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarSearchOption(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: TextField(
        controller: _searchController,
        autofocus: false,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _showSearchBar = false;
              });
            },
            icon: const Icon(Icons.clear, color: MyTheme.grey_153),
          ),
          filled: true,
          fillColor: MyTheme.white.withOpacity(0.6),
          hintText: "${AppLocalizations.of(context)!.search_products_from} :",
          hintStyle: const TextStyle(fontSize: 14.0, color: MyTheme.font_grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(8.0),
        ),
      ),
    );
  }

  Widget _buildSubCategory() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryProducts(slug: _subCategoryList[index].slug!),
              ),
            );
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecorations.buildBoxDecoration_1(),
            child: Text(
              _subCategoryList[index].name!,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: MyTheme.font_grey),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      itemCount: _subCategoryList.length,
    );
  }

  Widget _buildProductList() {
    if (_isInitial && _productList.isEmpty) {
      return SingleChildScrollView(
        child: ShimmerHelper().buildProductGridShimmer(scontroller: _scrollController),
      );
    } else if (_productList.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        color: MyTheme.accent_color,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          controller: _xcrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            itemCount: _productList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.all(18),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              var product = _productList[index];

              return ProductCard(
                id: product.id ?? 0, // تأكد من أن id ليس null
                slug: product.slug ?? '', // إذا كانت slug null، قم بتمرير قيمة افتراضية
                image: product.thumbnail_image ?? 'assets/placeholder.png', // صورة افتراضية في حالة عدم وجود صورة
                name: product.name ?? 'No Name', // نص افتراضي إذا كان الاسم فارغًا
                main_price: product.main_price ?? 'N/A', // عرض "N/A" في حالة عدم وجود سعر
                stroked_price: product.stroked_price ?? '', // قيمة افتراضية إذا كانت stroked_price فارغة
                discount: product.discount ?? 0, // التأكد من وجود قيمة الخصم، افتراضيًا 0
                is_wholesale: product.isWholesale ?? false, // تأكد من أن is_wholesale ليس null
                has_discount: product.has_discount ?? false, // تأكد من أن has_discount ليس null
              );
            },

          ),
        ),
      );
    } else if (_totalData == 0) {
      return Center(
        child: Text(AppLocalizations.of(context)!.no_data_is_available),
      );
    } else {
      return const SizedBox.shrink(); // Fallback
    }
  }

  Widget _buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(
          _totalData == _productList.length
              ? AppLocalizations.of(context)!.no_more_products_ucf
              : AppLocalizations.of(context)!.loading_more_products_ucf,
        ),
      ),
    );
  }
}
