import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/models/recipe_rating.dart';
import 'package:recipe_app/services/user_session_service.dart';

class RecipeRatingsWidget extends StatefulWidget {
  final List<RecipeRating> ratings;
  final Function(double rating, String? review) onRatingSubmitted;
  final String recipeId;

  const RecipeRatingsWidget({
    Key? key,
    required this.ratings,
    required this.onRatingSubmitted,
    required this.recipeId,
  }) : super(key: key);

  @override
  State<RecipeRatingsWidget> createState() => _RecipeRatingsWidgetState();
}

class _RecipeRatingsWidgetState extends State<RecipeRatingsWidget> {
  final TextEditingController _reviewController = TextEditingController();
  double _selectedRating = 0.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  bool _hasUserRated() {
    final currentUser = UserSessionService.getCurrentUser();
    if (currentUser == null) return false;
    
    return widget.ratings.any((rating) => rating.userId == currentUser.id);
  }

  RecipeRating? _getUserRating() {
    final currentUser = UserSessionService.getCurrentUser();
    if (currentUser == null) return null;
    
    try {
      return widget.ratings.firstWhere((rating) => rating.userId == currentUser.id);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating submission section
        if (!_hasUserRated()) _buildRatingSubmissionSection(),
        
        // User's existing rating (if any)
        if (_hasUserRated()) _buildUserRatingSection(),
        
        // Divider
        if (widget.ratings.isNotEmpty) 
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(),
          ),
        
        // All ratings list
        _buildRatingsList(),
      ],
    );
  }

  Widget _buildRatingSubmissionSection() {
    final currentUser = UserSessionService.getCurrentUser();
    
    if (currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Please log in to rate this recipe',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate this recipe',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          // Star rating selector
          Row(
            children: [
              const Text(
                'Your rating: ',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              ...List.generate(5, (index) {
                final starValue = index + 1.0;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = starValue;
                    });
                  },
                  child: Icon(
                    Icons.star,
                    size: 32,
                    color: starValue <= _selectedRating
                        ? AppColors.primary
                        : Colors.grey[300],
                  ),
                );
              }),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Optional review text field
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write a review (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedRating > 0 && !_isSubmitting ? _submitRating : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                      ),
                    )
                  : const Text(
                      'Submit Rating',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRatingSection() {
    final userRating = _getUserRating();
    if (userRating == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Your rating: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              ...List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 20,
                  color: index < userRating.rating.floor()
                      ? AppColors.primary
                      : Colors.grey[300],
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${userRating.rating}/5',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (userRating.review != null && userRating.review!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              userRating.review!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Rated ${_getTimeAgo(userRating.dateCreated)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsList() {
    final otherRatings = widget.ratings.where((rating) {
      final currentUser = UserSessionService.getCurrentUser();
      return currentUser == null || rating.userId != currentUser.id;
    }).toList();

    if (otherRatings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
          'No ratings yet. Be the first to rate this recipe!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Ratings (${otherRatings.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: otherRatings.length,
          itemBuilder: (context, index) {
            final rating = otherRatings[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 16,
                        child: Text(
                          'U', // Could be enhanced with actual user names
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ...List.generate(5, (starIndex) {
                                return Icon(
                                  Icons.star,
                                  size: 16,
                                  color: starIndex < rating.rating.floor()
                                      ? AppColors.primary
                                      : Colors.grey[300],
                                );
                              }),
                              const SizedBox(width: 8),
                              Text(
                                '${rating.rating}/5',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _getTimeAgo(rating.dateCreated),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (rating.review != null && rating.review!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      rating.review!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _submitRating() async {
    if (_selectedRating <= 0) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final review = _reviewController.text.trim();
      await widget.onRatingSubmitted(
        _selectedRating,
        review.isEmpty ? null : review,
      );

      // Reset form
      setState(() {
        _selectedRating = 0.0;
        _reviewController.clear();
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rating submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting rating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 