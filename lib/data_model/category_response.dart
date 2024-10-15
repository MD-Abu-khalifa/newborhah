import 'dart:convert';

// To parse this JSON data, use
// final categoryResponse = categoryResponseFromJson(jsonString);

CategoryResponse categoryResponseFromJson(String str) => CategoryResponse.fromJson(json.decode(str));

String categoryResponseToJson(CategoryResponse data) => json.encode(data.toJson());

class CategoryResponse {
  CategoryResponse({
    required this.categories,
    required this.success,
    required this.status,
  });

  List<Category>? categories;
  bool? success;
  int? status;

  // Factory method to create an instance from a JSON map
  factory CategoryResponse.fromJson(Map<String, dynamic> json) => CategoryResponse(
    categories: json["data"] != null
        ? List<Category>.from(json["data"].map((x) => Category.fromJson(x)))
        : [], // Handle null or empty data
    success: json["success"] ?? false, // Default to false if null
    status: json["status"] ?? 0, // Default to 0 if null
  );

  // Method to serialize the instance to JSON
  Map<String, dynamic> toJson() => {
    "data": categories != null ? List<dynamic>.from(categories!.map((x) => x.toJson())) : [],
    "success": success ?? false,
    "status": status ?? 0,
  };
}

class Category {
  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.banner,
    required this.icon,
    required this.numberOfChildren,
    required this.links,
  });

  int? id;
  String? name;
  String? slug;
  String? banner;
  String? icon;
  int? numberOfChildren;
  Links? links;

  // Factory method to create an instance from a JSON map
  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"] ?? 0, // Default to 0 if null
    name: json["name"] ?? "Unknown", // Default to "Unknown" if null
    slug: json["slug"] ?? "", // Default to empty string if null
    banner: json["banner"] ?? "", // Default to empty string if null
    icon: json["icon"] ?? "", // Default to empty string if null
    numberOfChildren: json["number_of_children"] ?? 0, // Default to 0 if null
    links: json["links"] != null ? Links.fromJson(json["links"]) : null, // Handle null for links
  );

  // Method to serialize the instance to JSON
  Map<String, dynamic> toJson() => {
    "id": id ?? 0,
    "name": name ?? "Unknown",
    "slug": slug ?? "",
    "banner": banner ?? "",
    "icon": icon ?? "",
    "number_of_children": numberOfChildren ?? 0,
    "links": links != null ? links!.toJson() : {}, // Handle null links safely
  };
}

class Links {
  Links({
    required this.products,
    required this.subCategories,
  });

  String? products;
  String? subCategories;

  // Factory method to create an instance from a JSON map
  factory Links.fromJson(Map<String, dynamic> json) => Links(
    products: json["products"] ?? "", // Default to empty string if null
    subCategories: json["sub_categories"] ?? "", // Default to empty string if null
  );

  // Method to serialize the instance to JSON
  Map<String, dynamic> toJson() => {
    "products": products ?? "",
    "sub_categories": subCategories ?? "",
  };
}
