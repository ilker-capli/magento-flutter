import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:magento_flutter/utils.dart';
import '../screen/product.dart';

Widget productBox(BuildContext context, dynamic item) {
  return Container(
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromARGB(255, 218, 218, 218)),
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.all(8),
    child: InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductScreen(
            title: item['name'],
            sku: item['sku'],
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CachedNetworkImage(
            imageUrl: item['image']['url'],
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 8),
          Text(
            item['name'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 8),
          Text(
            currencyWithPrice(item['price_range']['minimum_price']['final_price']),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}