import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:magento_flutter/utils.dart';
import '../screen/product.dart';

Widget productBox(BuildContext context, dynamic item) {
  double screenWidth = MediaQuery.of(context).size.width;
  double imgW = (screenWidth / 2) - 12;
  double imgH = imgW * 1.5;
  printLongString('$imgW x $imgH');
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
            title: item['name'],
            sku: item['sku'],
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CachedNetworkImage(
            imageUrl: item['image']['url'],
            width: imgW,
            height: imgH,
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