import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';
import 'settings_service.dart';

// Reference card shown under the converter for the selected currency pair.
// Edit these to change which amounts are listed and how currencies are labelled.

/// Amounts listed on the reference card, in the "From" currency.
const List<double> referenceAmounts = [
  1, 25, 100, 500, 1000, 25000, 50000, 100000, 250000, 500000, 1000000,
];

/// Optional per-currency amounts that replace [referenceAmounts] for that "From" currency.
const Map<String, List<double>> referenceAmountsByCurrency = {};

/// Symbols shown before amounts; currencies not listed fall back to their code.
const Map<String, String> currencySymbols = {
  'USD': '\$',
  'PHP': '₱',
  'THB': '฿',
  'EUR': '€',
  'GBP': '£',
  'JPY': '¥',
  'CNY': '¥',
  'INR': '₹',
  'KRW': '₩',
  'VND': '₫',
  'IDR': 'Rp',
  'MYR': 'RM',
  'SGD': 'S\$',
  'AUD': 'A\$',
  'CAD': 'C\$',
  'NZD': 'NZ\$',
};

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final SettingsService _settingsService = SettingsService();
  final ApiService _apiService = ApiService();
  final TextEditingController _amountController = TextEditingController(text: '1');
  
  String _fromCurrency = 'USD';
  String _toCurrency = 'USD';
  Map<String, double> _exchangeRates = {};
  bool _isLoading = false;
  
  final List<String> _currencies = [
    'AED', 'ARS', 'AUD', 'BRL', 'CAD', 'CHF', 'CLP', 'CNY', 'COP', 'EUR', 'GBP', 
    'IDR', 'INR', 'JPY', 'KRW', 'KHR', 'LKR', 'MYR', 'MXN', 'NZD', 'PHP', 'RUB',
    'SGD', 'THB', 'TRY', 'USD', 'UYU', 'VND', 'ZAR',
  ];

  @override
  void initState() {
    super.initState();
    _fromCurrency = _settingsService.getBaseCurrency();
    _fetchExchangeRates();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchExchangeRates() async {
    setState(() => _isLoading = true);
    try {
      _exchangeRates = await _apiService.fetchExchangeRates(_fromCurrency);
      setState(() {});
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _withSymbol(double value, String code) {
    final symbol = currencySymbols[code];
    final formatted = _formatResult(value, code);
    return symbol == null ? '$formatted $code' : '$symbol$formatted';
  }

  Widget _buildReferenceCard(ThemeData theme) {
    final rate = _isLoading ? null : _exchangeRates[_toCurrency];
    final amounts = referenceAmountsByCurrency[_fromCurrency] ?? referenceAmounts;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$_fromCurrency → $_toCurrency',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          for (final amount in amounts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _withSymbol(amount, _fromCurrency),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  Text(
                    rate == null ? '—' : _withSymbol(amount * rate, _toCurrency),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getCurrencyName(String code) {
    const names = {
      'AED': 'UAE Dirham',
      'ARS': 'Argentine Peso',
      'AUD': 'Australian Dollar',
      'BRL': 'Brazilian Real',
      'CAD': 'Canadian Dollar',
      'CHF': 'Swiss Franc',
      'CLP': 'Chilean Peso',
      'CNY': 'Chinese Yuan',
      'COP': 'Colombian Peso',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'IDR': 'Indonesian Rupiah',
      'INR': 'Indian Rupee',
      'JPY': 'Japanese Yen',
      'KRW': 'Korean Won',
      'KHR': 'Cambodian Riel',
      'LKR': 'Sri Lankan Rupee',
      'MYR': 'Malaysian Ringgit',
      'MXN': 'Mexican Peso',
      'NZD': 'New Zealand Dollar',
      'PHP': 'Philippine Peso',
      'RUB': 'Russian Ruble',
      'SGD': 'Singapore Dollar',
      'THB': 'Thai Baht',
      'TRY': 'Turkish Lira',
      'USD': 'US Dollar',
      'UYU': 'Uruguayan Peso',
      'VND': 'Vietnamese Dong',
      'ZAR': 'South African Rand',
    };
    return names[code] ?? code;
  }

  String _formatResult(double value, String code) {
    if (value == 0) return '0';
    if (code == 'JPY' || code == 'KRW' || code == 'IDR' || code == 'KHR' || code == 'CLP' || code == 'VND') {
      return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    }
    return value.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},');
  }

  double get _convertedAmount {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_fromCurrency == _toCurrency) return amount;
    final rate = _exchangeRates[_toCurrency] ?? 0;
    return amount * rate;
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _fetchExchangeRates();
  }

  void _showCurrencyPicker(bool isFrom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    isFrom ? 'From Currency' : 'To Currency',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _currencies.length,
                    itemBuilder: (context, index) {
                      final code = _currencies[index];
                      final selected = isFrom ? _fromCurrency == code : _toCurrency == code;
                      return ListTile(
                        leading: Container(
                          width: 48,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected 
                              ? Theme.of(context).colorScheme.primaryContainer 
                              : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            code,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: selected 
                                ? Theme.of(context).colorScheme.onPrimaryContainer 
                                : Colors.black87,
                            ),
                          ),
                        ),
                        title: Text(_getCurrencyName(code)),
                        trailing: selected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                         onTap: () {
                           setState(() {
                             if (isFrom) {
                               _fromCurrency = code;
                               _fetchExchangeRates();
                             } else {
                               _toCurrency = code;
                             }
                           });
                           Navigator.pop(context);
                         },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'Convert',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => _showCurrencyPicker(true),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _fromCurrency,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              Center(
                child: IconButton.filled(
                  onPressed: _swapCurrencies,
                  icon: const Icon(Icons.swap_vert),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('To', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatResult(_convertedAmount, _toCurrency),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => _showCurrencyPicker(false),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _toCurrency,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              if (_exchangeRates.isNotEmpty && _fromCurrency != _toCurrency)
                Center(
                  child: Text(
                    '1 $_fromCurrency = ${_formatResult(_exchangeRates[_toCurrency] ?? 0, _toCurrency)} $_toCurrency',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),

              if (_fromCurrency != _toCurrency) ...[
                const SizedBox(height: 24),
                _buildReferenceCard(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
