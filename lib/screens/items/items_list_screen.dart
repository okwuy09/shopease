
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/items_provider.dart';
import '../../widgets/dashboard_item_card.dart';
import 'details_screen.dart';

/// Screen that displays the full list of items.
/// 
/// Features:
/// - Infinite scrolling (pagination) via [ItemsProvider.loadMoreItems].
/// - Local filtering/search functionality.
/// - Pull-to-refresh.
/// - Error and Empty states.
class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen({super.key});

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Listener for scroll events to trigger pagination.
  /// 
  /// Calls [ItemsProvider.loadMoreItems] when the user scrolls near the bottom of the list.
  /// Pagination is disabled if a search query is active (as search is currently local-only).
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Trigger load more when near bottom
      if (_searchQuery.isEmpty) { // Only load more if not searching (local filtering only)
        Provider.of<ItemsProvider>(context, listen: false).loadMoreItems();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Items'),
        centerTitle: true,
      ),
      body: Consumer<ItemsProvider>(
        builder: (context, provider, child) {
          // Filter items based on local search query
          final filteredItems = provider.items.where((item) {
            final query = _searchQuery.toLowerCase();
            return item.title.toLowerCase().contains(query) ||
                   item.body.toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                      suffixIcon: _searchController.text.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                      filled: true,
                      fillColor: Colors.transparent, // Handled by Container
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
              ),

              // List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchItems(),
                  child: Builder(
                    builder: (context) {
                      if (provider.isLoading && provider.items.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Error View
                      if (provider.error != null && provider.items.isEmpty) {
                         return Center(
                           child: Padding(
                             padding: const EdgeInsets.all(24.0),
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Icons.signal_wifi_off_rounded, size: 64, color: Colors.grey[400]),
                                 const SizedBox(height: 16),
                                 Text(
                                   'Oops! Something went wrong.',
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87
                                   ),
                                 ),
                                 const SizedBox(height: 8),
                                 Text(
                                   provider.error!,
                                   textAlign: TextAlign.center,
                                   style: TextStyle(color: Colors.grey[600]),
                                 ),
                                 const SizedBox(height: 24),
                                 ElevatedButton.icon(
                                   onPressed: () => provider.fetchItems(),
                                   icon: const Icon(Icons.refresh),
                                   label: const Text('Retry'),
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: Theme.of(context).primaryColor,
                                     foregroundColor: Colors.white,
                                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         );
                      }

                      if (filteredItems.isEmpty) {
                         // Show empty state
                        return ListView(
                           physics: const AlwaysScrollableScrollPhysics(),
                           children: [
                             Padding(
                               padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
                               child: Center(
                                 child: Column(
                                   children: [
                                     Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                     const SizedBox(height: 16),
                                     Text(
                                       'No items found',
                                       style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                           ],
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filteredItems.length + (provider.hasMore && _searchQuery.isEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredItems.length) {
                             if (provider.hasMore && _searchQuery.isEmpty) {
                               return const Center(
                                 child: Padding(
                                   padding: EdgeInsets.all(16.0),
                                   child: CircularProgressIndicator(),
                                 ),
                               );
                             } else {
                               return const SizedBox.shrink(); 
                             }
                          }

                          final item = filteredItems[index];
                          return DashboardItemCard(
                            item: item,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailsScreen(item: item),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
