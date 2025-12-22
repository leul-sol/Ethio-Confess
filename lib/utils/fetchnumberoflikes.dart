// import 'package:flutter/material.dart';
// import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:ethioconfess/utils/biography_queries.dart';

// Future<int> fetchLikesCount(String biographyId, BuildContext context) async {
//   final GraphQLClient client = GraphQLProvider.of(context).value;

//   final QueryOptions options = QueryOptions(
//     document: gql(myQuery),
//     variables: {'biographyId': biographyId},
//   );

//   final QueryResult result = await client.query(options);

//   if (result.hasException) {
//     throw Exception(result.exception.toString());
//   }

//   final likesAggregate = result.data?['biographylikes_aggregate']?['aggregate'];
//   return likesAggregate?['count'] ?? 0;
// }
