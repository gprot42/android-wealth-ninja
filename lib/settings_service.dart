import 'package:hive_flutter/hive_flutter.dart';

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
    return _settingsBox.get('baseCurrency', defaultValue: 'CHF') as String;
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
}