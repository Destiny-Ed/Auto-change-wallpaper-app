

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<File?> converUrlToFile(String url) async {
  try {
    final response = await http.get(Uri.parse(url));

    final documentDirectory = await getApplicationDocumentsDirectory();

    final file = File("${documentDirectory.path}/${url.split('/').last}");

    file.writeAsBytes(response.bodyBytes);

    return file;
  } catch (e) {
    return null;
  }
}
