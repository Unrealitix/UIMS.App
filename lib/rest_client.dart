import 'dart:io';

import 'package:http/http.dart' as http;

typedef Client = http.Client;
typedef Request = http.Request;
typedef Response = http.Response;

class RestClient {
  //TODO: Link to our own api.
  // String urlBase = "http://127.0.0.1:8000/api";
  // String urlBase = "https://cataas.com";
  String urlBase = "https://vanir.mythicalsora.dev/api";

  Map<String, String> headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.acceptHeader: 'application/json',
  };

  Client client = Client();

  Uri urlGen(String api) {
    Uri apiUri = Uri.parse(api);
    Uri url = Uri.parse("$urlBase/$apiUri");
    // Uri url = Uri.parse("$urlBase/$apiUri");
    print("url: '$url'");
    return url;
  }

  String returnResponse(Response response) {
    String responseCode = response.statusCode.toString();
    if (responseCode.startsWith("2")) {
      return response.body;
    } else {
      throw HttpException(responseCode);
    }
  }

  // GET (receive data)
  Future<String> get(String api) async {
    Uri url = urlGen(api);
    Response response = await client.get(url, headers: headers);
    return returnResponse(response);
  }

  // POST (send data)
  Future<dynamic> post(String api, dynamic object) async {
    Uri url = urlGen(api);
    Response response = await client.post(url, headers: headers, body: object);
    return returnResponse(response);
  }

  // PUT (update data)
  Future<dynamic> put(String api) async {}

  // DELETE (delete data)
  Future<dynamic> delete(String api) async {}
}
