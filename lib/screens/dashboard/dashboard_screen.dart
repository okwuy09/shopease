
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/items_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/dashboard_item_card.dart';
import '../items/details_screen.dart';
import '../items/create_update_screen.dart';
import '../items/items_list_screen.dart';
import '../notifications/notification_screen.dart';

/// The main dashboard screen displayed after login.
/// 
/// Shows a welcome message, user stats, and a highlighted list of items.
/// Interacts with [ItemsProvider] to fetch and display data.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule initial data fetch after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemsProvider = Provider.of<ItemsProvider>(context, listen: false);
      if (itemsProvider.items.isEmpty) {
        itemsProvider.fetchItems();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient or Solid Color
          Container(
            decoration: BoxDecoration(
              gradient: isDark 
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0D332D), // Deep Green/Teal at top
                      Color(0xFF141414), // Dark at bottom
                    ],
                    stops: [0.0, 0.4],
                  )
                : const LinearGradient( // Light Mode Gradient
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE0F2F1), // Very light teal
                      Color(0xFFF5F5F5), // White smoke
                    ],
                    stops: [0.0, 0.4],
                  ),
            ),
          ),
          
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await Provider.of<ItemsProvider>(context, listen: false).fetchItems();
              },
              child: CustomScrollView(
                slivers: [
                  // Custom App Bar with User Profile
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4), // Reduced bottom to 4
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final user = auth.user;
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: isDark ? Colors.white.withAlpha(26) : Colors.grey[300],
                              backgroundImage: user?.avatarUrl != null 
                                  ? NetworkImage(user!.avatarUrl!) 
                                  : null,
                              child: user?.avatarUrl == null 
                                  ? Icon(Icons.person, color: isDark ? Colors.white : Colors.grey[700]) 
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  user?.name ?? 'Guest',
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (_) => const NotificationScreen())
                                );
                              },
                              icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : Colors.black87),
                            ),
                          ],
                        );
                      }
                    ),
                  ),
                ),

                  // User Details Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Reduced vertical from 8 to 4
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final user = auth.user;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withAlpha(10) : Colors.white,
                            borderRadius: BorderRadius.circular(12), // Reduced border radius
                            border: Border.all(color: isDark ? Colors.white.withAlpha(20) : Colors.grey[200]!, width: 1), 
                            boxShadow: [
                               BoxShadow(
                                color: isDark ? Colors.black.withAlpha(40) : Colors.black.withAlpha(10), // Softer shadow
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 26, 
                                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                                  backgroundImage: user?.avatarUrl != null 
                                      ? NetworkImage(user!.avatarUrl!) 
                                      : null,
                                  child: user?.avatarUrl == null 
                                      ? Icon(Icons.person, size: 28, color: isDark ? Colors.white70 : Colors.grey[500]) 
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Text Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            user?.name ?? 'Guest User',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isDark ? Colors.white : Colors.black87,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                                          ),
                                          child: Text(
                                            'PRO',
                                            style: TextStyle(
                                              color: Theme.of(context).primaryColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.email ?? 'Sign in to access features',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        fontSize: 13, 
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Arrow Icon for affordance
                              Icon(Icons.chevron_right, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                            ],
                          ),
                        );
                      }
                    ),
                  ),
                ),

                // Items List Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 2), // Reduced vertical from 4 to 2
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ItemsListScreen()),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Items List
                Consumer<ItemsProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    if (provider.error != null && provider.items.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
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
                        ),
                      );
                    }

                    if (provider.items.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No items found. Create one!', 
                            style: TextStyle(color: isDark ? Colors.white : Colors.black54),
                          ),
                        ),
                      );
                    }
                    
                    // Logic: Always show the newest item (index 0) + 4 random others (Total 5)
                    final allItems = provider.items;
                    final newestItem = allItems.first;
                    final otherItems = allItems.skip(1).toList();
                    
                    final randomOthers = (otherItems..shuffle()).take(4).toList();
                    final displayItems = [newestItem, ...randomOthers];
                    
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = displayItems[index];
                            return DashboardItemCard(
                              item: item,
                              onTap: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (_) => DetailsScreen(item: item))
                                );
                              },
                            );
                          },
                          childCount: displayItems.length,
                        ),
                      ),
                    );
                  },
                ),
                
                // Bottom Padding for Nav Bar
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
          ),
        ],
      ),

    );
  }
}
