class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userImage;
  final String? userAvatar;
  final double rating;
  final String title;
  final String? review;
  final String? comment;
  final List<String>? images;
  final int helpfulCount;
  final bool isVerifiedPurchase;
  final bool? verified;
  final DateTime createdAt;
  final List<String>? helpfulUsers;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userImage,
    this.userAvatar,
    required this.rating,
    required this.title,
    this.review,
    this.comment,
    this.images,
    this.helpfulCount = 0,
    this.isVerifiedPurchase = false,
    this.verified,
    required this.createdAt,
    this.helpfulUsers,
  });

  ReviewModel copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userImage,
    String? userAvatar,
    double? rating,
    String? title,
    String? review,
    String? comment,
    List<String>? images,
    int? helpfulCount,
    bool? isVerifiedPurchase,
    bool? verified,
    DateTime? createdAt,
    List<String>? helpfulUsers,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      review: review ?? this.review,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      verified: verified ?? this.verified,
      createdAt: createdAt ?? this.createdAt,
      helpfulUsers: helpfulUsers ?? this.helpfulUsers,
    );
  }
}
