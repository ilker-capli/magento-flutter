import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:magento_flutter/templates/product_box.dart';

import '../utils.dart';

class ElasticScreen extends StatelessWidget {
  final String title;
  final String categoryId;

  const ElasticScreen({
    super.key,
    required this.title,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: const Text('asd')
    );
  }
}
