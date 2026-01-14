
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/constants.dart';

/// Service class responsible for handing API interactions.
class ApiService {
  
  /// Fetches a list of items from the backend API.
  /// 
  /// The [start] and [limit] parameters allow for pagination (currently not implemented in backend).
  /// 
  /// Throws:
  /// - [Exception] with 'No internet connection' on [SocketException].
  /// - [Exception] with 'Connection timed out' on [TimeoutException].
  /// - [Exception] with specific server error codes for non-200 responses.
  /// - [Exception] for malformed JSON or other unexpected errors.
  Future<List<ItemModel>> fetchItems({int start = 0, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiUrl}/products'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        try {
          List<dynamic> body = jsonDecode(response.body);
          return body.map((dynamic item) => ItemModel.fromJson(item)).toList();
        } catch (e) {
          throw Exception('Failed to process data from server.');
        }
      } else {
        throw Exception('Server error (Error Code: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your settings.');
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  
  /// Creates a new item on the server.
  /// 
  /// Takes an [ItemModel] as input and returns the created item (with server-assigned ID).
  /// 
  /// Throws:
  /// - [Exception] with 'No internet connection' on [SocketException].
  /// - [Exception] with 'Request timed out' on [TimeoutException].
  /// - [Exception] if the server returns a non-200/201 status code.
  Future<ItemModel> createItem(ItemModel item) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiUrl}/products'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(item.toJson()),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ItemModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create item (Code: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timed out.');
    } catch (e) {
      throw Exception('Error creating item. Please try again.');
    }
  }
  
  /// Updates an existing item on the server.
  /// 
  /// Takes an [ItemModel] which must have a valid `id`.
  /// 
  /// Throws:
  /// - [Exception] with 'No internet connection' on [SocketException].
  /// - [Exception] with 'Request timed out' on [TimeoutException].
  /// - [Exception] if the server returns a non-200 status code.
  Future<ItemModel> updateItem(ItemModel item) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.apiUrl}/products/${item.id}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(item.toJson()),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return item; 
      } else {
        throw Exception('Failed to update item (Code: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('Request timed out.');
    } catch (e) {
      throw Exception('Error updating item. Please try again.');
    }
  }
}
