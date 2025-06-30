import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/models/post.dart';
import 'package:recipe_app/models/user.dart';
import 'package:recipe_app/services/mock_data_service.dart';
import 'package:recipe_app/services/user_session_service.dart';
import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/widgets/custom_bottom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // Constants
  static const int _communityTabIndex = 4;
  static const Duration _snackBarDuration = Duration(seconds: 2);
  static const Duration _duplicatePostDelay = Duration(minutes: 5);

  // State
  List<Post> _posts = [];
  final _postController = TextEditingController();
  final _commentController = TextEditingController();
  final Set<String> _recentPostContents = {};
  String? _showingCommentsForPost;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = true;
  bool _isUploadingPost = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _postController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // Navigation
  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _onNavBarTap(int index) {
    if (index == _communityTabIndex) return;

    final routes = {
      0: '/',
      1: '/search',
      3: '/favorites',
    };

    if (routes.containsKey(index)) {
      if (index == 0 || index == 3) {
        Navigator.pushReplacementNamed(context, routes[index]!);
      } else {
        Navigator.pushNamed(context, routes[index]!);
      }
    }
  }

  // Data Loading
  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    try {
      final posts = await FirebaseService.getAllPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _posts = [];
        _isLoading = false;
      });
    }
  }

  // Image Handling
  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      _showSnackBar('Failed to pick image', isError: true);
    }
  }

  void _removeSelectedImage() {
    setState(() => _selectedImage = null);
  }

  // Post Operations
  Future<void> _createPost() async {
    final content = _postController.text.trim();

    if (content.isEmpty && _selectedImage == null) return;

    if (_recentPostContents.contains(content)) {
      _showSnackBar(
        'You recently posted this content. Please wait before posting again.',
        isError: true,
      );
      return;
    }

    final currentUser = UserSessionService.getCurrentUser();
    if (currentUser == null) {
      _showSnackBar('Please log in to create posts', isError: true);
      return;
    }

    setState(() => _isUploadingPost = true);

    try {
      final newPost = Post(
        id: '',
        userId: currentUser.id,
        userName: currentUser.name,
        userProfileUrl: currentUser.profileImageUrl,
        content: content,
        image: null,
        createdAt: DateTime.now(),
        likes: 0,
        hasLiked: false,
        comments: [],
      );

      final postId =
          await FirebaseService.createPostWithImage(newPost, _selectedImage);

      if (postId != null) {
        _recentPostContents.add(content);
        Future.delayed(
            _duplicatePostDelay, () => _recentPostContents.remove(content));

        await _loadPosts();
        setState(() {
          _postController.clear();
          _selectedImage = null;
        });

        _showSnackBar('Post created successfully!', isSuccess: true);
      } else {
        _showSnackBar('Failed to create post. Please try again.',
            isError: true);
      }
    } catch (e) {
      _showSnackBar('Error creating post. Please try again.', isError: true);
    } finally {
      setState(() => _isUploadingPost = false);
    }
  }

  Future<void> _deletePost(Post post) async {
    final currentUser = UserSessionService.getCurrentUser();
    if (currentUser == null || currentUser.id != post.userId) {
      _showSnackBar('You can only delete your own posts', isError: true);
      return;
    }

    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed != true) return;

    try {
      final success = await FirebaseService.deletePost(post.id);
      if (success) {
        setState(() => _posts.removeWhere((p) => p.id == post.id));
        _showSnackBar('Post deleted successfully', isSuccess: true);
      } else {
        _showSnackBar('Failed to delete post', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error deleting post', isError: true);
    }
  }

  Future<void> _toggleLike(Post post) async {
    final currentUser = UserSessionService.getCurrentUser();
    if (currentUser == null) {
      _showSnackBar('Please log in to like posts', isError: true);
      return;
    }

    try {
      final postIndex = _posts.indexWhere((p) => p.id == post.id);
      if (postIndex == -1) return;

      final currentPost = _posts[postIndex];
      final isLiked = currentPost.isLikedByUser(currentUser.id);
      final newLikedBy = List<String>.from(currentPost.likedBy);

      if (isLiked) {
        newLikedBy.remove(currentUser.id);
      } else {
        newLikedBy.add(currentUser.id);
      }

      setState(() {
        _posts[postIndex] = currentPost.copyWith(
          hasLiked: !isLiked,
          likes: newLikedBy.length,
          likedBy: newLikedBy,
        );
      });

      final success =
          await FirebaseService.togglePostLike(post.id, currentUser.id);
      if (!success) {
        setState(() => _posts[postIndex] = post);
        _showSnackBar('Failed to update like. Please try again.',
            isError: true);
      }
    } catch (e) {
      // Silent fail for likes
    }
  }

  Future<void> _addComment(Post post, String content) async {
    final currentUser = UserSessionService.getCurrentUser();
    if (currentUser == null) {
      _showSnackBar('Please log in to comment', isError: true);
      return;
    }

    if (content.trim().isEmpty) return;

    try {
      final newComment = PostComment(
        id: FirebaseService.generateId(),
        userId: currentUser.id,
        userName: currentUser.name,
        userProfileUrl: currentUser.profileImageUrl,
        content: content.trim(),
        createdAt: DateTime.now(),
      );

      final postIndex = _posts.indexWhere((p) => p.id == post.id);
      if (postIndex == -1) return;

      setState(() {
        _posts[postIndex] = _posts[postIndex].copyWith(
          comments: [..._posts[postIndex].comments, newComment],
        );
      });

      _commentController.clear();

      final success =
          await FirebaseService.addCommentToPost(post.id, newComment);
      if (!success) {
        setState(() => _posts[postIndex] = post);
        _showSnackBar('Failed to add comment. Please try again.',
            isError: true);
      }
    } catch (e) {
      // Silent fail for comments
    }
  }

  // UI Helpers
  void _showSnackBar(String message,
      {bool isError = false, bool isSuccess = false}) {
    final color =
        isError ? Colors.red : (isSuccess ? Colors.green : Colors.orange);
    final icon =
        isError ? Icons.error : (isSuccess ? Icons.check_circle : Icons.info);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: _snackBarDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Post',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textPrimary.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _CreatePostSection(
            postController: _postController,
            selectedImage: _selectedImage,
            isUploadingPost: _isUploadingPost,
            onPickImage: _pickImage,
            onRemoveImage: _removeSelectedImage,
            onCreatePost: _createPost,
          ),
          Expanded(
            child: _isLoading
                ? const _LoadingState()
                : _posts.isEmpty
                    ? const _EmptyState()
                    : _PostsList(
                        posts: _posts,
                        showingCommentsForPost: _showingCommentsForPost,
                        commentController: _commentController,
                        onToggleLike: _toggleLike,
                        onDeletePost: _deletePost,
                        onAddComment: _addComment,
                        onToggleComments: (postId) {
                          setState(() {
                            _showingCommentsForPost =
                                _showingCommentsForPost == postId
                                    ? null
                                    : postId;
                          });
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _communityTabIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: _navigateBack,
      ),
      title: Text(
        'Community',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
    );
  }
}

// Extracted Widgets
class _CreatePostSection extends StatelessWidget {
  final TextEditingController postController;
  final File? selectedImage;
  final bool isUploadingPost;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onCreatePost;

  const _CreatePostSection({
    required this.postController,
    required this.selectedImage,
    required this.isUploadingPost,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const _UserAvatar(radius: 20, fontSize: 16),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: postController,
                  maxLines: null,
                  decoration: _inputDecoration(
                    'Share a recipe or cooking tip...',
                    borderRadius: 20,
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              _buildPhotoButton(),
              const SizedBox(width: 8),
              _buildSendButton(),
            ],
          ),
          if (selectedImage != null) ...[
            const SizedBox(height: 12),
            _ImagePreview(
              image: selectedImage!,
              onRemove: onRemoveImage,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(Icons.photo_camera_rounded,
            color: AppColors.primary, size: 20),
        onPressed: onPickImage,
        tooltip: 'Add photo',
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isUploadingPost
          ? Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                ),
              ),
            )
          : IconButton(
              icon: Icon(Icons.send_rounded,
                  color: AppColors.textPrimary, size: 20),
              onPressed: isUploadingPost ? null : onCreatePost,
              padding: EdgeInsets.zero,
            ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final double radius;
  final double fontSize;
  final User? user;

  const _UserAvatar({
    required this.radius,
    required this.fontSize,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = user ?? UserSessionService.getCurrentUser();

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.2),
        radius: radius,
        child: _buildAvatarContent(currentUser),
      ),
    );
  }

  Widget _buildAvatarContent(User? user) {
    if (user?.profileImageUrl == null) {
      return Text(
        user?.name[0].toUpperCase() ?? 'G',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      );
    }

    final isAsset = user!.profileImageUrl!.startsWith('assets/');

    return ClipOval(
      child: isAsset
          ? Image.asset(
              user.profileImageUrl!,
              fit: BoxFit.cover,
              width: radius * 2,
              height: radius * 2,
              errorBuilder: (_, __, ___) => _buildFallbackText(user),
            )
          : Image.network(
              user.profileImageUrl!,
              fit: BoxFit.cover,
              width: radius * 2,
              height: radius * 2,
              errorBuilder: (_, __, ___) => _buildFallbackText(user),
            ),
    );
  }

  Widget _buildFallbackText(User user) {
    return Text(
      user.name[0].toUpperCase(),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _ImagePreview({
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 16),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SendButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      width: 50,
      height: 50,
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                ),
              ),
            )
          : IconButton(
              icon: Icon(Icons.send_rounded,
                  color: AppColors.textPrimary, size: 20),
              onPressed: isLoading ? null : onPressed,
            ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading community posts...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to the Community!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Share your favorite recipes, cooking tips, and food discoveries with fellow food lovers.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary.withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildCreateFirstPostButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateFirstPostButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: AppColors.textPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Create First Post',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostsList extends StatelessWidget {
  final List<Post> posts;
  final String? showingCommentsForPost;
  final TextEditingController commentController;
  final Function(Post) onToggleLike;
  final Function(Post) onDeletePost;
  final Function(Post, String) onAddComment;
  final Function(String) onToggleComments;

  const _PostsList({
    required this.posts,
    required this.showingCommentsForPost,
    required this.commentController,
    required this.onToggleLike,
    required this.onDeletePost,
    required this.onAddComment,
    required this.onToggleComments,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: posts.length,
      itemBuilder: (context, index) => _PostCard(
        post: posts[index],
        isShowingComments: showingCommentsForPost == posts[index].id,
        commentController: commentController,
        onToggleLike: onToggleLike,
        onDeletePost: onDeletePost,
        onAddComment: onAddComment,
        onToggleComments: onToggleComments,
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final bool isShowingComments;
  final TextEditingController commentController;
  final Function(Post) onToggleLike;
  final Function(Post) onDeletePost;
  final Function(Post, String) onAddComment;
  final Function(String) onToggleComments;

  const _PostCard({
    required this.post,
    required this.isShowingComments,
    required this.commentController,
    required this.onToggleLike,
    required this.onDeletePost,
    required this.onAddComment,
    required this.onToggleComments,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = UserSessionService.getCurrentUser();
    final isOwnPost = currentUser != null && currentUser.id == post.userId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isOwnPost),
          if (post.content.isNotEmpty) _buildContent(),
          if (post.image != null) _buildImage(),
          _buildActions(currentUser),
          if (post.comments.isNotEmpty) _buildComments(),
          if (isShowingComments) _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isOwnPost) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          _UserAvatar(
            radius: 22,
            fontSize: 18,
            user: User(
              id: post.userId,
              name: post.userName,
              email: '',
              profileImageUrl: post.userProfileUrl,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getTimeAgo(post.createdAt),
                  style: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (isOwnPost) _buildOptionsMenu(),
        ],
      ),
    );
  }

  Widget _buildOptionsMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'delete') onDeletePost(post);
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Delete Post', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      icon: Icon(
        Icons.more_vert,
        color: AppColors.textPrimary.withOpacity(0.6),
        size: 20,
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Text(
        post.content,
        style: TextStyle(
          fontSize: 16,
          height: 1.4,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = post.image;
    if (imageUrl == null) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imageUrl,
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 250,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 60, color: Colors.grey[600]),
                const SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(User? currentUser) {
    final isLiked = currentUser != null && post.isLikedByUser(currentUser.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          _ActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            count: post.likes,
            color: isLiked ? Colors.red : Colors.grey[600]!,
            backgroundColor: isLiked
                ? Colors.red.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            onTap: () => onToggleLike(post),
          ),
          const SizedBox(width: 12),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            count: post.comments.length,
            color: Colors.grey[600]!,
            backgroundColor: Colors.grey.withOpacity(0.1),
            onTap: () => onToggleComments(post.id),
          ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: post.comments.map(_buildComment).toList(),
      ),
    );
  }

  Widget _buildComment(PostComment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserAvatar(
            radius: 14,
            fontSize: 12,
            user: User(
              id: comment.userId,
              name: comment.userName,
              email: '',
              profileImageUrl: comment.userProfileUrl,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeAgo(comment.createdAt),
                      style: TextStyle(
                        color: AppColors.textPrimary.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const _UserAvatar(radius: 16, fontSize: 14),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: commentController,
              decoration:
                  _inputDecoration('Write a comment...', borderRadius: 20),
              style: TextStyle(color: AppColors.textPrimary),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  onAddComment(post, value);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: AppColors.primary),
            onPressed: () {
              if (commentController.text.trim().isNotEmpty) {
                onAddComment(post, commentController.text);
              }
            },
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.count,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Functions
BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.08),
        spreadRadius: 0,
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(
      color: AppColors.primary.withOpacity(0.05),
      width: 1,
    ),
  );
}

InputDecoration _inputDecoration(String hint, {required double borderRadius}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AppColors.textPrimary.withOpacity(0.5)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: AppColors.primary),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: AppColors.primary),
    ),
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}
