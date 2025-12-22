import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BiographyShimmerEffects {
  static Widget buildTopShimmer() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        padding: const EdgeInsets.only(right: 10),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 150,
              width: 300,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
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

  static Widget buildListShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        final cardWidth = MediaQuery.of(context).size.width - 16;
        return Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[100]!,
          child: SizedBox(
            width: cardWidth,
            child: Container(
              height: 160,
              margin: const EdgeInsets.only(bottom: 24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget buildTabBarShimmer() {
    return SizedBox(
      height: 48,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (index) => Container(
              width: 120,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 