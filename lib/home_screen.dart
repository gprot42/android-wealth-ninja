import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
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
            decoration: const InputDecoration(labelText: 'Currency (e.g., EUR)'),
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
              const PopupMenuItem(value: 'currency', child: Text('Change Base Currency')),
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
    final cryptoAssets = _box.values.where((asset) => asset.type == AssetType.crypto);
    
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
                  final asset = Asset(symbol, 1.0, 0.0, AssetType.crypto, 'USD');
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
          if (_isLoading)
            const LinearProgressIndicator(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _box.listenable(),
              builder: (context, Box<Asset> box, _) {
                final cryptoAssets = box.values.where((asset) => asset.type == AssetType.crypto).toList();
                
                if (cryptoAssets.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.currency_bitcoin, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No cryptocurrencies added yet'),
                        Text('Tap + to add your first crypto', style: TextStyle(color: Colors.grey)),
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
    final stockAssets = _box.values.where((asset) => asset.type == AssetType.stock);
    
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
                  final asset = Asset(symbol.toUpperCase(), 1.0, 0.0, AssetType.stock, 'USD');
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
          if (_isLoading)
            const LinearProgressIndicator(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _box.listenable(),
              builder: (context, Box<Asset> box, _) {
                final stockAssets = box.values.where((asset) => asset.type == AssetType.stock).toList();
                
                if (stockAssets.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.trending_up, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No stocks added yet'),
                        Text('Tap + to add your first stock', style: TextStyle(color: Colors.grey)),
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
  State<CompoundCalculatorScreen> createState() => _CompoundCalculatorScreenState();
}

class _CompoundCalculatorScreenState extends State<CompoundCalculatorScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _amountController = TextEditingController(text: '1000');
  final TextEditingController _rateController = TextEditingController(text: '30');
  final TextEditingController _yearsController = TextEditingController(text: '5');
  String _selectedCurrency = 'USD';
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _result;

  final List<String> _currencies = ['USD', 'BTC', 'ETH', 'MSTR', 'CHF', 'GBP', 'PHP'];

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final amount = double.tryParse(_amountController.text);
      final rate = double.tryParse(_rateController.text);
      final years = int.tryParse(_yearsController.text);

      if (amount == null || amount <= 0) {
        throw Exception('Please enter a valid positive amount');
      }
      if (rate == null || rate < 0) {
        throw Exception('Please enter a valid non-negative rate');
      }
      if (years == null || years <= 0) {
        throw Exception('Please enter a valid positive number of years');
      }

      double futureValue;
      double usdEquivalent;
      double? quantity;

      // Calculate compound growth
      final growthFactor = pow(1 + rate / 100, years);
      futureValue = amount * growthFactor;

      // Handle different currencies
      if (_selectedCurrency == 'USD') {
        usdEquivalent = futureValue;
      } else if (['BTC', 'ETH'].contains(_selectedCurrency)) {
        // Crypto: fetch current price
        final currentPrice = await _apiService.fetchCryptoPrice(_selectedCurrency);
        if (currentPrice == null) {
          throw Exception('Failed to fetch current price for $_selectedCurrency');
        }
        quantity = amount / currentPrice;
        final futurePrice = currentPrice * growthFactor;
        futureValue = quantity * futurePrice;
        usdEquivalent = futureValue;
      } else if (_selectedCurrency == 'MSTR') {
        // Stock: fetch current price
        final currentPrice = await _apiService.fetchStockPrice(_selectedCurrency);
        if (currentPrice == null) {
          throw Exception('Failed to fetch current price for $_selectedCurrency');
        }
        quantity = amount / currentPrice;
        final futurePrice = currentPrice * growthFactor;
        futureValue = quantity * futurePrice;
        usdEquivalent = futureValue;
      } else {
        // Fiat currency: convert to USD
        final exchangeRates = await _apiService.fetchExchangeRates(_selectedCurrency);
        final usdRate = exchangeRates['USD'] ?? 1.0;
        usdEquivalent = futureValue / usdRate;
      }

      setState(() {
        _result = {
          'futureValue': futureValue,
          'usdEquivalent': usdEquivalent,
          'quantity': quantity,
          'currency': _selectedCurrency,
          'amount': amount,
          'rate': rate,
          'years': years,
        };
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              decoration: const InputDecoration(
                labelText: 'Beginning Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rateController,
              decoration: const InputDecoration(
                labelText: 'Annual Growth Rate (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _yearsController,
              decoration: const InputDecoration(
                labelText: 'Number of Years',
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
              items: _currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _calculate,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Calculate'),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 20),
              const Text(
                'Results:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Future Value: ${NumberFormat.currency(symbol: _result!['currency']).format(_result!['futureValue'])}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (_result!['quantity'] != null) ...[
                        Text(
                          'Quantity: ${NumberFormat('#,##0.########').format(_result!['quantity'])} ${_result!['currency']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                      Text(
                        'USD Equivalent: ${NumberFormat.currency(symbol: 'USD').format(_result!['usdEquivalent'])}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Based on ${_result!['amount']} ${_result!['currency']} growing at ${_result!['rate']}% annually for ${_result!['years']} years.',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
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
    final currentPrice = _currentPrices[asset.symbol] ?? (asset.buyPrice / rate);
    return asset.quantity * currentPrice;
  }

  double _getProfit(Asset asset) {
    if (asset.type == AssetType.cash) return 0.0;
    final currentPrice = _currentPrices[asset.symbol];
    if (currentPrice == null) return 0.0;
    final buyPriceInBase = asset.buyPrice / (_exchangeRates[asset.currency] ?? 1.0);
    return (currentPrice - buyPriceInBase) * asset.quantity;
  }

  List<PieChartSectionData> _generatePieSections(List<Asset> assets) {
    final double totalValue = assets.map(_getAssetValue).fold(0.0, (prev, val) => prev + val);
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
      return PieChartSectionData(
        value: value,
        color: color,
        title: '${percentage.toStringAsFixed(0)}%\n${asset.symbol}',
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
                          labelText: type == AssetType.cash ? 'Amount' : 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    if (type != AssetType.cash)
                      TextField(
                        controller: buyPriceController,
                        decoration: const InputDecoration(labelText: 'Buy Price (per unit)'),
                        keyboardType: TextInputType.number,
                      ),
                    TextField(
                      controller: currencyController,
                      decoration: const InputDecoration(labelText: 'Currency (e.g., CHF)'),
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
                final quantity = double.tryParse(quantityController.text) ?? 0.0;
                final buyPrice = double.tryParse(buyPriceController.text) ?? 0.0;
                final currency = currencyController.text.toUpperCase();
                if (symbol.isNotEmpty && quantity > 0) {
                  final asset = Asset(
                    symbol,
                    quantity,
                    type == AssetType.cash ? 1.0 : buyPrice,
                    type,
                    currency,
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
    final quantityController = TextEditingController(text: asset.quantity.toString());
    final buyPriceController = TextEditingController(text: asset.buyPrice.toString());
    final currencyController = TextEditingController(text: asset.currency);
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
                          labelText: type == AssetType.cash ? 'Amount' : 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    if (type != AssetType.cash)
                      TextField(
                        controller: buyPriceController,
                        decoration: const InputDecoration(labelText: 'Buy Price (per unit)'),
                        keyboardType: TextInputType.number,
                      ),
                    TextField(
                      controller: currencyController,
                      decoration: const InputDecoration(labelText: 'Currency (e.g., CHF)'),
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
                final quantity = double.tryParse(quantityController.text) ?? 0.0;
                final buyPrice = double.tryParse(buyPriceController.text) ?? 0.0;
                final currency = currencyController.text.toUpperCase();
                if (symbol.isNotEmpty && quantity > 0) {
                  // Update the existing asset
                  asset.symbol = symbol;
                  asset.quantity = quantity;
                  asset.buyPrice = type == AssetType.cash ? 1.0 : buyPrice;
                  asset.type = type;
                  asset.currency = currency;
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
          if (_isLoading)
            const LinearProgressIndicator(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _box.listenable(),
              builder: (context, Box<Asset> box, _) {
                if (box.values.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Your portfolio is empty'),
                        Text('Tap + to add your first asset', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                
                final double totalValue = box.values
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
                                  sections: _generatePieSections(box.values.toList()),
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
                          itemCount: box.length,
                          itemBuilder: (context, index) {
                            final asset = box.getAt(index)!;
                            final value = _getAssetValue(asset);
                            final profit = _getProfit(asset);
                            final profitColor = profit >= 0 ? Colors.green : Colors.red;
                            return ListTile(
                              title: Text('${asset.symbol.toUpperCase()} (${asset.quantity})'),
                              subtitle: Text(
                                'Value: ${formatCurrency.format(value)}${asset.type != AssetType.cash ? '\nProfit: ${formatCurrency.format(profit)}' : ''}',
                                style: asset.type != AssetType.cash ? TextStyle(color: profitColor) : null,
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