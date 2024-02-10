import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:magento_flutter/utils.dart';

class MyOrderScreen extends StatelessWidget {
  static const String query = """
  {
    customerOrders {
      items {
        order_number
        created_at
        grand_total
        status
      }
    }
  }
  """;

  const MyOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Orders'),
      ),
      body: Query(
        options: QueryOptions(document: gql(query)),
        builder: (result, {fetchMore, refetch}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List items = result.data?['customerOrders']['items'];
          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return orderBox(context, item);
            },
          );
        },
      ),
    );
  }

  Widget orderBox(BuildContext context, dynamic item) => Container(
      margin: const EdgeInsets.all(4), // Margin ekleme
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 218, 218, 218)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8), // Padding ekleme
      child: InkWell(
        onTap: () => printLongString('TAPPPP: ${item.toString()}'),
        child: Column( 
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // İçeriği düşeyde ortala
          children: [
            const SizedBox(height: 8), // Yükseklik için bir boşluk ekleyin
            Text(
              item['order_number'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 8), // Yükseklik için bir boşluk ekleyin
            Text(
              item['grand_total'].toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
}
