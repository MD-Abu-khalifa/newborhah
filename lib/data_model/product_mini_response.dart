import 'dart:convert';

ProductMiniResponse productMiniResponseFromJson(String str) =>
    ProductMiniResponse.fromJson(json.decode(str));

String productMiniResponseToJson(ProductMiniResponse data) =>
    json.encode(data.toJson());

class ProductMiniResponse {
  ProductMiniResponse({
    this.products,
    this.meta,
    this.success,
    this.status,
  });

  List<Product>? products;
  bool? success;
  int? status;
  Meta? meta;

  // Parsing JSON with null safety
  factory ProductMiniResponse.fromJson(Map<String, dynamic> json) =>
      ProductMiniResponse(
        products: json["data"] != null
            ? List<Product>.from(json["data"].map((x) => Product.fromJson(x)))
            : [], // Handle null by returning an empty list
        meta: json["meta"] != null ? Meta.fromJson(json["meta"]) : null, // Handle null
        success: json["success"] ?? false, // Default to false if null
        status: json["status"] ?? 0, // Default to 0 if null
      );

  Map<String, dynamic> toJson() => {
    "data": products != null
        ? List<dynamic>.from(products!.map((x) => x.toJson()))
        : [], // Handle null
    "meta": meta?.toJson(), // Handle null
    "success": success ?? false, // Default to false if null
    "status": status ?? 0, // Default to 0 if null
  };
}

class Product {
  Product({
    this.id,
    this.slug,
    this.name,
    this.thumbnail_image,
    this.main_price,
    this.stroked_price,
    this.has_discount,
    this.discount,
    this.rating,
    this.sales,
    this.links,
    this.isWholesale,
  });

  int? id;
  String? slug;
  String? name;
  String? thumbnail_image;
  String? main_price;
  String? stroked_price;
  bool? has_discount;
  var discount; // Ensure it can accept both int and double
  int? rating;
  int? sales;
  Links? links;
  bool? isWholesale;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"] ?? 0, // Default to 0 if null
    slug: json["slug"] ?? "", // Default to an empty string if null
    name: json["name"] ?? "Unknown", // Default to 'Unknown' if null
    thumbnail_image: json["thumbnail_image"] ?? "assets/placeholder.png", // Placeholder image if null
    main_price: json["main_price"] ?? "N/A", // Default to 'N/A' if null
    stroked_price: json["stroked_price"] ?? "", // Default to empty string if null
    has_discount: json["has_discount"] ?? false, // Default to false if null
    discount: json["discount"] ?? 0, // Default to 0 if null
    rating: json["rating"]?.toInt() ?? 0, // Handle null and ensure it's an int
    sales: json["sales"] ?? 0, // Default to 0 if null
    links: json["links"] != null ? Links.fromJson(json["links"]) : null, // Handle null for links
    isWholesale: json["is_wholesale"] ?? false, // Default to false if null
  );

  Map<String, dynamic> toJson() => {
    "id": id ?? 0,
    "slug": slug ?? "",
    "name": name ?? "Unknown",
    "thumbnail_image": thumbnail_image ?? "assets/placeholder.png",
    "main_price": main_price ?? "N/A",
    "stroked_price": stroked_price ?? "",
    "has_discount": has_discount ?? false,
    "discount": discount ?? 0,
    "rating": rating ?? 0,
    "sales": sales ?? 0,
    "links": links?.toJson(), // Handle null
    "is_wholesale": isWholesale ?? false,
  };
}

class Links {
  Links({
    this.details,
  });

  String? details;

  factory Links.fromJson(Map<String, dynamic> json) => Links(
    details: json["details"] ?? "", // Default to empty string if null
  );

  Map<String, dynamic> toJson() => {
    "details": details ?? "", // Handle null
  };
}

class Meta {
  Meta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  int? currentPage;
  int? from;
  int? lastPage;
  String? path;
  int? perPage;
  int? to;
  int? total;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    currentPage: json["current_page"] ?? 0, // Default to 0 if null
    from: json["from"] ?? 0, // Default to 0 if null
    lastPage: json["last_page"] ?? 0, // Default to 0 if null
    path: json["path"] ?? "", // Default to empty string if null
    perPage: json["per_page"] ?? 0, // Default to 0 if null
    to: json["to"] ?? 0, // Default to 0 if null
    total: json["total"] ?? 0, // Default to 0 if null
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage ?? 0,
    "from": from ?? 0,
    "last_page": lastPage ?? 0,
    "path": path ?? "",
    "per_page": perPage ?? 0,
    "to": to ?? 0,
    "total": total ?? 0,
  };
}
