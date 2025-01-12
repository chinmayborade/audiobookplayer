// lib/main.dart
import 'package:audiobook_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'services/s3_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: "lib/env_folder/.env");
  WidgetsFlutterBinding.ensureInitialized();

  final s3Service = S3Service(
    dotenv.env['AWS_BUCKET_NAME']!,
    bucketName: dotenv.env['AWS_BUCKET_NAME']!,
    region: dotenv.env['AWS_REGION']!,
    accessKey: dotenv.env['AWS_ACCESS_KEY']!,
    secretKey: dotenv.env['AWS_SECRET_KEY']!,
  );

  runApp(MyApp(s3Service: s3Service));
}

class MyApp extends StatelessWidget {
  final S3Service s3Service;

  const MyApp({Key? key, required this.s3Service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audiobook Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(s3Service: s3Service),
    );
  }
}
