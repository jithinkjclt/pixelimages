import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:imagelister/presentation/homeprovider/provider/homeprovider.dart';
import 'package:provider/provider.dart';
import 'package:imagelister/presentation/home/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await dotenv.load(fileName: "apikey.env");


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          print("✅ HomeProvider initialized");
          return HomeProvider();
        }),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("📱 MyApp built");
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
