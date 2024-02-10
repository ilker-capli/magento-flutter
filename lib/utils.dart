import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const Map<String, String> _currencies = {
  'USD': '\$',
  'EUR': '€',
  'TRY': 'TL',
  'AUD': 'A\$',
  'GBP': '£',
  'CAD': 'CA\$',
  'CNY': 'CN¥',
  'JPY': '¥',
  'SEK': 'SEK',
  'CHF': 'CHF',
  'INR': '₹',
  'KWD': 'د.ك',
  'RON': 'RON',
};

// todo - change
const Map<String, String> _optionLabelToCode = {
  'Beden': 'size'
};

String currencyWithPrice(dynamic price) {
  final currency = _currencies[price['currency']];
  return '${price['value'].toString()} $currency';
}

// todo - change
String getConfigurableAttributeCode(String label) {
  return _optionLabelToCode[label] ?? 'size';
}

/// Desktop Platform = 4 and Mobile Platform = 2
int certainPlatformGridCount() {
  var gridViewCount = 4;
  if (Platform.isIOS || Platform.isAndroid || Platform.isFuchsia) {
    gridViewCount = 2;
  }
  return gridViewCount;
}

bool gqlQueryResultHasAuthorizationError(QueryResult result) {
  if (result.exception != null) {
    List<GraphQLError> errors = result.exception!.graphqlErrors;
    for (var error in errors) {
      // Eğer hata yetkilendirme hatası ise true döndür
      if (error.extensions != null && error.extensions!['category'] == 'graphql-authorization') {
        return true;
      }
    }
  }
  return false;
}

void printLongString(String text) {
  if (kDebugMode) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    // ignore: avoid_print
    pattern.allMatches(text).forEach((RegExpMatch match) => print(match.group(0)));
  }
}

Future<String> getCart(BuildContext context) async {
  final client = GraphQLProvider.of(context).value;
  var result = await client.mutate(
    MutationOptions(document: gql('''
    mutation {
      createEmptyCart
    }
    ''')),
  );

  if (result.hasException) {
    if (kDebugMode) {
      print(result.exception.toString());
    }
    return "";
  }

  return result.data?['createEmptyCart'];
}
