import 'package:flutter/material.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  Map<String, List<ReviewModel>> _productReviews = {};
  List<ReviewModel> _userReviews = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, List<ReviewModel>> get productReviews => _productReviews;
  List<ReviewModel> get userReviews => _userReviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ReviewProvider() {
    loadMockReviews();
  }

  void loadMockReviews() {
    // Reviews for RTX 4090
    _productReviews['prod1'] = [
      ReviewModel(
        id: 'rev1',
        productId: 'prod1',
        userId: 'user2',
        userName: 'GamerPro123',
        userAvatar: 'https://example.com/avatar1.jpg',
        rating: 5,
        title: 'Absolute Beast of a GPU',
        comment: 'This card is incredible! Runs Cyberpunk at 4K ultra settings with ray tracing at over 60fps. DLSS 3 is a game changer.',
        helpfulCount: 45,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        verified: true,
      ),
      ReviewModel(
        id: 'rev2',
        productId: 'prod1',
        userId: 'user3',
        userName: 'PCBuilder101',
        userAvatar: 'https://example.com/avatar2.jpg',
        rating: 4,
        title: 'Amazing performance but pricey',
        comment: 'The performance is unmatched but the price is steep. If you have the budget, go for it.',
        helpfulCount: 23,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        verified: true,
      ),
    ];

    // Reviews for Elden Ring
    _productReviews['prod5'] = [
      ReviewModel(
        id: 'rev3',
        productId: 'prod5',
        userId: 'user4',
        userName: 'SoulsVeteran',
        userAvatar: 'https://example.com/avatar3.jpg',
        rating: 5,
        title: 'Masterpiece',
        comment: 'FromSoftware has outdone themselves. The world design is breathtaking and the combat is as satisfying as ever.',
        helpfulCount: 89,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        verified: true,
      ),
    ];

    // User's own reviews
    _userReviews = [
      ReviewModel(
        id: 'rev4',
        productId: 'prod7',
        userId: 'user1',
        userName: 'Current User',
        rating: 4,
        title: 'Great keyboard',
        comment: 'The switches are responsive and the RGB is vibrant. Software could be better.',
        helpfulCount: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        verified: true,
      ),
    ];

    notifyListeners();
  }

  List<ReviewModel> getReviewsForProduct(String productId) {
    return _productReviews[productId] ?? [];
  }

  double getAverageRatingForProduct(String productId) {
    final reviews = _productReviews[productId];
    if (reviews == null || reviews.isEmpty) return 0.0;
    
    double total = reviews.fold(0.0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }

  Map<int, int> getRatingDistribution(String productId) {
    final distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    final reviews = _productReviews[productId];
    
    if (reviews != null) {
      for (var review in reviews) {
        final ratingInt = review.rating.toInt();
        distribution[ratingInt] = (distribution[ratingInt] ?? 0) + 1;
      }
    }
    
    return distribution;
  }

  Future<bool> addReview(ReviewModel review) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Add to product reviews
      if (!_productReviews.containsKey(review.productId)) {
        _productReviews[review.productId] = [];
      }
      _productReviews[review.productId]!.insert(0, review);
      
      // Add to user reviews
      _userReviews.insert(0, review);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add review';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateReview(String reviewId, ReviewModel updatedReview) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Update in product reviews
      for (var productId in _productReviews.keys) {
        final index = _productReviews[productId]!.indexWhere((r) => r.id == reviewId);
        if (index >= 0) {
          _productReviews[productId]![index] = updatedReview;
          break;
        }
      }

      // Update in user reviews
      final userIndex = _userReviews.indexWhere((r) => r.id == reviewId);
      if (userIndex >= 0) {
        _userReviews[userIndex] = updatedReview;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update review';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Remove from product reviews
      for (var productId in _productReviews.keys) {
        _productReviews[productId]!.removeWhere((r) => r.id == reviewId);
      }

      // Remove from user reviews
      _userReviews.removeWhere((r) => r.id == reviewId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete review';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> markHelpful(String reviewId, String userId) async {
    for (var productId in _productReviews.keys) {
      final index = _productReviews[productId]!.indexWhere((r) => r.id == reviewId);
      if (index >= 0) {
        final review = _productReviews[productId]![index];
        final helpfulUsers = review.helpfulUsers ?? [];
        if (!helpfulUsers.contains(userId)) {
          _productReviews[productId]![index] = review.copyWith(
            helpfulCount: review.helpfulCount + 1,
            helpfulUsers: [...helpfulUsers, userId],
          );
          notifyListeners();
        }
        break;
      }
    }
  }

  bool hasUserReviewed(String productId, String userId) {
    final reviews = _productReviews[productId];
    if (reviews == null) return false;
    return reviews.any((review) => review.userId == userId);
  }

  ReviewModel? getUserReviewForProduct(String productId, String userId) {
    final reviews = _productReviews[productId];
    if (reviews == null) return null;
    try {
      return reviews.firstWhere((review) => review.userId == userId);
    } catch (e) {
      return null;
    }
  }
}