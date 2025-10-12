import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'settings_service.dart';
import 'main.dart' show Asset, AssetType;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCurrencyDialog() {
    String currentCurrency = _settingsService.getBaseCurrency();
    String newCurrency = currentCurrency;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Base Currency'),
          content: TextField(
            decoration:
                const InputDecoration(labelText: 'Currency (e.g., EUR)'),
            controller: TextEditingController(text: currentCurrency),
            onChanged: (val) => newCurrency = val.toUpperCase(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newCurrency.isNotEmpty) {
                  _settingsService.setBaseCurrency(newCurrency);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Theme'),
                    trailing: DropdownButton<String>(
                      value: _settingsService.getThemeMode(),
                      onChanged: (value) {
                        if (value != null) {
                          _settingsService.setThemeMode(value);
                          setDialogState(() {});
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 'light', child: Text('Light')),
                        DropdownMenuItem(value: 'dark', child: Text('Dark')),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Auto-refresh'),
                    trailing: Switch(
                      value: _settingsService.getAutoRefreshEnabled(),
                      onChanged: (value) {
                        _settingsService.setAutoRefreshEnabled(value);
                        setDialogState(() {});
                      },
                    ),
                  ),
                  if (_settingsService.getAutoRefreshEnabled())
                    ListTile(
                      title: const Text('Refresh Interval'),
                      trailing: DropdownButton<int>(
                        value: _settingsService.getRefreshInterval(),
                        onChanged: (value) {
                          if (value != null) {
                            _settingsService.setRefreshInterval(value);
                            setDialogState(() {});
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 min')),
                          DropdownMenuItem(value: 5, child: Text('5 min')),
                          DropdownMenuItem(value: 15, child: Text('15 min')),
                          DropdownMenuItem(value: 30, child: Text('30 min')),
                        ],
                      ),
                    ),
                  ListTile(
                    title: const Text('Cache Duration'),
                    trailing: DropdownButton<int>(
                      value: _settingsService.getCacheDuration(),
                      onChanged: (value) {
                        if (value != null) {
                          _settingsService.setCacheDuration(value);
                          setDialogState(() {});
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 30, child: Text('30 sec')),
                        DropdownMenuItem(value: 60, child: Text('1 min')),
                        DropdownMenuItem(value: 300, child: Text('5 min')),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Crypto Decimal Places'),
                    trailing: DropdownButton<int>(
                      value: _settingsService.getCryptoDecimalPlaces(),
                      onChanged: (value) {
                        if (value != null) {
                          _settingsService.setCryptoDecimalPlaces(value);
                          setDialogState(() {});
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('0')),
                        DropdownMenuItem(value: 1, child: Text('1')),
                        DropdownMenuItem(value: 2, child: Text('2')),
                        DropdownMenuItem(value: 3, child: Text('3')),
                        DropdownMenuItem(value: 4, child: Text('4')),
                        DropdownMenuItem(value: 5, child: Text('5')),
                        DropdownMenuItem(value: 6, child: Text('6')),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About Wealth Ninja'),
          content: const Text(
            'Wealth Ninja App v2.0\n'
            'Built with Flutter\n'
            'Tracks stocks, cryptocurrencies, and cash assets.\n'
            'Features real-time price updates, portfolio value visualization, '
            'dark/light mode, currency switching, and persistent settings.\n\n'
            'Data Sources:\n'
            '• Stocks: Yahoo Finance\n'
            '• Crypto: CoinGecko, CoinCap, CryptoCompare\n'
            '• Exchange Rates: Frankfurter API',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wealth Ninja'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'theme') {
                String current = _settingsService.getThemeMode();
                String newMode = current == 'dark' ? 'light' : 'dark';
                _settingsService.setThemeMode(newMode);
              } else if (value == 'currency') {
                _showCurrencyDialog();
              } else if (value == 'settings') {
                _showSettingsDialog();
              } else if (value == 'about') {
                _showAboutDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'theme', child: Text('Switch Theme')),
              const PopupMenuItem(
                  value: 'currency', child: Text('Change Base Currency')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'about', child: Text('About')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Crypto'),
            Tab(text: 'Stocks'),
            Tab(text: 'Portfolio'),
            Tab(text: 'Calculator'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CryptoTrackerScreen(),
          StockTrackerScreen(),
          PortfolioTrackerScreen(),
          CompoundCalculatorScreen(),
        ],
      ),
    );
  }
}

class CryptoTrackerScreen extends StatefulWidget {
  const CryptoTrackerScreen({super.key});

  @override
  State<CryptoTrackerScreen> createState() => _CryptoTrackerScreenState();
}

class _CryptoTrackerScreenState extends State<CryptoTrackerScreen> {
  final _box = Hive.box<Asset>('watched_assets');
  final SettingsService _settingsService = SettingsService();
  final ApiService _apiService = ApiService();
  Timer? _timer;
  String _baseCurrency = 'USD';
  Map<String, double> _exchangeRates = {'USD': 1.0};
  final Map<String, double> _currentPrices = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _baseCurrency = _settingsService.getBaseCurrency();
    _settingsService.watchKey('baseCurrency').listen((event) {
      setState(() {
        _baseCurrency = _settingsService.getBaseCurrency();
        _fetchExchangeRates().then((_) => _updatePrices());
      });
    });
    _fetchExchangeRates();
    _updatePrices();
    _setupAutoRefresh();
  }

  void _setupAutoRefresh() {
    if (_settingsService.getAutoRefreshEnabled()) {
      final interval = Duration(minutes: _settingsService.getRefreshInterval());
      _timer = Timer.periodic(interval, (_) => _updatePrices());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchExchangeRates() async {
    _exchangeRates = await _apiService.fetchExchangeRates(_baseCurrency);
  }

  Future<void> _updatePrices() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    await _fetchExchangeRates();

    // Only update crypto assets
    final cryptoAssets =
        _box.values.where((asset) => asset.type == AssetType.crypto);

    for (var asset in cryptoAssets) {
      final priceInUsd = await _apiService.fetchCryptoPrice(asset.symbol);
      if (priceInUsd != null) {
        final usdRate = _exchangeRates['USD'] ?? 1.0;
        _currentPrices[asset.symbol] = priceInUsd / usdRate;
      }
    }

    setState(() => _isLoading = false);
  }

  double _getAssetPrice(Asset asset) {
    return _currentPrices[asset.symbol] ?? 0;
  }

  void _addAsset() {
    showDialog(
      context: context,
      builder: (context) {
        String symbol = '';
        return AlertDialog(
          title: const Text('Add Cryptocurrency'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Symbol or CoinGecko ID (e.g., BTC, ethereum)',
                ),
                onChanged: (val) => symbol = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (symbol.isNotEmpty) {
                  final asset =
                      Asset(symbol, 1.0, 0.0, AssetType.crypto, 'USD');
                  _box.add(asset);
                  _updatePrices();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _box.listenable(),
              builder: (context, Box<Asset> box, _) {
                final cryptoAssets = box.values
                    .where((asset) => asset.type == AssetType.crypto)
                    .toList()
                  ..sort((a, b) =>
                      a.symbol.toLowerCase().compareTo(b.symbol.toLowerCase()));

                if (cryptoAssets.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.currency_bitcoin,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No cryptocurrencies added yet'),
                        Text('Tap + to add your first crypto',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _updatePrices,
                  child: ListView.builder(
                    itemCount: cryptoAssets.length,
                    itemBuilder: (context, index) {
                      final asset = cryptoAssets[index];
                      final price = _getAssetPrice(asset);
                      return ListTile(
                        title: Text(asset.symbol.toUpperCase()),
                        subtitle: Text(
                          'Current Price: ${price.toStringAsFixed(2)} $_baseCurrency',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => asset.delete(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAsset,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class StockTrackerScreen extends StatefulWidget {
  const StockTrackerScreen({super.key});

  @override
  State<StockTrackerScreen> createState() => _StockTrackerScreenState();
}

class _StockTrackerScreenState extends State<StockTrackerScreen> {
  final _box = Hive.box<Asset>('watched_assets');
  final SettingsService _settingsService = SettingsService();
  final ApiService _apiService = ApiService();
  Timer? _timer;
  String _baseCurrency = 'USD';
  Map<String, double> _exchangeRates = {'USD': 1.0};
  final Map<String, double> _currentPrices = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _baseCurrency = _settingsService.getBaseCurrency();
    _settingsService.watchKey('baseCurrency').listen((event) {
      setState(() {
        _baseCurrency = _settingsService.getBaseCurrency();
        _fetchExchangeRates().then((_) => _updatePrices());
      });
    });
    _fetchExchangeRates();
    _updatePrices();
    _setupAutoRefresh();
  }

  void _setupAutoRefresh() {
    if (_settingsService.getAutoRefreshEnabled()) {
      final interval = Duration(minutes: _settingsService.getRefreshInterval());
      _timer = Timer.periodic(interval, (_) => _updatePrices());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchExchangeRates() async {
    _exchangeRates = await _apiService.fetchExchangeRates(_baseCurrency);
  }

  Future<void> _updatePrices() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    await _fetchExchangeRates();

    // Only update stock assets
    final stockAssets =
        _box.values.where((asset) => asset.type == AssetType.stock);

    for (var asset in stockAssets) {
      final priceInUsd = await _apiService.fetchStockPrice(asset.symbol);
      if (priceInUsd != null) {
        final usdRate = _exchangeRates['USD'] ?? 1.0;
        _currentPrices[asset.symbol] = priceInUsd / usdRate;
      }
    }

    setState(() => _isLoading = false);
  }

  double _getAssetPrice(Asset asset) {
    return _currentPrices[asset.symbol] ?? 0;
  }

  void _addAsset() {
    showDialog(
      context: context,
      builder: (context) {
        String symbol = '';
        return AlertDialog(
          title: const Text('Add Stock'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Stock Symbol (e.g., AAPL, GOOGL)',
            ),
            onChanged: (val) => symbol = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (symbol.isNotEmpty) {
                  final asset = Asset(
                      symbol.toUpperCase(), 1.0, 0.0, AssetType.stock, 'USD');
                  _box.add(asset);
                  _updatePrices();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _box.listenable(),
              builder: (context, Box<Asset> box, _) {
                final stockAssets = box.values
                    .where((asset) => asset.type == AssetType.stock)
                    .toList()
                  ..sort((a, b) =>
                      a.symbol.toLowerCase().compareTo(b.symbol.toLowerCase()));

                if (stockAssets.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.trending_up, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No stocks added yet'),
                        Text('Tap + to add your first stock',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _updatePrices,
                  child: ListView.builder(
                    itemCount: stockAssets.length,
                    itemBuilder: (context, index) {
                      final asset = stockAssets[index];
                      final price = _getAssetPrice(asset);
                      return ListTile(
                        title: Text(asset.symbol.toUpperCase()),
                        subtitle: Text(
                          'Current Price: ${price.toStringAsFixed(2)} $_baseCurrency',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => asset.delete(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAsset,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CompoundCalculatorScreen extends StatefulWidget {
  const CompoundCalculatorScreen({super.key});

  @override
  State<CompoundCalculatorScreen> createState() =>
      _CompoundCalculatorScreenState();
}

class _CompoundCalculatorScreenState extends State<CompoundCalculatorScreen> {
  final ApiService _apiService = ApiService();
  final SettingsService _settingsService = SettingsService();

  final TextEditingController _amountController =
      TextEditingController(text: '1');
  final TextEditingController _rateController =
      TextEditingController(text: '30');
  final TextEditingController _yearsController =
      TextEditingController(text: '5');

  String _selectedCurrency = 'BTC';
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _result;

  final List<String> _currencies = [
    'BTC',
    'ETH',
    'MSTR',
    'USD',
    'CHF',
    'GBP',
    'PHP'
  ];

  int _cryptoDecimalPlaces = 2;
  StreamSubscription? _cryptoPrecisionSubscription;

  @override
  void initState() {
    super.initState();
    _cryptoDecimalPlaces = _settingsService.getCryptoDecimalPlaces();
    _cryptoPrecisionSubscription =
        _settingsService.watchKey('cryptoDecimalPlaces').listen((_) {
      if (!mounted) return;
      setState(() {
        _cryptoDecimalPlaces = _settingsService.getCryptoDecimalPlaces();
      });
    });
  }

  @override
  void dispose() {
    _cryptoPrecisionSubscription?.cancel();
    _amountController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  bool _isCrypto(String currency) => currency == 'BTC' || currency == 'ETH';

  bool _isStock(String currency) => currency == 'MSTR';

  double? _parseDouble(String input) {
    final sanitized = input.trim().replaceAll(',', '');
    if (sanitized.isEmpty) return null;
    return double.tryParse(sanitized);
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ') ? message.substring(11) : message;
  }

  String _buildDecimalPattern(int digits) {
    if (digits <= 0) {
      return '#,##0';
    }
    return '#,##0.${List.filled(digits, '0').join()}';
  }

  String _formatQuantity(double value, String currency) {
    final int digits =
        _isCrypto(currency) ? _cryptoDecimalPlaces.clamp(0, 6) : 4;
    final format = NumberFormat(_buildDecimalPattern(digits));
    return format.format(value);
  }

  String _formatCurrency(double value, String currency) {
    if (currency == 'USD') {
      return _formatUsd(value);
    }
    final int digits = _isCrypto(currency) ? _cryptoDecimalPlaces : 2;
    final formatter =
        NumberFormat.currency(symbol: '$currency ', decimalDigits: digits);
    return formatter.format(value);
  }

  String _formatUsd(double value, {int decimalDigits = 2}) {
    final formatter =
        NumberFormat.currency(symbol: 'USD ', decimalDigits: decimalDigits);
    return formatter.format(value);
  }

  int _suggestUsdDecimalDigits(double value) {
    if (value >= 1) {
      return 2;
    }
    if (value >= 0.1) {
      return 3;
    }
    if (value >= 0.01) {
      return 4;
    }
    if (value >= 0.001) {
      return 5;
    }
    return 6;
  }

  Widget _buildResultLine(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildResultSummaries(Color textColor, Color accentColor) {
    final result = _result!;
    final String type = result['type'] as String;
    final String currency = result['currency'] as String;
    final double rate = result['rate'] as double;
    final int years = result['years'] as int;

    final List<Widget> details = [];

    if (type == 'crypto' || type == 'stock') {
      final quantity = result['quantity'] as double;
      final currentPriceUsd = result['currentPriceUsd'] as double;
      final futurePriceUsd = result['futurePriceUsd'] as double;
      final currentValueUsd = result['currentValueUsd'] as double;
      final futureValueUsd = result['futureValueUsd'] as double;

      details.add(
        _buildResultLine(
          'Quantity',
          '${_formatQuantity(quantity, currency)} $currency',
          textColor,
        ),
      );
      details.add(
        _buildResultLine(
          'Current Price (USD)',
          _formatUsd(
            currentPriceUsd,
            decimalDigits: _suggestUsdDecimalDigits(currentPriceUsd),
          ),
          textColor,
        ),
      );
      details.add(
        _buildResultLine(
          'Future Price (USD)',
          _formatUsd(
            futurePriceUsd,
            decimalDigits: _suggestUsdDecimalDigits(futurePriceUsd),
          ),
          textColor,
        ),
      );
      details.add(
        _buildResultLine(
          'Current Value (USD)',
          _formatUsd(currentValueUsd),
          textColor,
        ),
      );
      details.add(
        _buildResultLine(
          'Future Value (USD)',
          _formatUsd(futureValueUsd),
          textColor,
        ),
      );
    } else if (type == 'fiat') {
      final currentValueBase = result['currentValueBase'] as double;
      final currentValueUsd = result['currentValueUsd'] as double;
      final futureValueBase = result['futureValueBase'] as double;
      final futureValueUsd = result['futureValueUsd'] as double;

      details.add(
        _buildResultLine(
          'Current Value',
          _formatCurrency(currentValueBase, currency),
          textColor,
        ),
      );
      details.add(
        _buildResultLine(
          'Current USD Value',
          _formatUsd(currentValueUsd),
          textColor,
        ),
      );
      details.add(
        _buildResultLine(
          'Future Value',
          _formatCurrency(futureValueBase, currency),
          textColor,
        ),
      );
      details.add(
        _buildResultLine(
          'Future USD Equivalent',
          _formatUsd(futureValueUsd),
          textColor,
        ),
      );
    } else {
      final currentValue = result['currentValue'] as double;
      final futureValue = result['futureValue'] as double;
      details.add(
        _buildResultLine(
          'Current Value',
          _formatCurrency(currentValue, currency),
          textColor,
        ),
      );
      details.add(
        _buildResultLine(
          'Future Value',
          _formatCurrency(futureValue, currency),
          textColor,
        ),
      );
    }

    details.add(const SizedBox(height: 12));
    details.add(
      Text(
        'Assumes a ${rate.toStringAsFixed(2)}% CAGR over $years year${years == 1 ? '' : 's'}.',
        style: TextStyle(
          color: accentColor,
          fontStyle: FontStyle.italic,
        ),
      ),
    );

    return details;
  }

  void _reset() {
    setState(() {
      _amountController.text = '1';
      _rateController.text = '30';
      _yearsController.text = '5';
      _selectedCurrency = 'BTC';
      _errorMessage = null;
      _result = null;
    });
  }

  Future<Map<String, dynamic>> _deriveResult({
    required double amount,
    required double rate,
    required int years,
    required double growthFactor,
    required String currency,
  }) async {
    if (_isCrypto(currency)) {
      final currentPrice = await _apiService.fetchCryptoPrice(currency);
      if (currentPrice == null) {
        throw Exception('Failed to fetch current price for $currency');
      }
      final quantity = amount;
      final futurePrice = currentPrice * growthFactor;
      final currentValueUsd = quantity * currentPrice;
      final futureValueUsd = quantity * futurePrice;

      return {
        'type': 'crypto',
        'currency': currency,
        'quantity': quantity,
        'currentPriceUsd': currentPrice,
        'futurePriceUsd': futurePrice,
        'currentValueUsd': currentValueUsd,
        'futureValueUsd': futureValueUsd,
        'rate': rate,
        'years': years,
        'growthFactor': growthFactor,
      };
    }

    if (_isStock(currency)) {
      final currentPrice = await _apiService.fetchStockPrice(currency);
      if (currentPrice == null) {
        throw Exception('Failed to fetch current price for $currency');
      }
      final quantity = amount;
      final futurePrice = currentPrice * growthFactor;
      final currentValueUsd = quantity * currentPrice;
      final futureValueUsd = quantity * futurePrice;

      return {
        'type': 'stock',
        'currency': currency,
        'quantity': quantity,
        'currentPriceUsd': currentPrice,
        'futurePriceUsd': futurePrice,
        'currentValueUsd': currentValueUsd,
        'futureValueUsd': futureValueUsd,
        'rate': rate,
        'years': years,
        'growthFactor': growthFactor,
      };
    }

    if (currency == 'USD') {
      final currentValue = amount;
      final futureValue = amount * growthFactor;

      return {
        'type': 'usd',
        'currency': currency,
        'currentValue': currentValue,
        'futureValue': futureValue,
        'futureValueUsd': futureValue,
        'rate': rate,
        'years': years,
        'growthFactor': growthFactor,
      };
    }

    final exchangeRates = await _apiService.fetchExchangeRates(currency);
    final usdRate = exchangeRates['USD'];
    if (usdRate == null) {
      throw Exception('Unable to determine USD exchange rate for $currency');
    }

    final currentValueUsd = amount * usdRate;
    final futureValueBase = amount * growthFactor;
    final futureValueUsd = futureValueBase * usdRate;

    return {
      'type': 'fiat',
      'currency': currency,
      'currentValueBase': amount,
      'currentValueUsd': currentValueUsd,
      'futureValueBase': futureValueBase,
      'futureValueUsd': futureValueUsd,
      'usdRate': usdRate,
      'rate': rate,
      'years': years,
      'growthFactor': growthFactor,
    };
  }

  Future<void> _calculate() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final amount = _parseDouble(_amountController.text);
      final rate = _parseDouble(_rateController.text);
      final years = int.tryParse(_yearsController.text.trim());

      if (amount == null || amount <= 0) {
        throw Exception('Please enter a valid positive amount or quantity');
      }
      if (rate == null || rate < 0) {
        throw Exception('Please enter a valid non-negative rate');
      }
      if (years == null || years <= 0) {
        throw Exception('Please enter a valid positive number of years');
      }

      final growthFactor = pow(1 + rate / 100, years).toDouble();
      final selectedCurrency = _selectedCurrency;

      final result = await _deriveResult(
        amount: amount,
        rate: rate,
        years: years,
        growthFactor: growthFactor,
        currency: selectedCurrency,
      );

      if (mounted) {
        setState(() {
          _result = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _friendlyError(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCrypto = _isCrypto(_selectedCurrency);
    final bool isStock = _isStock(_selectedCurrency);
    final bool isAsset = isCrypto || isStock;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color baseSurface = isDarkMode
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surfaceContainerLow;
    final Color resultBackground =
        isDarkMode ? baseSurface.withValues(alpha: 0.6) : baseSurface;
    final Color resultBorder =
        colorScheme.outlineVariant.withValues(alpha: isDarkMode ? 0.4 : 0.7);
    final Color resultTextColor = colorScheme.onSurface;
    final Color resultAccentColor = colorScheme.primary;

    final String amountLabel = isAsset ? 'Quantity Owned' : 'Beginning Amount';
    final String? amountHelper = isAsset
        ? 'Number of ${isStock ? 'shares' : 'units'} currently held'
        : null;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compound Wealth Calculator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: amountLabel,
                helperText: amountHelper,
                border: const OutlineInputBorder(),
                suffixText: isAsset ? null : _selectedCurrency,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rateController,
              decoration: const InputDecoration(
                labelText: 'Annual Growth Rate',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _yearsController,
              decoration: const InputDecoration(
                labelText: 'Number of Years',
                suffixText: 'yrs',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'Currency/Asset',
                border: OutlineInputBorder(),
              ),
              items: _currencies
                  .map(
                    (currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ),
                  )
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedCurrency = value;
                      });
                    },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _calculate,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Calculate'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: resultBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: resultBorder),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: resultAccentColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildResultSummaries(
                        resultTextColor, resultAccentColor),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PortfolioTrackerScreen extends StatefulWidget {
  const PortfolioTrackerScreen({super.key});

  @override
  State<PortfolioTrackerScreen> createState() => _PortfolioTrackerScreenState();
}

class _PortfolioTrackerScreenState extends State<PortfolioTrackerScreen> {
  final _box = Hive.box<Asset>('portfolio_assets');
  final SettingsService _settingsService = SettingsService();
  final ApiService _apiService = ApiService();
  Timer? _timer;
  String _baseCurrency = 'USD';
  Map<String, double> _exchangeRates = {'USD': 1.0};
  final Map<String, double> _currentPrices = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _baseCurrency = _settingsService.getBaseCurrency();
    _settingsService.watchKey('baseCurrency').listen((event) {
      setState(() {
        _baseCurrency = _settingsService.getBaseCurrency();
        _fetchExchangeRates().then((_) => _updatePrices());
      });
    });
    _fetchExchangeRates();
    _updatePrices();
    _setupAutoRefresh();
  }

  void _setupAutoRefresh() {
    if (_settingsService.getAutoRefreshEnabled()) {
      final interval = Duration(minutes: _settingsService.getRefreshInterval());
      _timer = Timer.periodic(interval, (_) => _updatePrices());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchExchangeRates() async {
    _exchangeRates = await _apiService.fetchExchangeRates(_baseCurrency);
  }

  Future<void> _updatePrices() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    await _fetchExchangeRates();

    for (var asset in _box.values) {
      double? priceInUsd;

      if (asset.type == AssetType.cash) {
        _currentPrices[asset.symbol] = 1.0;
        continue;
      }

      if (asset.type == AssetType.stock) {
        priceInUsd = await _apiService.fetchStockPrice(asset.symbol);
      } else if (asset.type == AssetType.crypto) {
        priceInUsd = await _apiService.fetchCryptoPrice(asset.symbol);
      }

      if (priceInUsd != null) {
        final usdRate = _exchangeRates['USD'] ?? 1.0;
        _currentPrices[asset.symbol] = priceInUsd / usdRate;
      }
    }

    setState(() => _isLoading = false);
  }

  double _getAssetValue(Asset asset) {
    final rate = _exchangeRates[asset.currency] ?? 1.0;
    if (asset.type == AssetType.cash) return asset.quantity / rate;
    final currentPrice =
        _currentPrices[asset.symbol] ?? (asset.buyPrice / rate);
    return asset.quantity * currentPrice;
  }

  double _getProfit(Asset asset) {
    if (asset.type == AssetType.cash) return 0.0;
    final currentPrice = _currentPrices[asset.symbol];
    if (currentPrice == null) return 0.0;
    final buyPriceInBase =
        asset.buyPrice / (_exchangeRates[asset.currency] ?? 1.0);
    return (currentPrice - buyPriceInBase) * asset.quantity;
  }

  double _getProfitPercentage(Asset asset) {
    if (asset.type == AssetType.cash) return 0.0;
    final currentPrice = _currentPrices[asset.symbol];
    if (currentPrice == null) return 0.0;
    final buyPriceInBase =
        asset.buyPrice / (_exchangeRates[asset.currency] ?? 1.0);
    if (buyPriceInBase == 0) return 0.0;
    return ((currentPrice - buyPriceInBase) / buyPriceInBase) * 100;
  }

  List<PieChartSectionData> _generatePieSections(List<Asset> assets) {
    final double totalValue =
        assets.map(_getAssetValue).fold(0.0, (prev, val) => prev + val);
    const List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
    ];
    int i = 0;
    return assets.map((asset) {
      final double value = _getAssetValue(asset);
      final double percentage = totalValue > 0 ? (value / totalValue) * 100 : 0;
      final Color color = colors[i % colors.length];
      i++;
      final labelSymbol =
          asset.type == AssetType.cash && (asset.cashNote?.isNotEmpty ?? false)
              ? '${asset.symbol} (${asset.cashNote})'
              : asset.symbol;
      return PieChartSectionData(
        value: value,
        color: color,
        title: '${percentage.toStringAsFixed(0)}%\n$labelSymbol',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  void _addAsset() {
    showDialog(
      context: context,
      builder: (context) {
        final symbolController = TextEditingController();
        final quantityController = TextEditingController();
        final buyPriceController = TextEditingController();
        final currencyController = TextEditingController(text: 'USD');
        final cashNoteController = TextEditingController();
        AssetType type = AssetType.stock;

        return AlertDialog(
          title: const Text('Add Portfolio Asset'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<AssetType>(
                      isExpanded: true,
                      value: type,
                      onChanged: (val) => setDialogState(() => type = val!),
                      items: AssetType.values
                          .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.toString().split('.').last)))
                          .toList(),
                    ),
                    if (type != AssetType.cash)
                      TextField(
                        controller: symbolController,
                        decoration: InputDecoration(
                            labelText: type == AssetType.crypto
                                ? 'Symbol or CoinGecko ID'
                                : 'Stock Symbol (e.g., GOOG)'),
                      ),
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                          labelText:
                              type == AssetType.cash ? 'Amount' : 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    if (type != AssetType.cash)
                      TextField(
                        controller: buyPriceController,
                        decoration: const InputDecoration(
                            labelText: 'Buy Price (per unit)'),
                        keyboardType: TextInputType.number,
                      ),
                    TextField(
                      controller: currencyController,
                      decoration: const InputDecoration(
                          labelText: 'Currency (e.g., CHF)'),
                    ),
                    if (type == AssetType.cash)
                      TextField(
                        controller: cashNoteController,
                        decoration: const InputDecoration(
                          labelText: 'Comment (max 4 chars)',
                          helperText: 'Optional',
                          counterText: '',
                        ),
                        maxLength: 4,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String symbol;
                if (type == AssetType.cash) {
                  symbol = currencyController.text.toUpperCase();
                } else if (type == AssetType.stock) {
                  symbol = symbolController.text.toUpperCase();
                } else {
                  symbol = symbolController.text;
                }
                final quantity =
                    double.tryParse(quantityController.text) ?? 0.0;
                final buyPrice =
                    double.tryParse(buyPriceController.text) ?? 0.0;
                final currency = currencyController.text.toUpperCase();
                final rawNote = cashNoteController.text.trim();
                final normalizedNote =
                    rawNote.isEmpty ? null : rawNote.toUpperCase();
                if (symbol.isNotEmpty && quantity > 0) {
                  final asset = Asset(
                    symbol,
                    quantity,
                    type == AssetType.cash ? 1.0 : buyPrice,
                    type,
                    currency,
                    type == AssetType.cash ? normalizedNote : null,
                  );
                  _box.add(asset);
                  _updatePrices();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editAsset(Asset asset) {
    final symbolController = TextEditingController(text: asset.symbol);
    final quantityController =
        TextEditingController(text: asset.quantity.toString());
    final buyPriceController =
        TextEditingController(text: asset.buyPrice.toString());
    final currencyController = TextEditingController(text: asset.currency);
    final cashNoteController =
        TextEditingController(text: asset.cashNote ?? '');
    AssetType type = asset.type;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Portfolio Asset'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<AssetType>(
                      isExpanded: true,
                      value: type,
                      onChanged: (val) => setDialogState(() => type = val!),
                      items: AssetType.values
                          .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.toString().split('.').last)))
                          .toList(),
                    ),
                    if (type != AssetType.cash)
                      TextField(
                        controller: symbolController,
                        decoration: InputDecoration(
                            labelText: type == AssetType.crypto
                                ? 'Symbol or CoinGecko ID'
                                : 'Stock Symbol (e.g., GOOG)'),
                      ),
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                          labelText:
                              type == AssetType.cash ? 'Amount' : 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    if (type != AssetType.cash)
                      TextField(
                        controller: buyPriceController,
                        decoration: const InputDecoration(
                            labelText: 'Buy Price (per unit)'),
                        keyboardType: TextInputType.number,
                      ),
                    TextField(
                      controller: currencyController,
                      decoration: const InputDecoration(
                          labelText: 'Currency (e.g., CHF)'),
                    ),
                    if (type == AssetType.cash)
                      TextField(
                        controller: cashNoteController,
                        decoration: const InputDecoration(
                          labelText: 'Comment (max 4 chars)',
                          helperText: 'Optional',
                          counterText: '',
                        ),
                        maxLength: 4,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String symbol;
                if (type == AssetType.cash) {
                  symbol = currencyController.text.toUpperCase();
                } else if (type == AssetType.stock) {
                  symbol = symbolController.text.toUpperCase();
                } else {
                  symbol = symbolController.text;
                }
                final quantity =
                    double.tryParse(quantityController.text) ?? 0.0;
                final buyPrice =
                    double.tryParse(buyPriceController.text) ?? 0.0;
                final currency = currencyController.text.toUpperCase();
                final rawNote = cashNoteController.text.trim();
                final normalizedNote =
                    rawNote.isEmpty ? null : rawNote.toUpperCase();
                if (symbol.isNotEmpty && quantity > 0) {
                  // Update the existing asset
                  asset.symbol = symbol;
                  asset.quantity = quantity;
                  asset.buyPrice = type == AssetType.cash ? 1.0 : buyPrice;
                  asset.type = type;
                  asset.currency = currency;
                  asset.cashNote =
                      type == AssetType.cash ? normalizedNote : null;
                  asset.save(); // Save the changes to Hive
                  _updatePrices();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(name: _baseCurrency);

    return Scaffold(
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _box.listenable(),
              builder: (context, Box<Asset> box, _) {
                final assets = box.values.toList()
                  ..sort((a, b) =>
                      a.symbol.toLowerCase().compareTo(b.symbol.toLowerCase()));

                if (assets.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Your portfolio is empty'),
                        Text('Tap + to add your first asset',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final double totalValue = assets
                    .map((asset) => _getAssetValue(asset))
                    .fold(0.0, (prev, val) => prev + val);

                return RefreshIndicator(
                  onRefresh: _updatePrices,
                  child: Column(
                    children: [
                      if (totalValue > 0)
                        SizedBox(
                          height: 250,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: _generatePieSections(assets),
                                  centerSpaceRadius: 60,
                                  sectionsSpace: 2,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Total Value'),
                                  Text(
                                    formatCurrency.format(totalValue),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '($_baseCurrency)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: assets.length,
                          itemBuilder: (context, index) {
                            final asset = assets[index];
                            final value = _getAssetValue(asset);
                            final profit = _getProfit(asset);
                            final profitPercentage =
                                _getProfitPercentage(asset);
                            final profitColor =
                                profit >= 0 ? Colors.green : Colors.red;
                            return ListTile(
                              title: Text(
                                '${asset.symbol.toUpperCase()}${asset.type == AssetType.cash && (asset.cashNote?.isNotEmpty ?? false) ? ' (${asset.cashNote})' : ''} (${asset.quantity})',
                              ),
                              subtitle: Text(
                                'Value: ${formatCurrency.format(value)}${asset.type != AssetType.cash ? '\nProfit: ${formatCurrency.format(profit)} (${profitPercentage >= 0 ? '+' : ''}${profitPercentage.toStringAsFixed(2)}%)' : ''}',
                                style: asset.type != AssetType.cash
                                    ? TextStyle(color: profitColor)
                                    : null,
                              ),
                              isThreeLine: asset.type != AssetType.cash,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editAsset(asset),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => asset.delete(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAsset,
        child: const Icon(Icons.add),
      ),
    );
  }
}
