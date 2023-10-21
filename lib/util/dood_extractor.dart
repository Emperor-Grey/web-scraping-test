import 'package:http/http.dart' as http;

class DoodExtractor {
  // Function to extract video details from a Doodstream URL.
  Future<Map<String, dynamic>> videoFromUrl(String url) async {
    try {
      // Send an HTTP GET request to the provided URL.
      final response = await http.get(Uri.parse(url));
      final newUrl = response.request!.url.toString();

      // Extract the Doodstream host from the URL.
      final doodHost = Uri.parse(newUrl).host;
      final content = response.body;

      // Check if the content contains a specific string.
      if (!content.contains("'/pass_md5/"))
        // ignore: curly_braces_in_flow_control_structures
        return {"error": "Invalid Doodstream URL"};

      // Extract the MD5 hash and token from the content.
      final md5 = content.split("'/pass_md5/")[1].split("',")[0];
      final token = md5.split("/").last;
      final randomString = getRandomString();
      final expiry = DateTime.now().millisecondsSinceEpoch;

      // Construct the final video URL.
      final videoUrlStartResponse =
          await http.get(Uri.parse("https://$doodHost/pass_md5/$md5"));
      final videoUrlStart = videoUrlStartResponse.body;
      final videoUrl =
          "$videoUrlStart$randomString?token=$token&expiry=$expiry";

      // Create a Map with the extracted details.
      final videoDetails = {
        "url": newUrl,
        "quality": "Doodstream",
        "videoUrl": videoUrl,
        "headers": doodHeaders(doodHost),
      };

      return videoDetails;
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  // Generate a random string for URL construction.
  String getRandomString({int length = 10}) {
    const allowedChars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => allowedChars.codeUnitAt(
            DateTime.now().microsecondsSinceEpoch % allowedChars.length),
      ),
    );
  }

  // Define custom headers for the HTTP request.
  Map<String, String> doodHeaders(String host) {
    return {
      "User-Agent": "Aniyomi",
      "Referer": "https://$host/",
    };
  }
}
