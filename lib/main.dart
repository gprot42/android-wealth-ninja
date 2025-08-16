import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
// Top 200 Crypto Symbol-to-ID Map
const Map<String, String> _cryptoSymbolToIdMap = {
  'BTC': 'bitcoin',
  'ETH': 'ethereum',
  'XRP': 'ripple',
  'USDT': 'tether',
  'BNB': 'binancecoin',
  'SOL': 'solana',
  'USDC': 'usd-coin',
  'STETH': 'staked-ether',
  'DOGE': 'dogecoin',
  'ADA': 'cardano',
  'TRX': 'tron',
  'WSTETH': 'wrapped-steth',
  'HYPE': 'hyperliquid',
  'WBTC': 'wrapped-bitcoin',
  'LINK': 'chainlink',
  'WBETH': 'wrapped-beacon-eth',
  'XLM': 'stellar',
  'SUI': 'sui',
  'WEETH': 'wrapped-eeth',
  'BCH': 'bitcoin-cash',
  'USDE': 'ethena-usde',
  'HBAR': 'hedera-hashgraph',
  'AVAX': 'avalanche-2',
  'WETH': 'weth',
  'LTC': 'litecoin',
  'LEO': 'leo-token',
  'TON': 'the-open-network',
  'USDS': 'usds',
  'SHIB': 'shiba-inu',
  'BSC-USD': 'binance-bridged-usdt-bnb-smart-chain',
  'UNI': 'uniswap',
  'WBT': 'whitebit',
  'CBBTC': 'coinbase-wrapped-btc',
  'DOT': 'polkadot',
  'SUSDE': 'ethena-staked-usde',
  'BGB': 'bitget-token',
  'CRO': 'crypto-com-chain',
  'ENA': 'ethena',
  'PEPE': 'pepe',
  'AAVE': 'aave',
  'XMR': 'monero',
  'MNT': 'mantle',
  'DAI': 'dai',
  'TAO': 'bittensor',
  'ETC': 'ethereum-classic',
  'NEAR': 'near',
  'APT': 'aptos',
  'ONDO': 'ondo-finance',
  'PI': 'pi-network',
  'ICP': 'internet-computer',
  'JITOSOL': 'jito-staked-sol',
  'ARB': 'arbitrum',
  'BUIDL': 'blackrock-usd-institutional-digital-liquidity-fund',
  'KAS': 'kaspa',
  'ALGO': 'algorand',
  'USD1': 'usd1-wlfi',
  'POL': 'polygon-ecosystem-token',
  'GT': 'gatechain-token',
  'VET': 'vechain',
  'ATOM': 'cosmos',
  'RETH': 'rocket-pool-eth',
  'PENGU': 'pudgy-penguins',
  'RENDER': 'render-token',
  'FTN': 'fasttoken',
  'OKB': 'okb',
  'BNSOL': 'binance-staked-sol',
  'SEI': 'sei-network',
  'SUSDS': 'susds',
  'RSETH': 'kelp-dao-restaked-eth',
  'WLD': 'worldcoin-wld',
  'BONK': 'bonk',
  'TRUMP': 'official-trump',
  'FET': 'fetch-ai',
  'JLP': 'jupiter-perpetuals-liquidity-provider-token',
  'FLR': 'flare-networks',
  'IP': 'story-2',
  'FIL': 'filecoin',
  'OSETH': 'stakewise-v3-oseth',
  'KCS': 'kucoin-shares',
  'LSETH': 'liquid-staked-ethereum',
  'USDT0': 'usdt0',
  'SKY': 'sky',
  'QNT': 'quant-network',
  'LBTC': 'lombard-staked-btc',
  'JUP': 'jupiter-exchange-solana',
  'METH': 'mantle-staked-ether',
  'USDTB': 'usdtb',
  'INJ': 'injective-protocol',
  'XDC': 'xdce-crowd-sale',
  'HASH': 'hash-2',
  'NEXO': 'nexo',
  'SPX': 'spx6900',
  'KHYPE': 'kinetic-staked-hype',
  'USDF': 'falcon-finance',
  'EZETH': 'renzo-restaked-eth',
  'TIA': 'celestia',
  'CFX': 'conflux-token',
  'KAIA': 'kaia',
  'PENDLE': 'pendle',
  'XTZ': 'tezos',
  'WIF': 'dogwifcoin',
  'ENS': 'ethereum-name-service',
  'MSOL': 'msol',
  'CGETH.HASHKEY': 'cgeth-hashkey-cloud',
  'THETA': 'theta-token',
  'A': 'vaulta',
  'IOTA': 'iota',
  'JASMY': 'jasmycoin',
  'VIRTUAL': 'virtual-protocol',
  'EETH': 'ether-fi-staked-eth',
  'GALA': 'gala',
  'CMETH': 'mantle-restaked-eth',
  'SAND': 'the-sandbox',
  'OUSG': 'ousg',
  'PYTH': 'pyth-network',
  'M': 'memecore',
  'TBTC': 'tbtc',
  'ETHX': 'stader-ethx',
  'USDX': 'usdx-money-usdx',
  'BTT': 'bittorrent',
  'USDY': 'ondo-us-dollar-yield',
  'RLUSD': 'ripple-usd',
  'JTO': 'jito-governance-token',
  'VSN': 'vision-3',
  'CBETH': 'coinbase-wrapped-staked-eth',
  'MORPHO': 'morpho',
  'FLOW': 'flow',
  'AB': 'newton-project',
  'WAL': 'walrus-2',
  'ZEC': 'zcash',
  'SWETH': 'sweth',
  'BTC.B': 'bitcoin-avalanche-bridged-btc-b',
  'USD0': 'usual-usd',
  'KTA': 'keeta',
  'MANA': 'decentraland',
  'BSV': 'bitcoin-cash-sv',
  'RSR': 'reserve-rights-token',
  'BRETT': 'based-brett',
  'XSOLVBTC': 'solv-protocol-solvbtc-bbn',
  'B': 'build-on',
  'TEL': 'telcoin',
  'BDX': 'beldex',
  'STRK': 'starknet',
  'FRXETH': 'frax-ether',
  'DYDX': 'dydx-chain',
  'USDD': 'usdd',
  'CORE': 'coredaoorg',
  'TUSD': 'true-usd',
  'HNT': 'helium',
  'AIOZ': 'aioz-network',
  'ETHFI': 'ether-fi',
  'APE': 'apecoin',
  'SYRUP': 'syrup',
  'RUNE': 'thorchain',
  'AR': 'arweave',
  'FLUID': 'instadapp',
  'NFT': 'apenft',
  'TRIP': 'trip',
  'SUN': 'sun-token',
  'MOG': 'mog-coin',
  'COMP': 'compound-governance-token',
  'ZK': 'zksync',
  'SUPER': 'superfarm',
  'SDAI': 'savings-dai',
  'NEO': 'neo',
  'XCN': 'chain-2',
  'REKT': 'rekt-4',
  'EIGEN': 'eigenlayer',
};
// Asset types
enum AssetType { stock, crypto, cash }
// Asset model
@HiveType(typeId: 0)
class Asset extends HiveObject {
  @HiveField(0)
  String symbol;
  @HiveField(1)
  double quantity;
  @HiveField(2)
  double buyPrice;
  @HiveField(3)
  AssetType type;
  @HiveField(4)
  String currency;
  Asset(this.symbol, this.quantity, this.buyPrice, this.type, this.currency);
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(AssetAdapter());
  await Hive.openBox<Asset>('watched_assets');
  await Hive.openBox<Asset>('portfolio_assets');
  await Hive.openBox('settings');
  runApp(const PortfolioApp());
}
class AssetAdapter extends TypeAdapter<Asset> {
  @override
  final int typeId = 0;
  @override
  Asset read(BinaryReader reader) {
    return Asset(
      reader.readString(),
      reader.readDouble(),
      reader.readDouble(),
      AssetType.values[reader.readInt()],
      reader.readString(),
    );
  }
  @override
  void write(BinaryWriter writer, Asset obj) {
    writer.writeString(obj.symbol);
    writer.writeDouble(obj.quantity);
    writer.writeDouble(obj.buyPrice);
    writer.writeInt(obj.type.index);
    writer.writeString(obj.currency);
  }
}
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TrackerTabs()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/splash.jpg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key});
  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}
