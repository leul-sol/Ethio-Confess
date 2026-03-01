import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:ethioconfess/models/category_model.dart';
import 'package:ethioconfess/providers/biography_providers.dart';
import 'package:ethioconfess/screens/biography/add_biography_page.dart';
// import 'package:ethioconfess/services/biography_page_services.dart';

import 'package:ethioconfess/widgets/app_error_widget.dart';
import 'components/biography_list_item.dart';
import 'components/error_screen.dart';
import 'components/header_delegates.dart';
import 'components/shimmer_effects.dart';
import 'components/top_biography_card.dart';

void main() {
  print('🚨🚨🚨 [BiographyDisplay] FILE LOADED! 🚨🚨🚨');
}

class BiographyDisplay extends ConsumerStatefulWidget {
  BiographyDisplay({super.key}) {
    print('🚨🚨🚨 [BiographyDisplay] CONSTRUCTOR CALLED! 🚨🚨🚨');
  }

  @override
  ConsumerState<BiographyDisplay> createState() => _BiographyDisplayState();
}

class _BiographyDisplayState extends ConsumerState<BiographyDisplay> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('🚨🚨🚨 [BiographyDisplay] INIT STATE CALLED! 🚨🚨🚨');
    // Schedule the initial data load for after the build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚨🚨🚨 [BiographyDisplay] POST FRAME CALLBACK CALLED! 🚨🚨🚨');
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    print('🚨🚨🚨 [BiographyDisplay] _loadInitialData CALLED! 🚨🚨🚨');
    if (!mounted) return;
    try {
      await _refreshTopBiographies();
    } catch (e) {
      print('🚨🚨🚨 [BiographyDisplay] Error in _loadInitialData: $e 🚨🚨🚨');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _refreshTopBiographies() async {
    print('🚨🚨🚨 [BiographyDisplay] _refreshTopBiographies CALLED! 🚨🚨🚨');
    ref.invalidate(fetchTopLikedBiographiesProvider);
  }

  @override
  Widget build(BuildContext context) {
    print('🚨🚨🚨 [BiographyDisplay] BUILD METHOD CALLED! 🚨🚨🚨');
    final topBiographies = ref.watch(fetchTopLikedBiographiesProvider);
    final allBiographies = ref.watch(allbiographyProvider);
    
    print('🚨🚨🚨 [BiographyDisplay] topBiographies state: ${topBiographies.runtimeType} 🚨🚨🚨');
    print('🚨🚨🚨 [BiographyDisplay] allBiographies state: ${allBiographies.runtimeType} 🚨🚨🚨');
    
    if (topBiographies.hasValue) {
      print('🚨🚨🚨 [BiographyDisplay] topBiographies has data: ${topBiographies.value?.length ?? 0} items 🚨🚨🚨');
    }
    if (allBiographies.hasValue) {
      print('🚨🚨🚨 [BiographyDisplay] allBiographies has data: ${allBiographies.value?.length ?? 0} items 🚨🚨🚨');
    }

    final bool showSingleEmptyState = allBiographies.hasValue &&
        (allBiographies.value ?? []).isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _errorMessage != null
          ? BiographyErrorScreen(
              errorMessage: _errorMessage ?? 'An error occurred',
              onRefresh: _loadInitialData,
            )
          : RefreshIndicator(
              onRefresh: _refreshAllData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverAppBar(
                    pinned: true,
                    floating: false,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    title: Text(
                      'Biographies',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (showSingleEmptyState) ...[
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildBiographiesEmptyState(context),
                    ),
                  ] else ...[
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: TopBiographyHeaderDelegate(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            topBiographies.when(
                              data: (biographies) {
                                if (biographies.isEmpty) {
                                  return const SizedBox(height: 24);
                                }
                                return Container(
                                  height: 170,
                                  color: Colors.white,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: biographies.length,
                                    itemBuilder: (context, index) {
                                      final bio = biographies[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                        ),
                                        child: TopBiographyCard(bio: bio),
                                      );
                                    },
                                  ),
                                );
                              },
                              loading: () => BiographyShimmerEffects.buildTopShimmer(),
                              error: (error, stack) {
                                print("Top biographies error: $error");
                                return BiographyShimmerEffects.buildTopShimmer();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: allBiographies.when(
                          data: (biographies) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: biographies.length,
                              itemBuilder: (context, index) {
                                return BiographyListItem(
                                  bio: biographies[index],
                                );
                              },
                            );
                          },
                          loading: () => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: BiographyShimmerEffects.buildListShimmer(),
                          ),
                          error: (error, stack) {
                            print("Biographies error: $error");
                            return AppErrorWidget(
                              message: 'Unable to load biographies',
                              onRetry: () async {
                                ref.invalidate(allbiographyProvider);
                                await ref.read(allbiographyProvider.notifier).loadBiographies();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostScreen()),
          );
          if (result == true) {
            ref.invalidate(allbiographyProvider);
            await Future.delayed(const Duration(milliseconds: 500));
            await ref.read(allbiographyProvider.notifier).loadBiographies();
            // Optionally, also refresh userBiographiesProvider if needed
            // ref.invalidate(userBiographiesProvider(userId));
          }
        },
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF4169E1),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }

  Widget _buildBiographiesEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
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
              'No biographies yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    letterSpacing: -0.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Share your life stories and inspire others. Tap the + button to post your first biography.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.45,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshAllData() async {
    print('🚨🚨🚨 [BiographyDisplay] _refreshAllData CALLED! 🚨🚨🚨');
    if (!mounted) return;
    try {
      // Refresh top biographies
      ref.invalidate(fetchTopLikedBiographiesProvider);
      // Refresh all biographies
      ref.invalidate(allbiographyProvider);
    } catch (e) {
      print('🚨🚨🚨 [BiographyDisplay] Error in _refreshAllData: $e 🚨🚨🚨');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }
}