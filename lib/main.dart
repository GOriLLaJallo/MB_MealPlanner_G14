import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'providers/app_provider.dart';
import 'utils/theme.dart';
import 'screens/main_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  
  await initializeDateFormatting('it_IT', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const MealPlannerApp(),
    ),
  );
}

class MealPlannerApp extends StatelessWidget {
  const MealPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner & Pantry',
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
