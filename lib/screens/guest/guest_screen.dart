import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:ethioconfess/screens/auth/signin_screen.dart';
import 'package:ethioconfess/screens/vent/vent_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/popular_entity.dart';
import '../../providers/biography_providers.dart';
import '../../providers/vent_provider.dart';
import '../../models/vent.dart';
import '../biography/biography_detail_page.dart';
import '../../utils/avatar_utils.dart';
import 'package:shimmer/shimmer.dart';

class GuestScreen extends ConsumerStatefulWidget {
  const GuestScreen({super.key});

  @override
  ConsumerState<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends ConsumerState<GuestScreen> {
  // ignore: unused_field
  bool _isLoading = false;
  String? _errorMessage;

  // Helper function to trim text
  String trimText(String text, {int maxLength = 100}) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  Future<void> _refreshAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(ventProvider(null).notifier).refresh();
      await ref.read(allbiographyProvider.notifier).loadBiographies();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to refresh data. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ventAsyncValue = ref.watch(ventProvider(null));
    final allBiographiesAsyncValue = ref.watch(allbiographyProvider);

    return WillPopScope(
      onWillPop: () async {
        // If this is the root route, exit the app instead of revealing any transient states
        if (!Navigator.of(context).canPop()) {
          SystemNavigator.pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
      body: _errorMessage != null
          ? _buildErrorScreen()
          : RefreshIndicator(
              onRefresh: _refreshAllData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    title: Row(
                      children: [
                        Image.asset(
                          'assets/logo/metsnagna_logo.png',
                          width: 56,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Vent Ethiopia',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SigninScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Biography Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Explore Biography',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4169E1),
                            ),
                          ),
                          const SizedBox(height: 16),
                          allBiographiesAsyncValue.when(
                            data: (biographies) {
                              if (biographies.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No biographies available',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              }
                              return SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: biographies.length,
                                  itemBuilder: (context, index) {
                                    final bio = biographies[index];
                                    return InkWell(
                                      onTap: () {
                                        final entity = PopularEntity(
                                          id: bio.id,
                                          content: bio.content,
                                          category: bio.category,
                                          createdAt: bio.createdAt,
                                          username: bio.username,
                                          likeCount: bio.likeCount,
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BiographyDetailPage(
                                              entity: entity,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 300,
                                        margin: const EdgeInsets.only(right: 16),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE8F1FF),
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(12),
                                            bottomRight: Radius.circular(12),
                                          ),
                                          border: Border(
                                            left: BorderSide(
                                              color: Color(0xFF2D6BEF),
                                              width: 4,
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage: AvatarUtils.getProfileImage(bio.profileImage),
                                                    backgroundColor: Colors.grey.shade200,
                                                    child: AvatarUtils.getProfileImage(bio.profileImage) == null
                                                        ? const Icon(
                                                            Icons.person,
                                                            size: 20,
                                                            color: Colors.grey,
                                                          )
                                                        : null,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Expanded(
                                                child: Text(
                                                  bio.content,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  const Icon(
                                                    Icons.favorite,
                                                    size: 16,
                                                    color: Colors.red,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${bio.likeCount}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            loading: () => _buildShimmerEffect(),
                            error: (_, __) => _buildShimmerEffect(),
                          ),
                          const SizedBox(height: 36),
                          const Text(
                            'Recent Vents',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4169E1),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Vents List
                  ventAsyncValue.when(
                    data: (vents) {
                      if (vents.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'No vents available',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final Vent vent = vents[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VentDetailScreen(
                                        ventId: vent.id ?? '',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(20),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundImage: AvatarUtils.getProfileImage(vent.user?.profile_image),
                                          backgroundColor: Colors.grey.shade200,
                                          child: AvatarUtils.getProfileImage(vent.user?.profile_image) == null
                                              ? const Icon(
                                                  Icons.person,
                                                  size: 16,
                                                  color: Colors.grey,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          constraints: const BoxConstraints(
                                            maxHeight: 63,
                                          ),
                                          child: Text(
                                            trimText(vent.content ?? 'No content available'),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              timeago.format(vent.updatedAt ?? DateTime.now()),
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.repeat, size: 16, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  vent.replyCount.toString(),
                                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: vents.length,
                        ),
                      );
                    },
                    loading: () => SliverToBoxAdapter(
                      child: _buildShimmerEffectForVents(),
                    ),
                    error: (error, stackTrace) {
                      setState(() {
                        _errorMessage = 'Failed to load vents. Please try again.';
                      });
                      return SliverToBoxAdapter(
                        child: _buildShimmerEffectForVents(),
                      );
                    },
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return RefreshIndicator(
      onRefresh: _refreshAllData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/no-results.png",
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _errorMessage ?? 'Something went wrong',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pull down to refresh',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 300,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerEffectForVents() {
    return SizedBox(
      height: 600,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        scrollDirection: Axis.vertical,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              height: 120,
            ),
          );
        },
      ),
    );
  }
}
