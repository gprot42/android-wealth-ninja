import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();
  
  late Box _settingsBox;
  
  // Initialize settings box
  Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
  }
  
  // Theme settings
  String getThemeMode() {
    return _settingsBox.get('themeMode', defaultValue: 'dark') as String;
  }
  
  Future<void> setThemeMode(String mode) async {
    await _settingsBox.put('themeMode', mode);
  }
  
  // Currency settings
  String getBaseCurrency() {
    return _settingsBox.get('baseCurrency', defaultValue: 'USD') as String;
  }
  
  Future<void> setBaseCurrency(String currency) async {
    await _settingsBox.put('baseCurrency', currency);
  }
  
  // Cache duration settings (in seconds)
  int getCacheDuration() {
    return _settingsBox.get('cacheDuration', defaultValue: 60) as int;
  }
  
  Future<void> setCacheDuration(int seconds) async {
    await _settingsBox.put('cacheDuration', seconds);
  }
  
  // Auto-refresh settings
  bool getAutoRefreshEnabled() {
    return _settingsBox.get('autoRefreshEnabled', defaultValue: true) as bool;
  }
  
  Future<void> setAutoRefreshEnabled(bool enabled) async {
    await _settingsBox.put('autoRefreshEnabled', enabled);
  }
  
  // Refresh interval settings (in minutes)
  int getRefreshInterval() {
    return _settingsBox.get('refreshInterval', defaultValue: 1) as int;
  }
  
  Future<void> setRefreshInterval(int minutes) async {
    await _settingsBox.put('refreshInterval', minutes);
  }
  
  // Watchlist settings
  List<String> getWatchlistOrder() {
    return List<String>.from(_settingsBox.get('watchlistOrder', defaultValue: <String>[]) as List);
  }
  
  Future<void> setWatchlistOrder(List<String> order) async {
    await _settingsBox.put('watchlistOrder', order);
  }
  
  // Portfolio settings
  List<String> getPortfolioOrder() {
    return List<String>.from(_settingsBox.get('portfolioOrder', defaultValue: <String>[]) as List);
  }
  
  Future<void> setPortfolioOrder(List<String> order) async {
    await _settingsBox.put('portfolioOrder', order);
  }
  
  // API preference settings
  String getPreferredCryptoAPI() {
    return _settingsBox.get('preferredCryptoAPI', defaultValue: 'coingecko') as String;
  }

  Future<void> setPreferredCryptoAPI(String api) async {
    await _settingsBox.put('preferredCryptoAPI', api);
  }

  // Decimal places settings for crypto prices
  int getCryptoDecimalPlaces() {
    return _settingsBox.get('cryptoDecimalPlaces', defaultValue: 2) as int;
  }

  Future<void> setCryptoDecimalPlaces(int places) async {
    await _settingsBox.put('cryptoDecimalPlaces', places);
  }
  
  // Clear all settings
  Future<void> clearAllSettings() async {
    await _settingsBox.clear();
  }
  
  // Watch for changes to a specific key
  Stream watchKey(String key) {
    return _settingsBox.watch(key: key);
  }

  Map<String, dynamic> exportToJson() {
    return {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': {
        'themeMode': getThemeMode(),
        'baseCurrency': getBaseCurrency(),
        'cacheDuration': getCacheDuration(),
        'autoRefreshEnabled': getAutoRefreshEnabled(),
        'refreshInterval': getRefreshInterval(),
        'watchlistOrder': getWatchlistOrder(),
        'portfolioOrder': getPortfolioOrder(),
        'preferredCryptoAPI': getPreferredCryptoAPI(),
        'cryptoDecimalPlaces': getCryptoDecimalPlaces(),
      },
    };
  }

  static const String defaultConfigFilename = 'wealth_ninja_settings.json';

  Future<String> exportToFile({String? filename}) async {
    final json = exportToJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(json);
    final exportFilename = filename ?? defaultConfigFilename;
    
    String dirPath;
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
      dirPath = '$home/Downloads';
      if (!await Directory(dirPath).exists()) {
        dirPath = (await getApplicationDocumentsDirectory()).path;
      }
    } else {
      dirPath = (await getApplicationDocumentsDirectory()).path;
    }
    
    final file = File('$dirPath/$exportFilename');
    await file.writeAsString(jsonString);
    return file.path;
  }

  Future<String> shareExport() async {
    final filePath = await exportToFile();
    if (Platform.isAndroid || Platform.isIOS) {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Wealth Ninja Backup',
      );
    }
    return filePath;
  }

  Future<bool> importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    
    if (result == null || result.files.isEmpty) {
      return false;
    }

    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    return importFromJson(jsonString);
  }

  Future<bool> importFromJson(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final settings = json['settings'] as Map<String, dynamic>?;
      
      if (settings == null) {
        return false;
      }

      if (settings['themeMode'] != null) {
        await setThemeMode(settings['themeMode'] as String);
      }
      if (settings['baseCurrency'] != null) {
        await setBaseCurrency(settings['baseCurrency'] as String);
      }
      if (settings['cacheDuration'] != null) {
        await setCacheDuration(settings['cacheDuration'] as int);
      }
      if (settings['autoRefreshEnabled'] != null) {
        await setAutoRefreshEnabled(settings['autoRefreshEnabled'] as bool);
      }
      if (settings['refreshInterval'] != null) {
        await setRefreshInterval(settings['refreshInterval'] as int);
      }
      if (settings['watchlistOrder'] != null) {
        await setWatchlistOrder(List<String>.from(settings['watchlistOrder'] as List));
      }
      if (settings['portfolioOrder'] != null) {
        await setPortfolioOrder(List<String>.from(settings['portfolioOrder'] as List));
      }
      if (settings['preferredCryptoAPI'] != null) {
        await setPreferredCryptoAPI(settings['preferredCryptoAPI'] as String);
      }
      if (settings['cryptoDecimalPlaces'] != null) {
        await setCryptoDecimalPlaces(settings['cryptoDecimalPlaces'] as int);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}