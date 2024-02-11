import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/accounts.dart';
import '../screen/address.dart';
import '../screen/myorder.dart';
import '../screen/signin.dart';
import '../screen/wishlist.dart';
import '../utils.dart';

class AccountsTabs extends StatelessWidget {
  const AccountsTabs({super.key});

  static const String customerQuery = """
  {
    customer {
      firstname
      lastname
    }
  }
  """;

  static const String revokeToken = """
  mutation {
    revokeCustomerToken {
      result
    }
  }
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Hesabım"),
      ),
      body: accountsBody(context),
    );
  }

  Widget accountsBody(BuildContext context) {
    printLongString('accountsBody');
    final isLoggedOn =
        context.select<AccountsProvider, bool>((value) => value.isCustomer);
    printLongString(isLoggedOn.toString());
    if (isLoggedOn) {
      return _customer(context);
    }
    return _guest(context);
  }

  Widget _guest(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Misafir Oturum'),
          ElevatedButton(
            child: const Text('Giriş Yap'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: screenSize.height / 2.2,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/profile_cover.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _customer(BuildContext context) {
    return Query(
      options: QueryOptions(document: gql(customerQuery)),
      builder: (result, {fetchMore, refetch}) {
        if (result.hasException) {
          if (gqlQueryResultHasAuthorizationError(result)) {
            printLongString('ERROR: graphql-authorization');
            printLongString(result.toString());
            Provider.of<AccountsProvider>(context, listen: false).signOff();
          }

          // return Text(result.exception.toString());
          return _guest(context);
        }

        if (result.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        dynamic customer = result.data?['customer'];
        var screenSize = MediaQuery.of(context).size;
        return SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  _buildCoverImage(screenSize/2),
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildProfileImage(),
                      Text(
                        '${customer['firstname']} ${customer['lastname']}',
                        style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
              Card(
                child: ListTile(
                  title: const Text('Siparişlerim'),
                  subtitle: const Text('Siparişlerinizin Durumlarını Kontrol Edin'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyOrderScreen()),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Adres Defterim'),
                  subtitle: const Text('Kayıtlı Adreslerini Gör / Düzenle'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddressScreen()),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Favori Listem'),
                  subtitle: const Text('Favori Listenizdeki Ürünleri Görün'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WishlistScreen()),
                  ),
                ),
              ),
              Mutation(
                options: MutationOptions(
                  document: gql(revokeToken),
                  onCompleted: (data) {
                    if (data != null) {
                      printLongString('revoke... onCompleted');
                      printLongString(data.toString());

                      final result = data['revokeCustomerToken']?['result'] ?? false;
                      if (result) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Çıkış Başarılı!')),
                        );
                        Provider.of<AccountsProvider>(context, listen: false)
                            .signOff();
                        getCart(context);
                      }
                    }
                  },
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error.toString()),
                      ),
                    );
                  },
                ),
                builder: (runMutation, result) {
                  return ElevatedButton(
                    child: const Text('Çıkış Yap'),
                    onPressed: () {
                      runMutation({});
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Container(
        width: 140.0,
        height: 140.0,
        decoration: BoxDecoration(
          /*image: DecorationImage(
            image: AssetImage('assets/images/nickfrost.jpg'),
            fit: BoxFit.cover,
          ),*/
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.white,
            width: 10.0,
          ),
        ),
      ),
    );
  }
}
