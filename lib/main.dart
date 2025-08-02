import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/item.dart';
import 'models/history_entry.dart';
import 'models/sell.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive once
  await Hive.initFlutter();

  // Register adapters only if not registered yet
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ItemAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(HistoryEntryAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SellAdapter());

  // Open Hive boxes
  await Hive.openBox<Item>('items');
  await Hive.openBox<HistoryEntry>('history');
  await Hive.openBox<Sell>('sales');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitrinaApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.amber),
      home: const HomeScreen(),
    );
  }
}
