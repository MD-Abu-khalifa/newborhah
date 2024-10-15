import 'dart:convert';

ProductDetailsResponse productDetailsResponseFromJson(String str) =>
    ProductDetailsResponse.fromJson(json.decode(str));

String productDetailsResponseToJson(ProductDetailsResponse data) =>
    json.encode(data.toJson());

class ProductDetailsResponse {
  ProductDetailsResponse({
    this.detailed_products,
    this.success,
    this.status,
  });

  List<DetailedProduct>? detailed_products;
  bool? success;
  int? status;

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> json) =>
      ProductDetailsResponse(
        detailed_products: json["data"] != null
            ? List<DetailedProduct>.from(
            json["data"].map((x) => DetailedProduct.fromJson(x)))
            : [], // التأكد من عدم وجود null
        success: json["success"] ?? false, // التحقق من null وتحديد قيمة افتراضية
        status: json["status"] ?? 0, // التحقق من null وتحديد قيمة افتراضية
      );

  Map<String, dynamic> toJson() => {
    "data": detailed_products != null
        ? List<dynamic>.from(detailed_products!.map((x) => x.toJson()))
        : [], // التأكد من عدم وجود null
    "success": success ?? false, // التأكد من عدم وجود null
    "status": status ?? 0, // التأكد من عدم وجود null
  };
}

class DetailedProduct {
  DetailedProduct({
    this.id,
    this.name,
    this.added_by,
    this.seller_id,
    this.shop_id,
    this.shop_slug,
    this.shop_name,
    this.shop_logo,
    this.photos,
    this.thumbnail_image,
    this.tags,
    this.price_high_low,
    this.choice_options,
    this.colors,
    this.has_discount,
    this.discount,
    this.stroked_price,
    this.main_price,
    this.calculable_price,
    this.currency_symbol,
    this.current_stock,
    this.unit,
    this.rating,
    this.rating_count,
    this.earn_point,
    this.description,
    this.downloads,
    this.video_link,
    this.link,
    this.brand,
    this.wholesale,
    this.estShippingTime,
  });

  int? id;
  String? name;
  String? added_by;
  int? seller_id;
  int? shop_id;
  String? shop_slug;
  String? shop_name;
  String? shop_logo;
  List<Photo>? photos;
  String? thumbnail_image;
  List<String>? tags;
  String? price_high_low;
  List<ChoiceOption>? choice_options;
  List<dynamic>? colors;
  bool? has_discount;
  var discount;
  String? stroked_price;
  String? main_price;
  var calculable_price;
  String? currency_symbol;
  int? current_stock;
  String? unit;
  int? rating;
  int? rating_count;
  int? earn_point;
  String? description;
  String? downloads;
  String? video_link;
  String? link;
  Brand? brand;
  List<Wholesale>? wholesale;
  int? estShippingTime;

  factory DetailedProduct.fromJson(Map<String, dynamic> json) =>
      DetailedProduct(
        id: json["id"] ?? 0, // التحقق من null
        name: json["name"] ?? "No Name", // التحقق من null
        added_by: json["added_by"] ?? "", // التحقق من null
        seller_id: json["seller_id"] ?? 0, // التحقق من null
        shop_id: json["shop_id"] ?? 0, // التحقق من null
        shop_slug: json["shop_slug"] ?? "", // التحقق من null
        shop_name: json["shop_name"] ?? "Unknown Shop", // التحقق من null
        shop_logo: json["shop_logo"] ?? "", // التحقق من null
        estShippingTime: json["est_shipping_time"] ?? 0, // التحقق من null
        photos: json["photos"] != null
            ? List<Photo>.from(json["photos"].map((x) => Photo.fromJson(x)))
            : [], // التحقق من null
        thumbnail_image:
        json["thumbnail_image"] ?? "assets/placeholder.png", // التحقق من null
        tags: json["tags"] != null
            ? List<String>.from(json["tags"].map((x) => x))
            : [], // التحقق من null
        price_high_low: json["price_high_low"] ?? "N/A", // التحقق من null
        choice_options: json["choice_options"] != null
            ? List<ChoiceOption>.from(
            json["choice_options"].map((x) => ChoiceOption.fromJson(x)))
            : [], // التحقق من null
        colors: json["colors"] != null
            ? List<dynamic>.from(json["colors"].map((x) => x))
            : [], // التحقق من null
        has_discount: json["has_discount"] ?? false, // التحقق من null
        discount: json["discount"] ?? 0, // التحقق من null
        stroked_price: json["stroked_price"] ?? "", // التحقق من null
        main_price: json["main_price"] ?? "N/A", // التحقق من null
        calculable_price: json["calculable_price"] ?? 0, // التحقق من null
        currency_symbol: json["currency_symbol"] ?? "\$", // التحقق من null
        current_stock: json["current_stock"] ?? 0, // التحقق من null
        unit: json["unit"] ?? "", // التحقق من null
        rating: json["rating"]?.toInt() ?? 0, // التحقق من null
        rating_count: json["rating_count"] ?? 0, // التحقق من null
        earn_point: json["earn_point"]?.toInt() ?? 0, // التحقق من null
        description: json["description"] ?? "No Description available", // التحقق من null
        downloads: json["downloads"] ?? "", // التحقق من null
        video_link: json["video_link"] ?? "", // التحقق من null
        link: json["link"] ?? "", // التحقق من null
        brand: json["brand"] != null ? Brand.fromJson(json["brand"]) : null, // التحقق من null
        wholesale: json["wholesale"] != null
            ? List<Wholesale>.from(
            json["wholesale"].map((x) => Wholesale.fromJson(x)))
            : [], // التحقق من null
      );

