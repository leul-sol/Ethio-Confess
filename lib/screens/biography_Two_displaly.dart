// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ethioconfess/providers/biography_providers.dart';
// import 'package:ethioconfess/screens/add_biography_page.dart';
// import 'package:ethioconfess/services/biography_page_services.dart';
// import 'package:ethioconfess/widgets/biography_two_widget.dart';

// import 'profile_screen.dart';

// class BiographyTwoDisplay extends ConsumerStatefulWidget {
//   @override
//   ConsumerState<BiographyTwoDisplay> createState() =>
//       _BiographyTwoDisplayState();
// }

// class _BiographyTwoDisplayState extends ConsumerState<BiographyTwoDisplay> {
//   int _selectedIndex = 0;
//   Category _selectedCategory = Category.Family;
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: _selectedIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   Future<void> _onRefresh(Category category) async {
//     // Invalidate the providers to force a refresh
//     ref.invalidate(biographyProvider(category));
//     ref.invalidate(fetchTopLikedBiographiesProvider);

//     // Wait for the new data to load
//     await Future.wait([
//       ref.read(biographyProvider(category).future),
//       ref.read(fetchTopLikedBiographiesProvider.future),
//     ]);
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//       _updateCategory(index);
//     });
//     // Animate to the selected page
//     _pageController.animateToPage(
//       index,
//       duration: Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   void _updateCategory(int index) {
//     switch (index) {
//       case 0:
//         _selectedCategory = Category.Family;
//         break;
//       case 1:
//         _selectedCategory = Category.Relationship;
//         break;
//       case 2:
//         _selectedCategory = Category.Health;
//         break;
//     }
//   }

//   void _onPageChanged(int index) {
//     setState(() {
//       _selectedIndex = index;
//       _updateCategory(index);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: GestureDetector(
//           onTap: () {
//             Navigator.push(
//                 context, MaterialPageRoute(builder: (context) => ProfileScreen()));
//           },
//           child: Image(image: AssetImage('assets/Frame.png')),
//         ),
//         actions: [
//           Row(
//             children: [
//               IconButton(
//                 icon: Icon(Icons.notifications),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: Icon(Icons.star),
//                 onPressed: () {},
//               ),
//             ],
//           )
//         ],
//       ),
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: _onPageChanged,
//         children: [
//           _buildCategoryPage(Category.Family),
//           _buildCategoryPage(Category.Relationship),
//           _buildCategoryPage(Category.Health),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => PostScreen()),
//           );
//         },
//         child: Icon(Icons.add),
//         foregroundColor: Colors.white,
//         backgroundColor: Colors.blue[400],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Color(0xFFFFF0F0),
//         selectedItemColor: Colors.blue[400],
//         unselectedItemColor: Colors.grey,
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.people_alt_outlined),
//             activeIcon: Icon(Icons.people_alt),
//             label: 'Family',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.favorite_outline),
//             activeIcon: Icon(Icons.favorite),
//             label: 'Relationship',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.health_and_safety_outlined),
//             activeIcon: Icon(Icons.health_and_safety),
//             label: 'Health',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryPage(Category category) {
//     final biographiesAsync = ref.watch(biographyProvider(category));
//     final topBiographiesAsync = ref.watch(fetchTopLikedBiographiesProvider);

//     return RefreshIndicator(
//       onRefresh: () => _onRefresh(category),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 20),
//             Expanded(
//               child: biographiesAsync.when(
//                 loading: () => Center(child: CircularProgressIndicator()),
//                 error: (error, stack) => SingleChildScrollView(
//                   physics: AlwaysScrollableScrollPhysics(),
//                   child: Center(
//                     child: Text(
//                       'Connection Error, please restore your connection and try again',
//                     ),
//                   ),
//                 ),
//                 data: (biographies) {
//                   if (biographies.isEmpty) {
//                     return SingleChildScrollView(
//                       physics: AlwaysScrollableScrollPhysics(),
//                       child: Center(child: Text('No data available')),
//                     );
//                   }

//                   return SingleChildScrollView(
//                     physics: AlwaysScrollableScrollPhysics(),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Challenge Container
//                         Container(
//                           height: 130,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20),
//                             gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [Colors.yellow[100]!, Colors.white],
//                             ),
//                             border: Border.all(
//                               color: Colors.grey[300]!,
//                               width: 0.5,
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               SizedBox(width: 10),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     SizedBox(height: 13),
//                                     Text('Daily Happiness Challenge'),
//                                     SizedBox(height: 10),
//                                     Text(
//                                       'Record your journey',
//                                       style: TextStyle(
//                                         fontSize: 17,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     SizedBox(height: 8),
//                                     ElevatedButton(
//                                       onPressed: () {},
//                                       style: ElevatedButton.styleFrom(
//                                         fixedSize: Size(150, 30),
//                                         backgroundColor: Colors.red[400],
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(30),
//                                         ),
//                                       ),
//                                       child: Text(
//                                         'Write a story..',
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Image(
//                                 image: AssetImage('assets/Frame.png'),
//                                 width: 100,
//                                 height: 100,
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         // Biographies List
//                         ...biographies.map((biography) => Padding(
//                               padding: EdgeInsets.only(bottom: 10),
//                               child: BiographyTwoWidget(entity: biography),
//                             )),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
