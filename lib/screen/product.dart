import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import '../mutation.dart';
import '../provider/cart.dart';
import '../utils.dart';
import 'products/configurations.dart';

class ProductScreen extends StatefulWidget {
  final String title;
  final String sku;

  const ProductScreen({
    super.key,
    required this.title,
    required this.sku,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final qtyController = TextEditingController(text: '1');
  final optionsMap = <String, String>{};
  final _formKey = GlobalKey<FormState>();

Map<String, bool> _isPanelExpandedMap = {};

@override
void initState() {
  super.initState();
  _isPanelExpandedMap = {
    'description': false, // Varsayılan olarak kapalı
    'shipping': false,
  };
}

// ExpansionPanelList içindeki expansionCallback metodu
expansionCallback(String panelKey, bool isExpanded) {
  setState(() {
    _isPanelExpandedMap[panelKey] = !isExpanded;
  });
}
  static const query = r'''
   query GetProductsBySKU($sku: String) {
    products(filter: { sku: { eq: $sku }}) {
      items {
        image {
          url
        }
        sku
        __typename
        price_range {
          minimum_price {
            final_price {
              currency
              value
            }
          }
        }
        description {
          html
        }
        ... on ConfigurableProduct {
          configurable_options {
            label
            values {
              label
            }
          }
          variants {
            product {
              sku
            }
            attributes {
              uid
              label
              code
            }
          }
        }
      }
    }
   }
   ''';

  @override
  void dispose() {
    qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(query),
          variables: {
            'sku': widget.sku,
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

          dynamic item = result.data?['products']['items'][0];
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: item['image']['url'],
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      height: 500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyWithPrice(
                      item['price_range']['minimum_price']['final_price'],
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _options(
                    item: item,
                  ),
                  const SizedBox(height: 16),
                  ExpansionPanelList(
                    elevation: 0,
                    expandedHeaderPadding: EdgeInsets.zero,
                    children: [
                      ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) => const ListTile(
                          title: Text(
                            'Ürün Açıklaması',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        body: ListTile(
                          title: Html(
                            data: item['description']['html'],
                            style: {
                              'body': Style(fontSize: FontSize.medium),
                            },
                          ),
                        ),
                        isExpanded: _isPanelExpandedMap['description'] ?? false,
                      ),
                      ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) => const ListTile(
                          title: Text(
                            'Teslimat ve Kargo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        body: ListTile(
                          title: Html(
                            data: 'Kargo ücreti 39,99 TL olup 1.000 TL ve üzeri siparişlerinizde kargo ücretsizdir. Siparişleriniz 2-4 iş günü içerisinde kargoya teslim edilecektir. Kargoya teslim edilen siparişiniz ile ilgili kargo firmasından tarafınıza SMS gönderilecek olup aynı anda kargo bilgileri mail olarak da tarafınıza bilgilendirme yapılacaktır (NOT: Birden fazla ürün bulunan siparişlerinizdeki bazı ürünler mağaza depolarımız üzerinden sevk edilebilir. Bu gönderiler parçalı gönderim olup farklı zamanlarda teslim edilebilmektedir. Siparişiniz ile herhangi bir soruda müşteri hizmetlerimizden bilgi alabilirsiniz). Sipariş gönderim aşamalarını Hesabım bölümündeki siparişlerim kısmından takip edebilirsiniz.',
                            style: {
                              'body': Style(fontSize: FontSize.medium),
                            },
                          ),
                        ),
                        isExpanded: _isPanelExpandedMap['shipping'] ?? false,
                      ),
                    ],

                    expansionCallback: (panelIndex, isExpanded) {
                      if (panelIndex == 0) {
                        expansionCallback('description', !isExpanded);
                      } else if (panelIndex == 1) {
                        expansionCallback('shipping', !isExpanded);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: false,
                    controller: qtyController,
                    decoration: InputDecoration(
                      hintText: '1',
                      labelText: 'Adet',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                        borderSide: const BorderSide(color: Colors.grey), // Gri renkli kenarlık
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                        borderSide: const BorderSide(color: Colors.grey), // Gri renkli kenarlık
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen sepete eklemek için adet girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: orderMutation(
                      cartProvider,
                      widget.sku,
                      qtyController,
                      _formKey,
                      item,
                      optionsMap,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _options({required dynamic item}) {
    if (item['__typename'] == "ConfigurableProduct") {
      return configurationOptions(item: item, options: optionsMap);
    }
    return Container();
  }
}
