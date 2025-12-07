class BannerModel {
  final int id;
  final String imageUrl;
  final String title;
  final String redirectUrl;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.redirectUrl,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      title: json['title'] ?? '',
      redirectUrl: json['redirect_url'] ?? '',
    );
  }

  static List<BannerModel> fromJsonList(List<dynamic> list) {
    return list.map((e) => BannerModel.fromJson(e)).toList();
  }
}
