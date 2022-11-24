import 'dart:convert';
import 'dart:io';
import 'utils.dart';

class RestClient {
  //TODO: Link to our own api.
  // String urlBase = "http://127.0.0.1:8000/api";
  // String urlBase = "https://cataas.com";
  String urlBase = "https://httpbin.org";

  HttpClient client = HttpClient();

  Uri urlGen(String api) {
    Uri apiUri = Uri.parse(api);
    Uri url = Uri.parse("$urlBase/$apiUri?format=json");
    // Uri url = Uri.parse("$urlBase/$apiUri");
    print("url: '$url'");
    return url;
  }

  HttpClientRequest addHeaders(HttpClientRequest request) {
    request.headers.add("Content-Type", "application/json");
    request.headers.add("Accept", "application/json");
    return request;
  }

  Future<dynamic> retGen(HttpClientResponse response) async {
    int statusCode = response.statusCode;
    print("statusCode: $statusCode");

    if (statusCode == 200 || statusCode == 201) {
      String responseBody = await response.transform(utf8.decoder).join();
      for (String s in splitStringByLength(responseBody, 256)) {
        print(s);
      }
      return jsonDecode(responseBody);
    } else {
      print("Error getting $response");
      return null;
    }
  }

  // GET (receive data)
  Future<dynamic> get(String api) async {
    HttpClientRequest request = await client.getUrl(urlGen(api));
    request = addHeaders(request);
    HttpClientResponse response = await request.close();
    return retGen(response);
  }

  // POST (send data)
  Future<dynamic> post(String api, dynamic object) async {
    HttpClientRequest request = await client.postUrl(urlGen(api));
    request = addHeaders(request);
    request.write(object);
    HttpClientResponse response = await request.close();
    return retGen(response);
  }

  // PUT (update data)
  Future<dynamic> put(String api) async {}

  // DELETE (delete data)
  Future<dynamic> delete(String api) async {}
}
