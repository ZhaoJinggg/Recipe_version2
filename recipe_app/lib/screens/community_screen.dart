import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/models/post.dart';
import 'package:recipe_app/models/user.dart';
import 'package:recipe_app/services/mock_data_service.dart';
import 'package:recipe_app/services/user_session_service.dart';
import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/widgets/custom_bottom_nav_bar.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<Post> _posts = [];
  final _postController = TextEditingController();
  final int _currentNavIndex = 4; // Community tab
  bool _isLoading = true;
  final Set<String> _recentPostContents = <String>{};

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('📥 Loading posts from Firebase database...');
      final posts = await FirebaseService.getAllPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
      print('✅ Loaded ${posts.length} posts from Firebase database');
    } catch (e) {
      print('❌ Error loading posts from Firebase: $e');
      // Fallback to mock data if Firebase fails
      print('📥 Falling back to mock data...');
      setState(() {
        _posts = MockDataService.getAllPosts();
        _isLoading = false;
      });
      print('✅ Loaded ${_posts.length} posts from mock data (fallback)');
    }
  }

  Future<void> _createPostsTable() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('🗄️ Creating posts table in database...');

      // First, ensure Firebase is initialized
      final firebaseInitialized = await FirebaseService.initialize();
      if (!firebaseInitialized) {
        throw Exception('Failed to initialize Firebase');
      }

      // Test connection
      final connectionTest = await FirebaseService.testConnection();
      if (!connectionTest) {
        throw Exception('Failed to connect to Firestore');
      }

      // Get mock posts from MockDataService
      final mockPosts = MockDataService.getAllPosts();
      print('📝 Found ${mockPosts.length} mock posts to save');

      // Save each post to Firebase (this will create the posts collection)
      for (int i = 0; i < mockPosts.length; i++) {
        final post = mockPosts[i];
        print('💾 Saving post ${i + 1}/${mockPosts.length}: ${post.userName}');

        final postId = await FirebaseService.createPost(post);
        if (postId != null) {
          print(
              '✅ Saved post: ${post.userName} - ${post.content.substring(0, 30)}... (ID: $postId)');
        } else {
          print('❌ Failed to save post: ${post.userName}');
        }
      }

      print('🎉 Posts table creation process completed!');

      // Reload posts from database after creation
      await _loadPosts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                    child:
                        Text('Posts table created and loaded from database!')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      print('❌ Error creating posts table: $e');
      print('Stack trace: ${StackTrace.current}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                    child: Text(
                        'Failed to create posts table. Check console for details.')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onNavBarTap(int index) {
    if (index != _currentNavIndex) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/');
          break;
        case 1:
          Navigator.pushNamed(context, '/search');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/favorites');
          break;
      }
    }
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isNotEmpty) {
      final postContent = _postController.text.trim();

      // Check for duplicate content
      if (_recentPostContents.contains(postContent)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                    child: Text(
                        'You recently posted this content. Please wait before posting again.')),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }

      final currentUser = UserSessionService.getCurrentUser();
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(child: Text('Please log in to create posts')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }

      try {
        final newPost = Post(
          id: '', // Firebase will generate this
          userId: currentUser.id,
          userName: currentUser.name,
          userProfileUrl: currentUser.profileImageUrl,
          content: postContent,
          image: null,
          createdAt: DateTime.now(),
          likes: 0,
          hasLiked: false,
          comments: [],
        );

        final postId = await FirebaseService.createPost(newPost);

        if (postId != null) {
          // Add to recent posts set to prevent duplicates
          _recentPostContents.add(postContent);

          // Remove from recent posts after 5 minutes
          Future.delayed(const Duration(minutes: 5), () {
            _recentPostContents.remove(postContent);
          });

          // Update the post with the generated ID
          final createdPost = newPost.copyWith(id: postId);

          setState(() {
            _posts = [createdPost, ..._posts];
            _postController.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Post created successfully!')),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                      child: Text('Failed to create post. Please try again.')),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      } catch (e) {
        print('❌ Error creating post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                    child: Text('Error creating post. Please try again.')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Community',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _createPostsTable,
            icon: const Icon(Icons.storage, color: AppColors.primary),
            tooltip: 'Create posts table in database',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCreatePostSection(),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildPostsList(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildCreatePostSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            radius: 20,
            child: () {
              final user = UserSessionService.getCurrentUser();
              if (user?.profileImageUrl != null) {
                if (user!.profileImageUrl!.startsWith('assets/')) {
                  return ClipOval(
                    child: Image.asset(
                      user.profileImageUrl!,
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                    ),
                  );
                } else {
                  return ClipOval(
                    child: Image.network(
                      user.profileImageUrl!,
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          user.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  );
                }
              }
              return Text(
                user?.name[0].toUpperCase() ?? 'G',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              );
            }(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: 'Share a recipe or cooking tip...',
                hintStyle:
                    TextStyle(color: AppColors.textPrimary.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide:
                      BorderSide(color: AppColors.primary.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: Icon(Icons.send, color: AppColors.textPrimary),
              onPressed: _createPost,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildPostsList() {
    return _posts.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];
              return _buildPostCard(post);
            },
          );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share something!',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  radius: 20,
                  child: post.userProfileUrl != null
                      ? (post.userProfileUrl!.startsWith('assets/')
                          ? ClipOval(
                              child: Image.asset(
                                post.userProfileUrl!,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    post.userName[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  );
                                },
                              ),
                            )
                          : ClipOval(
                              child: Image.network(
                                post.userProfileUrl!,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    post.userName[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  );
                                },
                              ),
                            ))
                      : Text(
                          post.userName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _getTimeAgo(post.createdAt),
                      style: TextStyle(
                        color: AppColors.textPrimary.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              post.content,
              style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
            ),
          ),
          if (post.image != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Image.network(
                post.image!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 60),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      post.hasLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.hasLiked ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.likes.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.comment_outlined, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      post.comments.length.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.share_outlined, color: Colors.grey),
              ],
            ),
          ),
          if (post.comments.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: post.comments.map((comment) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          radius: 14,
                          child: comment.userProfileUrl != null
                              ? (comment.userProfileUrl!.startsWith('assets/')
                                  ? ClipOval(
                                      child: Image.asset(
                                        comment.userProfileUrl!,
                                        fit: BoxFit.cover,
                                        width: 28,
                                        height: 28,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Text(
                                            comment.userName[0].toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : ClipOval(
                                      child: Image.network(
                                        comment.userProfileUrl!,
                                        fit: BoxFit.cover,
                                        width: 28,
                                        height: 28,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Text(
                                            comment.userName[0].toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          );
                                        },
                                      ),
                                    ))
                              : Text(
                                  comment.userName[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getTimeAgo(comment.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comment.content,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
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
