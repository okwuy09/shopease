
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/items_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

/// The entry point of the application.
void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
/// 
/// Sets up the [MultiProvider] for state management and defines both Light and Dark themes.
/// Consumes [ThemeProvider] to toggle between theme modes.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom Colors from the reference image
    const primaryGreen = Color(0xFF0F9D58); // Approx Google Green / Vibrant Green
    const darkBackground = Color(0xFF141414); // Very dark, almost black
    const surfaceColor = Color(0xFF1F1F1F); // Slightly lighter for cards
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Dark Theme Definition
          final darkTheme = ThemeData.dark().copyWith(
            scaffoldBackgroundColor: darkBackground,
            primaryColor: primaryGreen,
            colorScheme: const ColorScheme.dark(
              primary: primaryGreen,
              surface: surfaceColor,
              onSurface: Colors.white,
              secondary: Color(0xFFEAB308),
            ),
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
            cardColor: surfaceColor,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: surfaceColor,
              selectedItemColor: primaryGreen,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
            ),
          );

          // Light Theme Definition
          final lightTheme = ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            primaryColor: primaryGreen,
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              surface: Colors.white,
              onSurface: Colors.black87,
              secondary: Color(0xFFEAB308),
            ),
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              iconTheme: IconThemeData(color: Colors.black87),
              titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: primaryGreen,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 10,
            ),
          );

          return MaterialApp(
            title: 'Shopease',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: lightTheme,
            darkTheme: darkTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
