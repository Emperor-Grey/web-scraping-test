class Anime {
  final String title;
  final String imageUrl;
  final String animeUrl;

  Anime({
    required this.animeUrl,
    required this.title,
    required this.imageUrl,
  });
}
// i know i use two models i can just use one i probably will do that but in future
class PopularAnime {
  final String title;
  final String imageUrl;

  PopularAnime({
    required this.title,
    required this.imageUrl,
  });
}
