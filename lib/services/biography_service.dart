// import 'dart:io';

// import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../services/storage_service.dart';

// final StorageService _storageService = StorageService();

// class GraphQLService {
//   static HttpLink getHttpLink() {
//     final HttpClient httpClient = HttpClient();
//     httpClient.connectionTimeout = const Duration(seconds: 30);

//     return HttpLink(
//       "http://49.13.238.194:2000/v1/graphql",
//       httpClient: IOClient(httpClient),
//     );
//   }

//   Link getAuthLink() {
//     return AuthLink(
//       getToken: () async {
//         final token = await _storageService.getToken();
//         if (token != null) {
//           return 'Bearer $token';
//         }
//         return null;
//       },
//     );
//   }

//   GraphQLClient clientTOQuery() {
//     final authLink = getAuthLink();
//     return GraphQLClient(
//       link: authLink.concat(httpLink),
//       cache: GraphQLCache(),
//     );
//   }
// }

// // Create a provider for the GraphQL client
// final graphqlClientProvider = Provider<GraphQLClient>((ref) {
//   final service = GraphQLService();
//   return service.clientTOQuery();
// });
