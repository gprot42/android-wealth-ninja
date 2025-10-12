import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'settings_service.dart';
import 'home_screen.dart';

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
  @HiveField(5)
  String? cashNote;

  Asset(
    this.symbol,
    this.quantity,
    this.buyPrice,
    this.type,
    this.currency, [
    this.cashNote,
  ]);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(AssetAdapter());
  await Hive.openBox<Asset>('watched_assets');
  await Hive.openBox<Asset>('portfolio_assets');

  // Initialize settings service
  final settingsService = SettingsService();
  await settingsService.init();

  runApp(const WealthNinjaApp());
}

class AssetAdapter extends TypeAdapter<Asset> {
  @override
  final int typeId = 0;
  @override
  Asset read(BinaryReader reader) {
    final symbol = reader.readString();
    final quantity = reader.readDouble();
    final buyPrice = reader.readDouble();
    final type = AssetType.values[reader.readInt()];
    final currency = reader.readString();
    String? cashNote;

    if (reader.availableBytes > 0) {
      final hasCashNote = reader.readBool();
      if (hasCashNote && reader.availableBytes > 0) {
        cashNote = reader.readString();
      }
    }

    return Asset(
      symbol,
      quantity,
      buyPrice,
      type,
      currency,
      cashNote,
    );
  }

  @override
  void write(BinaryWriter writer, Asset obj) {
    writer.writeString(obj.symbol);
    writer.writeDouble(obj.quantity);
    writer.writeDouble(obj.buyPrice);
    writer.writeInt(obj.type.index);
    writer.writeString(obj.currency);

    final hasCashNote = (obj.cashNote?.isNotEmpty ?? false);
    writer.writeBool(hasCashNote);
    if (hasCashNote) {
      writer.writeString(obj.cashNote!);
    }
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    // Initialize settings if needed
    _settingsService.init().then((_) {
      Timer(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/splash.jpg',
              fit: BoxFit.contain,
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'Wealth Ninja',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Track your wealth like a ninja',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WealthNinjaApp extends StatefulWidget {
  const WealthNinjaApp({super.key});

  @override
  State<WealthNinjaApp> createState() => _WealthNinjaAppState();
}

class _WealthNinjaAppState extends State<WealthNinjaApp> {
  final SettingsService _settingsService = SettingsService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _settingsService.init();
      // Listen for theme changes
      _settingsService.watchKey('themeMode').listen((event) {
        if (mounted) setState(() {});
      });
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing app: $e');
      // Set as initialized even if there's an error to avoid infinite loading
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show a loading screen while initializing
      return MaterialApp(
        title: 'Wealth Ninja',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    final String themeMode = _settingsService.getThemeMode();

    return MaterialApp(
      title: 'Wealth Ninja',
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
      debugShowCheckedModeBanner: false,
    );
  }
}
