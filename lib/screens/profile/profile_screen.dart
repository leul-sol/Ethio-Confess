import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:metsnagna/providers/biography_providers.dart';
import 'package:metsnagna/screens/profile/edit_content_screen.dart';
// import 'package:metsnagna/services/biography_page_services.dart';
// import '../../models/category_enum.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/time_duration.dart';
import '../../models/popular_entity.dart';
import 'package:shimmer/shimmer.dart';
import 'package:metsnagna/screens/biography/biography_detail_page.dart';
import 'package:metsnagna/screens/vent/vent_detail_screen.dart';

import 'edit_profile_screen.dart';
import 'update_password_screen.dart';
import 'settings_screen.dart';

import '../../utils/avatar_utils.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onLogout;
  const ProfileScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? userId;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh biographies when coming back to this screen
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is bool && args) {
      _refreshBiographies(); // Call to refresh biographies if a new one was created
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      final shouldLogout = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (context) => AlertDialog(
          title: const Text('Confirm Logout'),
          content:
              const Text('Are you sure you want to log out of your account?'),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
              ),
              child: const Text('CANCEL'),
            ),
            // Logout Button
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('LOGOUT'),
            ),
          ],
        ),
      );

      if (shouldLogout == true && context.mounted) {
        // Perform logout
        await ref.read(authStateProvider.notifier).logout(context);
        // Only after logout completes, call onLogout to reset ProviderScope
        if (widget.onLogout != null) {
          widget.onLogout!();
        }
      }
    } catch (e) {
      if (context.mounted) {
        // Show error message if logout fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to logout. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadUserId() async {
    final token = await _storageService.getToken();
    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      final hasuraClaims = decodedToken['https://hasura.io/jwt/claims'];
      if (hasuraClaims != null) {
        setState(() {
          userId = hasuraClaims['x-hasura-user-id'];
          print('Loaded User ID: $userId');
        });
      }
    }
  }

  Future<void> _showDeleteConfirmation(Future<void> Function() onDelete) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
            ),
            child: const Text('CANCEL'),
          ),
          // Delete Button
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await onDelete(); // Call the delete function if confirmed
      ref.invalidate(userVentsProvider(userId!));
      ref.invalidate(userBiographiesProvider(
          userId!)); // Invalidate the provider to refresh the list
    }
  }

  // Future<void> _refreshAll() async {
  //   if (userId == null) return;

  //   // Invalidate all providers to force refresh
  //   ref.invalidate(userProfileProvider(userId!));
  //   ref.invalidate(userVentsProvider(userId!));
  //   ref.invalidate(userBiographiesProvider(userId!));

  //   // Wait for all data to refresh
  //   await Future.wait([
  //     ref.read(userProfileProvider(userId!).future),
  //     ref.read(userVentsProvider(userId!).future),
  //     ref.read(userBiographiesProvider(userId!).future),
  //   ]);
  // }

  Future<void> _refreshBiographies() async {
    if (userId != null) {
      ref.invalidate(userBiographiesProvider(
          userId!)); // Invalidate the provider to refresh the list
    }
  }

  Future<void> _refreshVents() async {
    if (userId != null) {
      ref.invalidate(userVentsProvider(
          userId!)); // Invalidate the provider to refresh the list
    }
  }

  // Helper method for styled action buttons
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(6),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Shimmer for profile picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 16),
          // Shimmer for username
          Container(
            width: 150,
            height: 24, // Adjusted height to match actual text size
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            // color: Colors.white,
          ),
          const SizedBox(height: 8),
          // Shimmer for email
          Container(
            width: 120,
            height: 20, // Adjusted height to match actual text size
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 100),
          // Shimmer for action buttons  const SizedBox(height: 20),
          // Shimmer for tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            height: 55, // Match the actual height of the tabs
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100, // Adjust width as needed
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Container(
                  width: 100, // Adjust width as needed
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 20), // Space before the content area
          // Shimmer for content area (biographies and vents)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with settings
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.settings_outlined, size: 28, color: Colors.grey[600]),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 28, color: Colors.red),
                    onPressed: () => _handleLogout(context, ref),
                  ),
                ],
              ),
            ),

            // Profile info
            Consumer(
              builder: (context, ref, child) {
                final userProfileAsync =
                    ref.watch(userProfileProvider(userId!));
                print('=== PROFILE SCREEN DEBUG ===');
                print('UserProfileAsync: $userProfileAsync');
                if (userProfileAsync.hasValue) {
                  final userData = userProfileAsync.value;
                  print('Username: ${userData?['username']}');
                  print('Email: ${userData?['email']}');
                  print('Profile Image: ${userData?['profile_image'] ?? 'null'}');
                }
                print('=== PROFILE SCREEN DEBUG END ===');
                return userProfileAsync.when(
                    data: (userProfile) => _buildProfileContent(userProfile),
                    // data: (userProfile) => _buildShimmerLoading(),
                    loading: () => _buildShimmerLoading(),
                    error: (error, stack) {
                      // Log the error for debugging
                      print('Error loading profile: $error');
                      return Center(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(userProfileProvider(userId!));
                          },
                          child: ListView(
                            // Use ListView to make it scrollable for RefreshIndicator
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      size: 64,
                                      color: Color(0xFF4169E1),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Oops! Something went wrong',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Pull down to refresh and try again',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.black38,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    // Optional: Display the error details in debug mode
                                    // if (kDebugMode) Text(error.toString()),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
              },
            ),

            const SizedBox(height: 20),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // First tab: Vents
                  Consumer(
                    builder: (context, ref, child) {
                      final ventsAsync = ref.watch(userVentsProvider(userId!));
                      print('Vent Provider State: ${ventsAsync.runtimeType}');
                      return RefreshIndicator(
                        onRefresh: () async {
                          await _refreshVents(); // Call the refresh function
                        },
                        child: ventsAsync.when(
                          data: (vents) {
                            print('Vents loaded: ${vents.length} items');
                            if (vents.isEmpty) {
                              // Wrap empty state in a scrollable view
                              return CustomScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  SliverFillRemaining(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No Vents Yet',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Share your thoughts and experiences\nwith the community',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: vents.length,
                              itemBuilder: (context, index) {
                                final vent = vents[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VentDetailScreen(
                                          ventId: vent.id.toString(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 24.0),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.format_quote_rounded,
                                          size: 32,
                                          color: Colors.black26,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          vent.content ?? '',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.5,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              timeAgo(vent.createdAt ?? DateTime.now()),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                _buildActionButton(
                                                  icon: Icons.edit_outlined,
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => EditContentScreen(
                                                          initialContent: vent.content ?? '',
                                                          onUpdate: (newContent) async {
                                                            await ref.read(updateVentProvider({
                                                              'id': vent.id,
                                                              'content': newContent,
                                                            }).future);
                                                            ref.invalidate(userVentsProvider(userId!));
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  color: Color(0xFF4169E1),
                                                  tooltip: 'Edit',
                                                ),
                                                _buildActionButton(
                                                  icon: Icons.delete,
                                                  onPressed: () =>
                                                      _showDeleteConfirmation(() async {
                                                    await ref.read(userVentsProvider(userId!).notifier).deleteVent(vent.id!);
                                                  }),
                                                  color: Colors.red,
                                                  tooltip: 'Delete',
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => _buildShimmerVentCard(),
                          error: (error, stack) =>
                              // Wrap error state in a scrollable view
                              RefreshIndicator(
                                onRefresh: _refreshVents,
                                child: ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.error_outline_rounded,
                                              size: 48,
                                              color: Color(0xFF4169E1),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Unable to load vents',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Pull down to refresh the page',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Colors.black54,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      );
                    },
                  ),
                  // Second tab: Biographies
                  Consumer(
                    builder: (context, ref, child) {
                      final biographiesAsync = ref.watch(userBiographiesProvider(userId!));
                      print('Biography Provider State: ${biographiesAsync.runtimeType}');
                      return RefreshIndicator(
                        onRefresh: () async {
                          await _refreshBiographies(); // Call the refresh function
                        },
                        child: biographiesAsync.when(
                          data: (biographies) {
                            print('Biographies loaded: ${biographies.length} items');
                            if (biographies.isEmpty) {
                              // Wrap empty state in a scrollable view
                              return CustomScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  SliverFillRemaining(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.book_outlined,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No Biographies Yet',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Start sharing your life stories\nand inspire others',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return CustomScrollView(
                              slivers: [
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final biography = biographies[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => BiographyDetailPage(
                                                entity: PopularEntity(
                                                  id: biography['id'],
                                                  content: biography['content'],
                                                  username: biography['user']['username'],
                                                  createdAt: biography['created_at'],
                                                  likeCount: biography['biographylikes_aggregate']
                                                      ['aggregate']['count'],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 24.0, left: 16, right: 16),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 12,
                                                spreadRadius: 1,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.format_quote_rounded,
                                                size: 32,
                                                color: Colors.black26,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                biography['content'],
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  height: 1.5,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        timeAgo(DateTime.parse(
                                                            biography['created_at'])),
                                                        style: TextStyle(
                                                          color: Colors.grey.shade600,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade100,
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.favorite,
                                                              color: Colors.red.shade400,
                                                              size: 16,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              '${biography['biographylikes_aggregate']['aggregate']['count']}',
                                                              style: const TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      _buildActionButton(
                                                        icon: Icons.edit_outlined,
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  EditContentScreen(
                                                                initialContent:
                                                                    biography['content'],
                                                                onUpdate: (newContent) async {
                                                                  await ref.read(
                                                                      updateBiographyProvider({
                                                                    'id': biography['id'],
                                                                    'content': newContent,
                                                                  }).future);

                                                                  ref.invalidate(
                                                                      userBiographiesProvider(
                                                                          userId!));
                                                                  ref.invalidate(allbiographyProvider);
                                                                  await ref.read(allbiographyProvider.notifier).loadBiographies();
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        color: Color(0xFF4169E1),
                                                        tooltip: 'Edit',
                                                      ),
                                                      _buildActionButton(
                                                        icon: Icons.delete,
                                                        onPressed: () =>
                                                            _showDeleteConfirmation(() async {
                                                          final success = await ref.read(
                                                              deleteBiographyProvider(
                                                                      biography['id'])
                                                                  .future);
                                                          if (!success) {
                                                            throw Exception(
                                                                'Failed to delete biography');
                                                          }
                                                          // Invalidate and refetch the global list
                                                          ref.invalidate(allbiographyProvider);
                                                          await ref.read(allbiographyProvider.notifier).loadBiographies();
                                                        }),
                                                        color: Colors.red,
                                                        tooltip: 'Delete',
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: biographies.length,
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => _buildShimmerBiographyCard(),
                          error: (error, stack) =>
                              // Wrap error state in a scrollable view
                              RefreshIndicator(
                                onRefresh: _refreshBiographies,
                                child: ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.error_outline_rounded,
                                              size: 48,
                                              color: Color(0xFF4169E1),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Unable to load biographies',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Pull down to refresh the page',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Colors.black54,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final ventsAsync = ref.watch(userVentsProvider(userId!));
                      print('Vent Provider State: ${ventsAsync.runtimeType}');
                      return RefreshIndicator(
                        onRefresh: () async {
                          await _refreshVents(); // Call the refresh function
                        },
                        child: ventsAsync.when(
                          data: (vents) {
                            print('Vents loaded: ${vents.length} items');
                            if (vents.isEmpty) {
                              // Wrap empty state in a scrollable view
                              return CustomScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  SliverFillRemaining(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No Vents Yet',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Share your thoughts and experiences\nwith the community',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: vents.length,
                              itemBuilder: (context, index) {
                                final vent = vents[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VentDetailScreen(
                                          ventId: vent.id.toString(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 24.0),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.format_quote_rounded,
                                          size: 32,
                                          color: Colors.black26,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          vent.content ?? '',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.5,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              timeAgo(vent.createdAt ?? DateTime.now()),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                _buildActionButton(
                                                  icon: Icons.edit_outlined,
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => EditContentScreen(
                                                          initialContent: vent.content ?? '',
                                                          onUpdate: (newContent) async {
                                                            await ref.read(updateVentProvider({
                                                              'id': vent.id,
                                                              'content': newContent,
                                                            }).future);
                                                            ref.invalidate(userVentsProvider(userId!));
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  color: Color(0xFF4169E1),
                                                  tooltip: 'Edit',
                                                ),
                                                _buildActionButton(
                                                  icon: Icons.delete,
                                                  onPressed: () =>
                                                      _showDeleteConfirmation(() async {
                                                    await ref.read(userVentsProvider(userId!).notifier).deleteVent(vent.id!);
                                                  }),
                                                  color: Colors.red,
                                                  tooltip: 'Delete',
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => _buildShimmerVentCard(),
                          error: (error, stack) =>
                              // Wrap error state in a scrollable view
                              RefreshIndicator(
                                onRefresh: _refreshVents,
                                child: ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.error_outline_rounded,
                                              size: 48,
                                              color: Color(0xFF4169E1),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Unable to load vents',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Pull down to refresh the page',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Colors.black54,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> userProfile) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color.fromARGB(255, 153, 174, 239),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AvatarUtils.getProfileImage(userProfile['profile_image']),
              backgroundColor: userProfile['profile_image'] == null || userProfile['profile_image'].toString().isEmpty
                  ? Color(0xFF4169E1)
                  : null,
              child: (userProfile['profile_image'] == null || userProfile['profile_image'].toString().isEmpty)
                  ? Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            userProfile['username'] ?? 'Unknown User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userProfile['email'] ?? 'No email',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 20),

          // Edit Profile Text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Add your edit profile navigation here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(),
                    ),
                  );
                },
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF4169E1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "|",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  // Add your edit profile navigation here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdatePasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  'Update Password',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF4169E1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tabs
          Container(
            width: MediaQuery.of(context).size.width - 30,
            height: 55, // Fixed height to match design
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(6), // Smaller padding
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Color(0xFF4169E1),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Vents'),
                Tab(text: 'Biographies'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBiographyCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            height: 120, // Match the actual height of the tabs
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100, // Adjust width as needed
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Container(
                  width: 100, // Adjust width as needed
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20), // Space before the content area
          // Shimmer for content area (biographies and vents)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            height: 150, // Match the actual height of the tabs
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100, // Adjust width as needed
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Container(
                  width: 100, // Adjust width as needed
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerVentCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3, // Number of shimmer items to show
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 24.0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 100,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
