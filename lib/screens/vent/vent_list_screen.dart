import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ethioconfess/screens/vent/create_vent_screen.dart';
import '../../utils/auth_utils.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/vent_widget/vent_grid.dart';
import '../../providers/vent_provider.dart';
import '../../providers/category_provider.dart';

class VentListScreen extends ConsumerStatefulWidget {
  const VentListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VentListScreen> createState() => _VentListScreenState();
}

class _VentListScreenState extends ConsumerState<VentListScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String? _currentCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    
    try {
      // First, load categories
      await ref.read(categoryProvider.notifier).fetchCategories();
      final categories = ref.read(categoryProvider).categories;
      
      if (categories.isNotEmpty && mounted) {
        setState(() {
          _tabController = TabController(length: categories.length + 1, vsync: this);
          _currentCategoryId = null; // Start with "All" tab
        });
        _tabController?.addListener(_handleTabIndexChange);
        
        // Now explicitly load all vents for the initial "All" tab
        await ref.read(ventProvider(null).notifier).loadAllVents();
      }
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  void _handleTabIndexChange() {
    if (_tabController == null || !_tabController!.indexIsChanging) return;
    
    final categories = ref.read(categoryProvider).categories;
    final newCategoryId = _tabController!.index == 0 
        ? null 
        : categories[_tabController!.index - 1].id;
        
    if (_currentCategoryId != newCategoryId) {
      setState(() {
        _currentCategoryId = newCategoryId;
      });
      
      // Explicitly load vents for the selected category
      if (newCategoryId == null) {
        ref.read(ventProvider(null).notifier).loadAllVents();
      } else {
        ref.read(ventProvider(newCategoryId).notifier).loadVentsByCategory(newCategoryId);
      }
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabIndexChange);
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (!mounted) return;
    
    await ref.read(categoryProvider.notifier).fetchCategories();
    final categories = ref.read(categoryProvider).categories;
    
    if (categories.isNotEmpty) {
      if (_tabController?.length != categories.length + 1) {
        _tabController?.removeListener(_handleTabIndexChange);
        _tabController?.dispose();
        setState(() {
          _tabController = TabController(length: categories.length + 1, vsync: this);
        });
        _tabController?.addListener(_handleTabIndexChange);
      }
      
      // Invalidate the current category's provider to force a refresh
      ref.invalidate(ventProvider(_currentCategoryId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);

    if (categoryState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(
          color: Color(0xFF4169E1),
        )),
      );
    }

    if (categoryState.error != null) {
      return Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                AppErrorWidget(
                  message: 'Couldn\'t load categories',
                  subtitle: 'Something went wrong. Please try again.',
                  onRetry: _handleRefresh,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (categoryState.categories.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No categories available'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleRefresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(
          color: Color(0xFF4169E1),
        )),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Vents',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await handleProtectedAction(
            context,
            action: ProtectedAction.create,
            message: 'Please sign in to create a vent',
          )) {
            // Get the current category based on actual tab controller index
            String? preSelectedCategoryId;
            if (_tabController != null) {
              final currentIndex = _tabController!.index;
              final categories = ref.read(categoryProvider).categories;
              
              if (currentIndex == 0) {
                // "All" tab - no category pre-selected
                preSelectedCategoryId = null;
              } else if (currentIndex > 0 && currentIndex <= categories.length) {
                // Category tab - pre-select the current category
                preSelectedCategoryId = categories[currentIndex - 1].id;
              }
            }
            
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => CreateVentScreen(
                  preSelectedCategoryId: preSelectedCategoryId,
                ),
              ),
            );
            
            if (result == true && mounted) {
              // Force a network refresh on both providers
              await ref.read(ventProvider(_currentCategoryId).notifier).refresh();
              await ref.read(ventProvider(null).notifier).refresh();
              setState(() {}); // Trigger rebuild
            }
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
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            // CreateVentButton(
            //   onPressed: () async {
            //     if (await handleProtectedAction(
            //       context,
            //       action: ProtectedAction.create,
            //       message: 'Please sign in to create a vent',
            //     )) {
            //       final result = await Navigator.push<bool>(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => const CreateVentScreen(),
            //         ),
            //       );
                  
            //       if (result == true && mounted) {
            //         // Force a network refresh on both providers
            //         await ref.read(ventProvider(_currentCategoryId).notifier).refresh();
            //         await ref.read(ventProvider(null).notifier).refresh();
            //         setState(() {}); // Trigger rebuild
            //       }
            //     }
            //   },
            // ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: const Color(0xFF4169E1),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF4169E1),
                dividerColor: const Color.fromARGB(255, 203, 214, 249),
                indicatorWeight: 3,
                tabAlignment: TabAlignment.start,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                tabs: [
                  const Tab(text: 'All'),
                  ...categoryState.categories
                      .map((category) => Tab(text: category.categoryName))
                      .toList(),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: VentGrid(key: const ValueKey('all'), categoryId: null),
                  ),
                  
                  ...categoryState.categories.map((category) => 
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: VentGrid(key: ValueKey(category.id), categoryId: category.id),
                    )
                  ).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