  Map<String, dynamic> toJson() => {
    "id": id ?? 0,
    "name": name ?? "No Name",
    "added_by": added_by ?? "",
    "seller_id": seller_id ?? 0,
    "shop_id": shop_id ?? 0,
    "est_shipping_time": estShippingTime ?? 0,
    "shop_slug": shop_slug ?? "",
    "shop_name": shop_name ?? "Unknown Shop",
    "shop_logo": shop_logo ?? "",
    "photos": photos != null
        ? List<dynamic>.from(photos!.map((x) => x.toJson()))
        : [],
    "thumbnail_image": thumbnail_image ?? "assets/placeholder.png",
    "tags": tags != null ? List<dynamic>.from(tags!.map((x) => x)) : [],
    "price_high_low": price_high_low ?? "N/A",
    "choice_options": choice_options != null
        ? List<dynamic>.from(choice_options!.map((x) => x.toJson()))
        : [],
    "colors": colors != null ? List<dynamic>.from(colors!.map((x) => x)) : [],
    "discount": discount ?? 0,
    "stroked_price": stroked_price ?? "",
    "main_price": main_price ?? "N/A",
    "calculable_price": calculable_price ?? 0,
    "currency_symbol": currency_symbol ?? "\$",
    "current_stock": current_stock ?? 0,
    "unit": unit ?? "",
    "rating": rating ?? 0,
    "rating_count": rating_count ?? 0,
    "earn_point": earn_point ?? 0,
    "description": description ?? "No Description available",
    "downloads": downloads ?? "",
    "video_link": video_link ?? "",
    "link": link ?? "",
    "brand": brand?.toJson(),
    "wholesale": wholesale != null
        ? List<dynamic>.from(wholesale!.map((x) => x.toJson()))
        : [],
  };
}

class Brand {
  Brand({
    this.id,
    this.slug,
    this.name,
    this.logo,
  });

  int? id;
  String? slug;
  String? name;
  String? logo;

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
    id: json["id"] ?? 0, // التحقق من null
    slug: json["slug"] ?? "", // التحقق من null
    name: json["name"] ?? "No Name", // التحقق من null
    logo: json["logo"] ?? "", // التحقق من null
  );

  Map<String, dynamic> toJson() => {
    "id": id ?? 0,
    "slug": slug ?? "",
    "name": name ?? "No Name",
    "logo": logo ?? "",
  };
}

class Photo {
  Photo({
    this.variant,
    this.path,
  });

  String? variant;
  String? path;

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    variant: json["variant"] ?? "", // التحقق من null
    path: json["path"] ?? "", // التحقق من null
  );

  Map<String, dynamic> toJson() => {
    "variant": variant ?? "",
    "path": path ?? "",
  };
}

class ChoiceOption {
  ChoiceOption({
    this.name,
    this.title,
    this.options,
  });

  String? name;
  String? title;
  List<String>? options;

  factory ChoiceOption.fromJson(Map<String, dynamic> json) => ChoiceOption(
    name: json["name"] ?? "", // التحقق من null
    title: json["title"] ?? "", // التحقق من null
    options: json["options"] != null
        ? List<String>.from(json["options"].map((x) => x))
        : [], // التحقق من null
  );

  Map<String, dynamic> toJson() => {
    "name": name ?? "",
    "title": title ?? "",
    "options": options != null ? List<dynamic>.from(options!.map((x) => x)) : [],
  };
}

class Wholesale {
  var minQty;
  var maxQty;
  var price;

  Wholesale({
    this.minQty,
    this.maxQty,
    this.price,
  });

  factory Wholesale.fromJson(Map<String, dynamic> json) => Wholesale(
    minQty: json["min_qty"] ?? 0, // التحقق من null
    maxQty: json["max_qty"] ?? 0, // التحقق من null
    price: json["price"] ?? 0, // التحقق من null
  );

  Map<String, dynamic> toJson() => {
    "min_qty": minQty ?? 0,
    "max_qty": maxQty ?? 0,
    "price": price ?? 0,
  };
}
