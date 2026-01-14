import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';

/// The user profile screen.
/// 
/// Displays user information, statistics, and settings options.
/// Features a custom gradient background and glassmorphism UI elements.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: isDark 
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0D332D), Color(0xFF141414)],
                    stops: [0.0, 0.4],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE0F2F1), Color(0xFFF5F5F5)],
                    stops: [0.0, 0.4],
                  ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16), // Reduced padding
              child: Column(
                children: [
                   // 2. Profile Header with Glow
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 90, // Reduced from 110
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.4),
                                blurRadius: 15, // Significantly reduced glow
                                spreadRadius: 1, // Minimal spread
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 80, // Reduced from 100
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: user?.avatarUrl != null
                                ? DecorationImage(image: NetworkImage(user!.avatarUrl!), fit: BoxFit.cover)
                                : null,
                            color: Colors.grey[800],
                          ),
                          child: user?.avatarUrl == null
                              ? const Icon(Icons.person, size: 40, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced spacing
                  
                  Text(
                    user?.name ?? 'Guest User',
                    style: TextStyle(
                      fontSize: 22, // Reduced font size
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    user?.email ?? 'No Email',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced spacing
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced padding
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      'Edit Profile', 
                      style: TextStyle(
                        color: Theme.of(context).primaryColor, 
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24), // Reduced from 32

                  // 3. Stats Row
                  Row(
                    children: [
                      _buildStatCard(context, '12', 'Orders', Icons.shopping_bag_outlined),
                      const SizedBox(width: 12),
                      _buildStatCard(context, '5', 'Reviews', Icons.star_border),
                      const SizedBox(width: 12),
                      _buildStatCard(context, 'Active', 'Status', Icons.check_circle_outline),
                    ],
                  ),

                  const SizedBox(height: 24), // Reduced from 32

                  // 4. Menu Sections
                  _buildSectionHeader(context, 'Settings'),
                  _buildMenuContainer(context, [
                    // Theme Toggle
                     SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(6), // Reduced padding
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.purple, size: 18),
                      ),
                      title: Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                      value: themeProvider.isDarkMode,
                      onChanged: (val) => themeProvider.toggleTheme(val),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      dense: true, // Make list tile denser
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(context, Icons.language, 'Language', 'English', Colors.blue),
                  ]),

                  const SizedBox(height: 16), // Reduced from 24
                  
                  _buildSectionHeader(context, 'Account'),
                  _buildMenuContainer(context, [
                    _buildMenuItem(context, Icons.credit_card, 'Payment Methods', '', Colors.orange),
                    _buildDivider(isDark),
                    _buildMenuItem(context, Icons.location_on_outlined, 'Address', '', Colors.red),
                    _buildDivider(isDark),
                    _buildMenuItem(context, Icons.notifications_outlined, 'Notifications', 'On', Colors.teal),
                  ]),

                  const SizedBox(height: 24), // Reduced

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                         Provider.of<AuthProvider>(context, listen: false).logout();
                         Navigator.of(context).pushAndRemoveUntil(
                           MaterialPageRoute(builder: (_) => const LoginScreen()),
                           (route) => false,
                         );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12), // Reduced padding
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4), // Reduced bottom padding
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(), 
          style: TextStyle(
            fontSize: 11, // Reduced font size
            fontWeight: FontWeight.bold, 
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  /// Builds a glassmorphic container for menu items.
  Widget _buildMenuContainer(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16), // Reduced radius
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15, // Reduced blur
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String trailing, Color iconColor) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
     return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), // Compact padding
      dense: true, // Make list tile denser
      leading: Container(
        padding: const EdgeInsets.all(6), // Reduced padding
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title, 
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing.isNotEmpty) 
            Text(trailing, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          if (trailing.isNotEmpty) const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, thickness: 1, color: isDark ? Colors.white10 : Colors.grey[100]);
  }

  /// Builds a statistic card with an icon and value.
  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8), // Further reduced padding for smaller height
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
           boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12, 
                color: isDark ? Colors.grey[400] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
