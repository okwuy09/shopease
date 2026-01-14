
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';

/// Provider class for managing the state of items in the application.
/// 
/// Handles fetching, pagination, addition, and updates of items.
/// Mixes in [ChangeNotifier] to notify listeners of state changes.
class ItemsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  /// List of items currently loaded.
  List<ItemModel> _items = [];
  
  /// Loading state for the initial fetch or refresh.
  bool _isLoading = false;
  
  /// Error message, if any operation fails.
  String? _error;

  // Pagination State
  int _page = 0;
  final int _limit = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  
  // Connectivity
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ItemsProvider() {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      // Check if we have any connection (mobile, wifi, ethernet, etc.)
      // and if we are in a state that needs refreshing (error or empty)
      final hasConnection = !results.contains(ConnectivityResult.none);
      if (hasConnection) {
        if (_error != null || _items.isEmpty) {
           debugPrint('Network restored. Retrying fetch...');
           fetchItems();
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  /// Returns the immutable list of items.
  List<ItemModel> get items => _items;
  
  /// Returns true if the initial fetch is in progress.
  bool get isLoading => _isLoading;
  
  /// Returns true if more items are being loaded (pagination).
  bool get isLoadingMore => _isLoadingMore;
  
  /// Returns the current error message, or null if no error.
  String? get error => _error;
  
  /// Returns true if there are likely more items to fetch from the server.
  bool get hasMore => _hasMore;

  /// Fetches the initial batch of items or refreshes the list.
  /// 
  /// Clears existing items and error state before fetching.
  /// Sets [isLoading] to true during the process.
  Future<void> fetchItems() async {
    // If already loading, don't trigger again (loops prevention)
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    _page = 0;
    _hasMore = true;
    // _items = []; // Don't clear immediately on refresh to keep UI stable? 
    // Actually, for pull-to-refresh we usually want to clear or replace.
    // If we're retrying from error, valid cache might be there.
    // Let's decide: If we have items from cache, we keep them until we get new ones.
    // But if we want to show loading spinner properly, notifyListeners is good.
    notifyListeners();

    try {
      final newItems = await _apiService.fetchItems(start: 0, limit: _limit);
      _items = newItems;
      if (newItems.length < _limit) {
        _hasMore = false;
      }
      
      // Cache the fetched items
      await _cacheItems(_items);
      
    } catch (e) {
      // If network fetch fails, try to load from cache
      await _loadFromCache();
      
      // If we still have no items, show the error
      if (_items.isEmpty) {
        _error = e.toString().replaceAll('Exception: ', '');
      } else {
        // We have cached items, so we clear the error to show them
        // Optional: You could set a flag like _isOffline = true to show a banner
        _error = null; 
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads the next page of items.
  /// 
  /// Appends new items to the existing [_items] list.
  /// Does nothing if already loading or if [_hasMore] is false.
  Future<void> loadMoreItems() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final newItems = await _apiService.fetchItems(start: _items.length, limit: _limit);
      
      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _items.addAll(newItems);
        if (newItems.length < _limit) {
          _hasMore = false;
        }
      }
    } catch (e) {
      // For load more, we might show a snackbar instead of full screen error
       _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  /// Adds a new item to the list and the backend.
  /// 
  /// Inserts the new item at the beginning of the local list upon success.
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> addItem(ItemModel item) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final newItem = await _apiService.createItem(item);
      _items.insert(0, newItem); // Add to top of list
      
      // Update cache with new list
      await _cacheItems(_items);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Updates an existing item in the list and the backend.
  /// 
  /// Replaces the item in the local list upon success.
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> updateItem(ItemModel item) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _apiService.updateItem(item);
      final index = _items.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _items[index] = item;
      }
      
      // Update cache
      await _cacheItems(_items);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Helper to save items to SharedPreferences
  Future<void> _cacheItems(List<ItemModel> itemsToCache) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(
        itemsToCache.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('cached_items', encodedData);
    } catch (e) {
      debugPrint('Error caching items: $e');
    }
  }

  /// Helper to load items from SharedPreferences
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('cached_items');
      
      if (cachedData != null) {
        final List<dynamic> decodedList = json.decode(cachedData);
        _items = decodedList.map((itemJson) => ItemModel.fromJson(itemJson)).toList();
        // Since we loaded from cache, we assume there might be more on server, 
        // but for safety we can reset pagination or just leave it.
        // If we treat cache as "page 0", we can leave _page = 0.
      }
    } catch (e) {
      debugPrint('Error loading from cache: $e');
    }
  }
}
