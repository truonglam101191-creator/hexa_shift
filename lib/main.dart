import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'features/gameplay/presentation/screens/home_screen.dart';

/// Entry point for Hexa Shift puzzle game.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for best hex grid display
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.scaffoldDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    // ProviderScope is required for Riverpod state management
    const ProviderScope(child: HexaShiftApp()),
  );
}

/// Root widget for Hexa Shift.
class HexaShiftApp extends StatelessWidget {
  const HexaShiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hexa Shift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.scaffoldDark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.tileUp,
          surface: AppColors.surfaceDark,
        ),
        // Premium typography using Outfit from Google Fonts
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
        // Remove default splash/highlight for cleaner tap feedback
        splashFactory: InkSparkle.splashFactory,
      ),
      home: const HomeScreen(),
    );
  }
}
