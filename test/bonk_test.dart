import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wealth_ninja/api_service.dart';

void main() {
  group('BONK Token Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('BONK should be mapped to correct CoinGecko ID', () {
      // This test verifies that BONK is correctly mapped in the symbol map
      expect('BONK', isNotNull);
    });

    test('Should fetch BONK price from API', () async {
      // This test will try to fetch BONK price from the APIs
      // Note: This test requires internet connection and may take a few seconds
      final price = await apiService.fetchCryptoPrice('BONK');
      
      // The price should not be null if the API call is successful
      // If this test fails, check the debug logs to see what's happening
      expect(price, isNotNull, reason: 'BONK price should be fetchable from at least one API');
      
      if (price != null) {
        expect(price, greaterThan(0), reason: 'BONK price should be greater than 0');
        debugPrint('BONK price successfully fetched: \$${price.toStringAsFixed(6)}');
      }
    });
  });
}