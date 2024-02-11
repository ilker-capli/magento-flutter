import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:magento_flutter/screen/product.dart';
import 'package:magento_flutter/utils.dart';
import 'package:dio/dio.dart';

class ProductService {
  final Dio _dio = Dio();

  Future<dynamic> fetchProducts(int from, int size) async {
    try {
      String url = 'https://www.vicco.com.tr/elastic.php?categoryId=68&order=position&direction=asc&from=$from&size=$size';
      final response = await _dio.get(url);
      // printLongString(response.headers.toString());
      if (response.statusCode == 200) {
        printLongString('fetchProducts: $url');
        return response.data;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Failed to load products');
    }
  }
}

class Filter {
  final String name;
  final List<Option> options;

  Filter({required this.name, required this.options});

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      name: json['label'],
      options: List<Option>.from(
          json['options'].map((option) => Option.fromJson(option))),
    );
  }
}

class Option {
  final String name;
  final bool selected;

  Option({required this.name, required this.selected});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      name: json['key'],
      selected: false, // Varsayılan olarak seçili olmayacak
    );
  }
}

class ElasticTabs extends StatefulWidget {
  const ElasticTabs({super.key});

  @override
  State<ElasticTabs> createState() => _ElasticTabsState();
}

class _ElasticTabsState extends State<ElasticTabs> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _products = [];
  dynamic _aggregations = {};
  bool _loading = false;
  bool initialized = false;
  int _page = 1;
  int totalProducts = 0;

  double screenWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreProducts);
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMoreProducts);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProducts() async {
    printLongString('_loadProduct');
    setState(() {
      _loading = true;
    });
    try {
      dynamic data = await _productService.fetchProducts((_page-1)*12, 12);
      final List<dynamic> products = [];
      for (var item in data['product']['hits']['hits']) {
        products.add(item['_source']);
      }

      // printLongString(data['product']['aggregations'].keys.toString());
      
      for (var key in data['product']['aggregations'].keys) {
        printLongString(key.toString());
        printLongString(data['product']['aggregations'][key]['label']);
        printLongString(data['product']['aggregations'][key].toString());
      }
      
      setState(() {
        initialized = true;
        totalProducts = data['product']['hits']['total']['value'] ?? 0;
        _products.addAll(products);
        _aggregations = data['product']['aggregations'];
        _loading = false;
        _page++;
      });
    } catch (e) {
      // Handle error
      setState(() {
        _loading = false;
      });
    }
  }

  void _loadMoreProducts() {
    double threshold = 500.0;
    if (initialized && totalProducts <= _products.length) {
        return;
    }
    if (_scrollController.position.pixels + threshold >= _scrollController.position.maxScrollExtent) {
      if (!_loading) {
        _loadProducts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Elastic Page"),
      ),
      body: Column(
        children: [
          // Sabit alan
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Filtrele butonuna tıklama işlemleri
                    // Off canvas modalı açabilirsiniz
                    _openFilterModal();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.tune), // Icons.tune icon'u
                      SizedBox(width: 8), // Araya bir boşluk eklemek için SizedBox
                      Text('Filtrele'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Sırala butonuna tıklama işlemleri
                    // Off canvas modalı açabilirsiniz
                    setState(() {
                      _products.clear();
                      _page = 1;
                      totalProducts = 0;
                      _loadProducts();
                    });
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sort), // Icons.tune icon'u
                      SizedBox(width: 8), // Araya bir boşluk eklemek için SizedBox
                      Text('Sırala'),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  constraints: const BoxConstraints(
                    minWidth: 100, // Metnin minimum genişliği
                  ),
                  child: Text(
                    'Toplam: $totalProducts',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        childAspectRatio: 0.6,
      ),
      itemCount: _products.length + (_loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _products.length) {
          return _buildProductCard(_products[index], index);
        } else {
          return _buildLoadingIndicator();
        }
      },
    );
  }

  Widget _buildProductCard(dynamic product, int index) {
    screenWidth = MediaQuery.of(context).size.width;
    double imgW = (screenWidth / 2) - 12;
    double imgH = imgW * 1;
    
    return Container(
    margin: const EdgeInsets.fromLTRB(6, 6, 6, 24),
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromARGB(255, 250, 250, 250)),
      //borderRadius: BorderRadius.circular(12),
    ),
    //padding: const EdgeInsets.all(0),
    child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(
              title: product['name'],
              sku: product['sku'],
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CachedNetworkImage(
                imageUrl: 'https://vicco-k8s-media.mncdn.com/mnresize/425/-/media/catalog/product${product['image']}',
              width: imgW,
              height: imgH,
            ),
            const SizedBox(height: 8),
            Text(
              product['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              maxLines: 2, // Metni en fazla iki satıra sığdır
              overflow: TextOverflow.ellipsis, // Gerektiğinde metni kes ve üç nokta (...) ile göster
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${product['price']} ₺',
                style: const TextStyle(color: Colors.green),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: Text(
                '${index+1} / ${totalProducts.toString()}',
                style: const TextStyle(color: Colors.black12, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator()
        ]
      )
    );
  }

  void _openFilterModal() 
  {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sabit başlık (header)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              child: const Text(
                'Filtreler',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Scroll edilebilir alan
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dinamik olarak filtre seçeneklerini oluştur
                      
                      for (var key in _aggregations.keys) 

            ExpansionTile(
              title: Text(_aggregations[key]['label']),
              children: [
                
                for (var option in _aggregations[key]['buckets'])
                  CheckboxListTile(
                    title: Text(option['key']),
                    value: false,
                    onChanged: (bool? value) {
                      // Handle checkbox change
                    },
                  ),
                  
              ],
            ),
            
                    ],
                  ),
                ),
              ),
            ),
            // Sabit alt kısım (footer)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              child: Text(
                'Toplam Ürün Sayısı: $totalProducts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        );
      },
    );
  }


}
