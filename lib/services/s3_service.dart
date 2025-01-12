import '../models/book.dart';
import 'package:aws_s3_api/s3-2006-03-01.dart' as s3;

class S3Service {
  final String bucketName;
  final String region;
  final String accessKey;
  final String secretKey;

  late s3.S3 _s3Client;

  S3Service(
    String? s, {
    required this.bucketName,
    required this.region,
    required this.accessKey,
    required this.secretKey,
  }) {
    final credentials = s3.AwsClientCredentials(
      accessKey: accessKey,
      secretKey: secretKey,
    );

    _s3Client = s3.S3(
      region: region,
      credentials: credentials,
    );
  }

  Future<List<Book>> fetchBooks() async {
    try {
      final response = await _s3Client.listObjectsV2(
        bucket: bucketName,
        prefix: 'books/',
      );

      if (response.contents == null || response.contents!.isEmpty) {
        throw Exception('No books found in the specified bucket.');
      }

      List<Book> books = [];
      Map<String, List<Chapter>> bookChapters = {};
      for (var object in response.contents!) {
        final key = object.key;
        if (key == null || !key.endsWith('.mp3')) continue;
        final parts = key.split('/');
        if (parts.length < 3) continue;
        final bookTitle = parts[1].replaceAll('-', ' ');
        final chapterFile = parts[2];
        final objectUrl = _buildObjectUrl(key);
        final chapter = Chapter(
          id: chapterFile,
          title: 'Chapter ${chapterFile.split('.')[0]}',
          audioUrl: objectUrl,
          duration: Duration(minutes: 30),
        );

        bookChapters.putIfAbsent(bookTitle, () => []).add(chapter);
      }
      bookChapters.forEach((title, chapters) {
        books.add(Book(
          id: title.toLowerCase().replaceAll(' ', '-'),
          title: title,
          author: 'Author',
          coverUrl: _buildObjectUrl('books/$title/cover.jpg'),
          chapters: chapters,
        ));
      });

      return books;
    } catch (e) {
      print('Error fetching books from S3: $e');
      throw Exception('Failed to fetch books from S3: $e');
    }
  }

  String _buildObjectUrl(String key) {
    final encodedKey = Uri.encodeComponent(key);
    return 'https://$bucketName.s3.eu-north-1.amazonaws.com/$encodedKey';
  }
}
