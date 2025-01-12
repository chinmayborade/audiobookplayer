import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../services/s3_service.dart';
import '../../models/book.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  final S3Service s3Service;

  const HomeScreen({Key? key, required this.s3Service}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Book>> futureBooks;

  @override
  void initState() {
    super.initState();
    futureBooks = widget.s3Service.fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#F5EFE7"),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: HexColor("#F2F9FF"),
        title: const Text(
          'Audiobook Library',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {
              setState(() {
                futureBooks = widget.s3Service.fetchBooks();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: futureBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final book = snapshot.data![index];
                  return Card(
                    shadowColor: HexColor('#1B1833'),
                    color: HexColor('#1B1833'),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 117,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14.0),
                        child: ListTile(
                          leading: SizedBox(
                            width: 50,
                            height: 50,
                            child: CachedNetworkImage(
                              imageUrl: Uri.encodeFull(
                                book.coverUrl!,
                              ),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) {
                                print('Image error for ${book.title}: $error');

                                return const Icon(
                                  Icons.book,
                                  size: 50,
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                          title: Text(
                            book.title,
                            style: TextStyle(
                                color: Colors.white,
                                height: 2,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          subtitle: Text(
                            book.author,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Text(
                            '${book.chapters.length} chapters',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerScreen(book: book),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(
              child: Text('No books found'),
            );
          }
        },
      ),
    );
  }
}
