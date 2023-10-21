import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:scrap_web/models/anime.dart';
import 'package:scrap_web/widgets/video.dart';

class AnimeDetails extends StatefulWidget {
  const AnimeDetails({super.key, required this.anime});

  final Anime anime;

  @override
  State<AnimeDetails> createState() => _AnimeDetailsState();
}

class _AnimeDetailsState extends State<AnimeDetails> {
  String? episodeLink;

  @override
  void initState() {
    super.initState();
    loadEpisode();
  }

  Future loadEpisode() async {
    final url = Uri.parse(widget.anime.animeUrl);
    final response = await http.get(url);
    dom.Document document = dom.Document.html(response.body);

    // Have to scrap episode link but for now just testing things

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VideoPlayerView(
                  // test doodstream link
                  url: 'https://dood.wf/e/pkmo057i6226',
                  dataSourceType: MyDataSourceType.network,
                ),
              ),
            );
          },
          child: const Text('Play Recent Episode'),
        ),
      ),
    );
  }
}
