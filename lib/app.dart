import 'package:flutter/material.dart';

import 'pages/home_page.dart';

class WriterApp extends StatelessWidget {
  const WriterApp({super.key});

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'IBMPlexMono';
    final textTheme = Typography.material2021().black.apply(
      fontFamily: fontFamily,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Story Beat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        fontFamily: fontFamily,
        textTheme: textTheme,
        primaryTextTheme: textTheme,
      ),
      home: const HomePage(),
    );
  }
}
