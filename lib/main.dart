import 'package:flutter/material.dart';
import 'package:scrap_web/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // //! Testing
  // final extractor = DoodExtractor();
  // const url =
  //     "https://dood.wf/e/pkmo057i6226"; // Replace with the Doodstream URL you want to test

  // final videoDetails = await extractor.videoFromUrl(url);

  // if (videoDetails.containsKey("error")) {
  //   print("Error: ${videoDetails["error"]}");
  // } else {
  //   print("Video URL: ${videoDetails["videoUrl"]}");
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 26, 25, 25),
      ),
      home: const App(),
    );
  }
}
