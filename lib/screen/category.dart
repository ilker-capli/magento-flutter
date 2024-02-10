import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:magento_flutter/templates/product_box.dart';

import '../utils.dart';

class CategoryScreen extends StatelessWidget {
  final String title;
  final String categoryId;

  const CategoryScreen({
    super.key,
    required this.title,
    required this.categoryId,
  });

  static const query = r'''
   query GetProductsByCategory($categoryId: String) {
    products(filter: {
      category_uid: {
        eq: $categoryId
      }
    } ) {
      items {
        name
        sku
        image {
          url
        }
        price_range {
          minimum_price {
            final_price {
              currency
                value
              }
            }
          }
        }
      }
   }
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(query),
          variables: {
            'categoryId': categoryId.toString(),
          },
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List items = result.data?['products']['items'];
          if (items.isEmpty) {
            return const Center(
              child: Text('Bu kategoride şuan için hiç bir ürün bulunamadı.'),
            );
          }

          return GridView.count(
            crossAxisCount: certainPlatformGridCount(),
            childAspectRatio: 0.475,
            children: List.generate(
              items.length,
              (index) => productBox(
                context,
                items[index],
              ),
            ),
          );
        },
      ),
    );
  }
}
