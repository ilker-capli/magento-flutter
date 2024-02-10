import 'package:flutter/material.dart';
import 'package:magento_flutter/utils.dart';

Widget configurationOptions({
  dynamic item,
  required Map<String, String> options,
}) {
  var configurableOptions = item['configurable_options'];
  if (configurableOptions == null) {
    return Container();
  }
  var widgetList = <Widget>[];
  for (var option in configurableOptions) {
    widgetList.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownMenu<dynamic>(
          dropdownMenuEntries: option['values']
              .map<DropdownMenuEntry>((e) => DropdownMenuEntry(
                    value: e['label'],
                    label: e['label'],
                  ))
              .toList(),
          label: Text(option['label']),
          onSelected: (value) {
            options[getConfigurableAttributeCode(option['label'])] = value;
          },
        ),
      ),
    );
  }
  return Column(
    children: widgetList,
  );
}

String getVariantSku({dynamic data, required Map<String, String> options, required String sku}) {
  var variantSku = sku;

  // Veri null değilse ve 'variants' adlı bir anahtar içeriyorsa
  if (data != null && data['variants'] != null) {
    var variants = data['variants'] as List;

    // Tüm varyantları kontrol et
    for (var variant in variants) {
      // Varyantın 'attributes' anahtarına eriş ve öznitelikleri kontrol et
      var attributes = variant['attributes'] as List;

      // İlk ve ikinci seçeneklerin her ikisi de mevcutsa
      if (attributes.any((attr) => attr['code'] == options.keys.first && attr['label'] == options.values.first) &&
          attributes.any((attr) => attr['code'] == options.keys.last && attr['label'] == options.values.last)) {
        // Varyant SKU'sunu al
        variantSku = variant['product']['sku'];
        break; // İlk eşleşme bulunduğunda döngüyü sonlandır
      }
    }
  }

  return variantSku;
}