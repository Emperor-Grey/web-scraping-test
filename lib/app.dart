import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:scrap_web/models/anime.dart';
import 'package:scrap_web/pages/details.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  List<Anime> animes = [];
  List<PopularAnime> popularAnimes = [];

  @override
  void initState() {
    super.initState();
    getPopularDataFromWebsite();
    getDataFromWebsite();
  }

  Future getPopularDataFromWebsite() async {
    final mainSite = Uri.parse('https://anitaku.so/popular.html');
    final response = await http.get(mainSite);
    dom.Document document = dom.Document.html(response.body);

    final titles = document
        .querySelectorAll('p.name > a')
        .map((title) => title.attributes['title'] ?? "")
        .toList();

    final imageUrl = document
        .querySelectorAll('div > a > img')
        .skip(1)
        .map((image) => "${image.attributes['src']}")
        .toList();

    setState(() {
      popularAnimes = List.generate(
        titles.length,
        (index) => PopularAnime(
          title: titles[index],
          imageUrl: imageUrl[index],
        ),
      );
    });
  }

  Future getDataFromWebsite() async {
    final siteUrl = Uri.parse('https://anitaku.so/home.html');
    final response = await http.get(siteUrl);
    dom.Document document = dom.Document.html(response.body);

    final titles = document
        .querySelectorAll('p.name > a')
        .map((title) => title.attributes['title']!)
        .toList();

    final imageUrl = document
        .querySelectorAll('div > a > img')
        .skip(1)
        .map((image) => "${image.attributes['src']}")
        .toList();

    final animeUrl = document
        .querySelectorAll('div > a')
        .map((link) => "$siteUrl${link.attributes['href']}")
        .toList();

    setState(() {
      animes = List.generate(
        titles.length,
        (index) => Anime(
          animeUrl: animeUrl[index],
          title: titles[index],
          imageUrl: imageUrl[index],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: Image.asset('assets/images/bg_image.jpg').image,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'Movie Magic Awaits',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.white, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              IconlyLight.search,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              IconlyLight.notification,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              "Popular Now",
              style: GoogleFonts.aBeeZee(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CarouselSlider.builder(
              itemCount: popularAnimes.length,
              itemBuilder: (context, index, realIndex) {
                final popularAnime = popularAnimes[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 310,
                    height: 200,
                    child: Image.network(
                      popularAnime.imageUrl,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: size.height * 0.3,
                autoPlay: true,
                aspectRatio: 16 / 9,
                enlargeCenterPage: true,
                autoPlayAnimationDuration: const Duration(seconds: 2),
                enableInfiniteScroll: true,
                autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
                pageSnapping: true,
                viewportFraction: 0.46,
              ),
            ),
            const SizedBox(height: 26),
            Text(
              "Recent Releases",
              style: GoogleFonts.aBeeZee(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: size.height * 0.3,
              child: ListView.builder(
                itemCount: animes.length,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final anime = animes[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AnimeDetails(anime: anime),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 150,
                              height: size.height * 0.247,
                              child: Image.network(
                                anime.imageUrl,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: anime.title.length > 17
                                      ? "${anime.title.substring(0, anime.title.length - (anime.title.length ~/ 1.5))}..."
                                      : anime.title),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 26),
            Text(
              "Trending Shows",
              style: GoogleFonts.aBeeZee(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            //Just Copy Pasted the above will complete this after things works and maybe encapsulate this too
            SizedBox(
              height: size.height * 0.3,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 150,
                            height: size.height * 0.247,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "title",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
