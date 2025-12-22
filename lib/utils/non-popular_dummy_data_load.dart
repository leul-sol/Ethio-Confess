import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:metsnagna/models/popular_entity.dart';

Future<List<PopularEntity>> loadnonPopularDummyData() async {
  final String jsonString =
      await rootBundle.loadString('assets/dummy_non_popular_data.json');
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((json) => PopularEntity.fromJson(json)).toList();
}
