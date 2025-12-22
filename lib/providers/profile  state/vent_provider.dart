// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:metsnagna/models/popular_entity.dart';
// import 'package:metsnagna/graphql/graphql_client.dart';
// import 'package:metsnagna/utils/biography_queries.dart';
// import 'vent_state.dart';

// final ventProvider = StateNotifierProvider<VentNotifier, VentState>(
//   (ref) => VentNotifier(),
// );

// class VentNotifier extends StateNotifier<VentState> {
//   VentNotifier() : super(const VentState.initial());

//   final GraphQLClient _graphqlClient = graphqlClient();

//   Future<void> fetchVents(String userId) async {
//     state = const VentState.loading();

//     try {
//       final QueryOptions options = QueryOptions(
//         document: gql(ventPostsQuery),
//         variables: {'userid': userId},
//       );

//       final result = await _graphqlClient.query(options);

//       if (result.hasException) {
//         throw Exception(result.exception.toString());
//       }

//       final vents = (result.data?['vent'] as List)
//           .map((ventJson) => VentEntity.fromJson(ventJson))
//           .toList();

//       state = VentState.loaded(vents);
//     } catch (e) {
//       state = VentState.error(e.toString());
//     }
//   }
// }
