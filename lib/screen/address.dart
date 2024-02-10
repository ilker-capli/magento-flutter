import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AddressScreen extends StatelessWidget {
  static const String query = """
  {
    customer {
      addresses {
        firstname
        lastname
        street
        city
        region {
          region
        }
        telephone
      }
    }
  }
  """;

  const AddressScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Addresses'),
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

          List addresses = result.data?['customer']['addresses'];
          return ListView.builder(
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              var address = addresses[index];
              String street = '';
              if (address['street'] != null && address['street'].isNotEmpty) {
                street = '${address['street'][0]}';
                if (address['street'].length > 1 && address['street'][1] != null) {
                  street += ' ${address['street'][1]}';
                }
              }
              return Card(
                child: Column(
                  children: [
                    Text('${address['firstname']} ${address['lastname']}'),
                    Text(street),
                    Text('${address['city']}'),
                    Text('${address['region']['region']}'),
                    Text('${address['telephone']}')
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
