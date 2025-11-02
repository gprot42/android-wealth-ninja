import 'package:flutter/material.dart';
import 'api_service.dart';
import 'settings_service.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final SettingsService _settingsService = SettingsService();
  final ApiService _apiService = ApiService();
  
  String _baseCurrency = 'CHF';
  Map<String, double> _exchangeRates = {};
  bool _isLoading = false;
  
  // Target currencies to show conversions for, sorted alphabetically
  final List<String> _targetCurrencies = [
    'ARS', // Argentine Peso
    'AUD', // Australian Dollar
    'CNY', // Chinese Yuan
    'COP', // Colombian Peso
    'EUR', // Euro
    'GBP', // British Pound
    'IDR', // Indonesian Rupiah
    'JPY', // Japanese Yen
    'KRW', // Korean Won
    'MXN', // Mexican Peso
    'NZD', // New Zealand Dollar
    'PHP', // Philippine Peso
    'RUB', // Russian Ruble
    'SGD', // Singapore Dollar
    'USD', // US Dollar (already supported)
    'ZAR', // South African Rand
    'LKR', // Sri Lankan Rupee
    'AED', // UAE Dirham
  ];

  @override
  void initState() {
    super.initState();
    _baseCurrency = _settingsService.getBaseCurrency();
    _fetchExchangeRates();
  }

  Future<void> _fetchExchangeRates() async {
    setState(() => _isLoading = true);
    try {
      _exchangeRates = await _apiService.fetchExchangeRates(_baseCurrency);
      setState(() {});
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'ARS': return 'Argentine Peso';
      case 'AUD': return 'Australian Dollar';
      case 'CNY': return 'Chinese Yuan';
      case 'COP': return 'Colombian Peso';
      case 'EUR': return 'Euro';
      case 'GBP': return 'British Pound';
      case 'IDR': return 'Indonesian Rupiah';
      case 'JPY': return 'Japanese Yen';
      case 'KRW': return 'Korean Won';
      case 'MXN': return 'Mexican Peso';
      case 'NZD': return 'New Zealand Dollar';
      case 'PHP': return 'Philippine Peso';
      case 'RUB': return 'Russian Ruble';
      case 'SGD': return 'Singapore Dollar';
      case 'USD': return 'US Dollar';
      case 'ZAR': return 'South African Rand';
      case 'LKR': return 'Sri Lankan Rupee';
      case 'AED': return 'UAE Dirham';
      default: return code;
    }
  }

  String _formatCurrency(double value, String code) {
    if (value == 0) return '0.00';
    
    // Different decimal places for different currencies
    if (code == 'JPY' || code == 'KRW') {
      return value.toStringAsFixed(0);
    } else if (code == 'IDR') {
      return value.toStringAsFixed(0);
    } else {
      return value.toStringAsFixed(2);
    }
  }

  void _changeBaseCurrency() {
    List<String> allCurrencies = ['CHF', 'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'SGD', 'AED', 'PHP', 'KRW', 'MXN', 'NZD', 'AUD', 'ARS', 'COP', 'RUB', 'ZAR', 'LKR']..sort();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Base Currency'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allCurrencies.length,
              itemBuilder: (context, index) {
                final currency = allCurrencies[index];
                return ListTile(
                  title: Text('$currency - ${_getCurrencyName(currency)}'),
                  trailing: currency == _baseCurrency ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      _baseCurrency = currency;
                      _settingsService.setBaseCurrency(currency);
                    });
                    Navigator.pop(context);
                    _fetchExchangeRates();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Currency Converter',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rates per 1 $_baseCurrency',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _changeBaseCurrency,
                  icon: const Icon(Icons.edit),
                  label: const Text('Change'),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchExchangeRates,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _targetCurrencies.length,
                itemBuilder: (context, index) {
                  final currencyCode = _targetCurrencies[index];
                  final rate = _exchangeRates[currencyCode] ?? 0.0;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('$currencyCode - ${_getCurrencyName(currencyCode)}'),
                      trailing: Text(
                        '${_formatCurrency(rate, currencyCode)} $currencyCode',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