class _PortfolioAppState extends State<PortfolioApp> {
  @override
  void initState() {
    super.initState();
    Hive.box('settings').watch(key: 'themeMode').listen((event) {
      setState(() {});
    });
  }
  @override
  Widget build(BuildContext context) {
    final String themeMode = Hive.box('settings').get('themeMode', defaultValue: 'dark') as String;
    return MaterialApp(
      title: 'Portfolio Tracker',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      themeMode: themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
class TrackerTabs extends StatefulWidget {
  const TrackerTabs({super.key});
  @override
  State<TrackerTabs> createState() => _TrackerTabsState();
}
class _TrackerTabsState extends State<TrackerTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _settingsBox = Hive.box('settings');
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  void _showCurrencyDialog() {
    String currentCurrency = _settingsBox.get('baseCurrency', defaultValue: 'USD') as String;
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
                  _settingsBox.put('baseCurrency', newCurrency);
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
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About Portfolio Tracker'),
          content: const Text(
            'Portfolio Tracker App v1.0\n'
            'Built with Flutter\n'
            'Tracks stocks, cryptocurrencies, and cash assets.\n'
            'Features real-time price updates, portfolio value visualization, '
            'dark/light mode, and currency switching.'
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
        title: const Text('Tracker App'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'theme') {
                String current = _settingsBox.get('themeMode', defaultValue: 'dark') as String;
                String newMode = current == 'dark' ? 'light' : 'dark';
                _settingsBox.put('themeMode', newMode);
              } else if (value == 'currency') {
                _showCurrencyDialog();
              } else if (value == 'about') {
                _showAboutDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'theme', child: Text('Switch Theme')),
              const PopupMenuItem(value: 'currency', child: Text('Change Base Currency')),
              const PopupMenuItem(value: 'about', child: Text('About')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Price Tracker'),
            Tab(text: 'Portfolio Tracker'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PriceTrackerScreen(),
          PortfolioTrackerScreen(),
        ],
      ),
    );
  }
}
// Fetches STOCK prices from Yahoo Finance
Future<double?> _fetchPriceFromYahoo(String symbol) async {
  try {
    final url = Uri.parse('https://query1.finance.yahoo.com/v8/finance/chart/$symbol?range=1d&interval=1m');
    final response = await http.get(url, headers: {'User-Agent': 'Mozilla/5.0'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data['chart']['result'];
      if (result != null && result.isNotEmpty) {
        return result[0]['meta']['regularMarketPrice']?.toDouble();
      }
    } else {
      debugPrint('Yahoo chart API failed: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (e) {
    debugPrint('Error fetching Yahoo price for $symbol: $e');
  }
  return null;
}
// Fetches CRYPTO prices from CoinGecko
Future<double?> _fetchCryptoPriceFromCoinGecko(String coinId) async {
  try {
    final url = Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=$coinId&vs_currencies=usd');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data.isNotEmpty && data[coinId] != null) {
        return data[coinId]['usd']?.toDouble();
      }
    }
  } catch (e) {
    debugPrint('Error fetching CoinGecko price for $coinId: $e');
  }
  return null;
}
class PriceTrackerScreen extends StatefulWidget {
  const PriceTrackerScreen({super.key});
  @override
  State<PriceTrackerScreen> createState() => _PriceTrackerScreenState();
}
class _PriceTrackerScreenState extends State<PriceTrackerScreen> {
  final _box = Hive.box<Asset>('watched_assets');
  final _settingsBox = Hive.box('settings');
  Timer? _timer;
  String _baseCurrency = 'USD';
  Map<String, double> _exchangeRates = {'USD': 1.0};
  Map<String, double> _currentPrices = {};
  @override
  void initState() {
    super.initState();
    _baseCurrency = _settingsBox.get('baseCurrency', defaultValue: 'USD') as String;
    _settingsBox.watch(key: 'baseCurrency').listen((event) {
      setState(() {
        _baseCurrency = _settingsBox.get('baseCurrency', defaultValue: 'USD') as String;
        _fetchExchangeRates().then((_) => _updatePrices());
      });
    });
    _fetchExchangeRates();
    _updatePrices();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updatePrices());
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  Future<void> _fetchExchangeRates() async {
    try {
      final response = await http.get(Uri.parse('https://api.frankfurter.app/latest?from=$_baseCurrency'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _exchangeRates = Map<String, double>.from(data['rates'])
          ..[data['base']] = 1.0);
      } else {
        debugPrint('Exchange rate API failed: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching exchange rates: $e');
    }
  }
  Future<void> _updatePrices() async {
    await _fetchExchangeRates();
    for (var asset in _box.values) {
      double? priceInUsd;
      if (asset.type == AssetType.cash) {
        _currentPrices[asset.symbol] = 1.0;
        continue;
      }
      if (asset.type == AssetType.stock) {
        priceInUsd = await _fetchPriceFromYahoo(asset.symbol);
      } else if (asset.type == AssetType.crypto) {
        String coinId = _cryptoSymbolToIdMap[asset.symbol.toUpperCase()] ?? asset.symbol.toLowerCase();
        priceInUsd = await _fetchCryptoPriceFromCoinGecko(coinId);
      }
      if (priceInUsd != null) {
        final usdRate = _exchangeRates['USD'] ?? 1.0;
        _currentPrices[asset.symbol] = priceInUsd / usdRate;
      }
    }
    setState(() {});
  }
  double _getAssetPrice(Asset asset) {
    final rate = _exchangeRates[asset.currency] ?? 1.0;
    if (asset.type == AssetType.cash) return 1.0 / rate;
    return _currentPrices[asset.symbol] ?? 0;
  }
  void _addAsset() {
    showDialog(
      context: context,
      builder: (context) {
        String symbol = '';
        AssetType type = AssetType.stock;
        return AlertDialog(
          title: const Text('Add Watched Asset'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<AssetType>(
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
                      decoration: InputDecoration(
                        labelText: type == AssetType.crypto
                            ? 'Symbol or CoinGecko ID'
                            : 'Stock Symbol (e.g., AAPL)',
                      ),
                      onChanged: (val) => symbol = val,
                    ),
                  if (type == AssetType.cash)
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Currency (e.g., EUR)'),
                      onChanged: (val) => symbol = val,
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (symbol.isNotEmpty) {
                  final String finalSymbol = (type == AssetType.stock || type == AssetType.cash)
                                              ? symbol.toUpperCase()
                                              : symbol;
                  final asset = Asset(finalSymbol, 1.0, 0.0, type, type == AssetType.cash ? finalSymbol : 'USD');
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
      body: ValueListenableBuilder(
        valueListenable: _box.listenable(),
        builder: (context, Box<Asset> box, _) {
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final asset = box.getAt(index)!;
              final price = _getAssetPrice(asset);
              return ListTile(
                title: Text(
                    '${asset.symbol} (${asset.type.toString().split('.').last})'),
                subtitle: Text(
                    'Current Price: ${price.toStringAsFixed(2)} $_baseCurrency'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => asset.delete(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAsset,
        child: const Icon(Icons.add),
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
  final _settingsBox = Hive.box('settings');
  Timer? _timer;
  String _baseCurrency = 'USD';
  Map<String, double> _exchangeRates = {'USD': 1.0};
  Map<String, double> _currentPrices = {};
  @override
  void initState() {
    super.initState();
    _baseCurrency = _settingsBox.get('baseCurrency', defaultValue: 'USD') as String;
    _settingsBox.watch(key: 'baseCurrency').listen((event) {
      setState(() {
        _baseCurrency = _settingsBox.get('baseCurrency', defaultValue: 'USD') as String;
        _fetchExchangeRates().then((_) => _updatePrices());
      });
    });
    _fetchExchangeRates();
    _updatePrices();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updatePrices());
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  Future<void> _fetchExchangeRates() async {
    try {
      final response = await http.get(Uri.parse('https://api.frankfurter.app/latest?from=$_baseCurrency'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _exchangeRates = Map<String, double>.from(data['rates'])
          ..[data['base']] = 1.0);
      } else {
        debugPrint('Exchange rate API failed: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching exchange rates: $e');
    }
  }
  Future<void> _updatePrices() async {
    await _fetchExchangeRates();
    for (var asset in _box.values) {
      double? priceInUsd;
      if (asset.type == AssetType.cash) {
        _currentPrices[asset.symbol] = 1.0;
        continue;
      }
      if (asset.type == AssetType.stock) {
        priceInUsd = await _fetchPriceFromYahoo(asset.symbol);
      } else if (asset.type == AssetType.crypto) {
        String coinId = _cryptoSymbolToIdMap[asset.symbol.toUpperCase()] ?? asset.symbol.toLowerCase();
        priceInUsd = await _fetchCryptoPriceFromCoinGecko(coinId);
      }
      if (priceInUsd != null) {
        final usdRate = _exchangeRates['USD'] ?? 1.0;
        _currentPrices[asset.symbol] = priceInUsd / usdRate;
      }
    }
    setState(() {});
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
    if (currentPrice == null)
      return 0.0;
    final buyPriceInBase =
        asset.buyPrice / (_exchangeRates[asset.currency] ?? 1.0);
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
                          labelText:
                              type == AssetType.cash ? 'Amount' : 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    if (type != AssetType.cash)
                      TextField(
                        controller: buyPriceController,
                        decoration:
                            const InputDecoration(labelText: 'Buy Price (per unit)'),
                        keyboardType: TextInputType.number,
                      ),
                    TextField(
                      controller: currencyController,
                      decoration:
                          const InputDecoration(labelText: 'Currency (e.g., CHF)'),
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
                } else { // For crypto, save what the user typed (could be 'BTC' or 'my-coin-id')
                  symbol = symbolController.text;
                }
                final quantity =
                    double.tryParse(quantityController.text) ?? 0.0;
                final buyPrice =
                    double.tryParse(buyPriceController.text) ?? 0.0;
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
  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(name: _baseCurrency);
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: _box.listenable(),
        builder: (context, Box<Asset> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('Add an asset to your portfolio.'));
          }
          final double totalValue = box.values
              .map((asset) => _getAssetValue(asset))
              .fold(0.0, (prev, val) => prev + val);
          return Column(
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
                      title: Text('${asset.symbol} (${asset.quantity})'),
                      subtitle: Text(
                        'Value: ${formatCurrency.format(value)}${asset.type != AssetType.cash ? '\nProfit: ${formatCurrency.format(profit)}' : ''}',
                        style: asset.type != AssetType.cash ? TextStyle(color: profitColor) : null,
                      ),
                      isThreeLine: asset.type != AssetType.cash,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => asset.delete(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAsset,
        child: const Icon(Icons.add),
      ),
    );
  }
}
