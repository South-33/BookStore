import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'fakeproduct_model.dart';

class ProductService {
  Future<List<Giveaway>> getApi() async {
    final uri = Uri.parse('https://www.gamerpower.com/api/giveaways');
    final res = await http.get(uri);
    try {
      if (res.statusCode == 200) {
        return compute(giveawayListFromJson, res.body);
      } else {
        throw Exception("Error Status Code: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

}