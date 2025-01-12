import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/book.dart';

class PlayerScreen extends StatefulWidget {
  final Book book;

  const PlayerScreen({Key? key, required this.book}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioPlayer _audioPlayer;
  int currentChapterIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadChapter();
  }

  /// Loads the current chapter's audio URL
  void _loadChapter() async {
    try {
      await _audioPlayer
          .setUrl(widget.book.chapters[currentChapterIndex].audioUrl);
    } catch (e) {
      print('Error loading audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load audio: $e')),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#F5EFE7"),
      appBar: AppBar(
          elevation: 2,
          backgroundColor: HexColor("#F5EFE7"),
          title: Text(widget.book.title,
              style: TextStyle(
                fontSize: 26,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              widget.book.coverUrl!,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.book, size: 200),
            ),
            const SizedBox(height: 20),
            Text(
              widget.book.title,
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              widget.book.author,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            DropdownButton<int>(
              value: currentChapterIndex,
              items: List.generate(
                widget.book.chapters.length,
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text(
                    widget.book.chapters[index].title,
                  ),
                ),
              ),
              onChanged: (index) {
                if (index != null) {
                  setState(() {
                    currentChapterIndex = index;
                    _loadChapter();
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            StreamBuilder<PlayerState>(
              stream: _audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final isPlaying = playerState?.playing ?? false;
                final processingState = playerState?.processingState;

                if (processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering) {
                  return const CircularProgressIndicator();
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: currentChapterIndex > 0
                          ? () {
                              setState(() {
                                currentChapterIndex--;
                                _loadChapter();
                              });
                            }
                          : null,
                    ),
                    IconButton(
                      icon: CircleAvatar(
                          radius: 40.0,
                          backgroundColor: HexColor("#1B1833"),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          )),
                      iconSize: 75.0,
                      onPressed: () {
                        if (isPlaying) {
                          _audioPlayer.pause();
                        } else {
                          _audioPlayer.play();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed:
                          currentChapterIndex < widget.book.chapters.length - 1
                              ? () {
                                  setState(() {
                                    currentChapterIndex++;
                                    _loadChapter();
                                  });
                                }
                              : null,
                    ),
                  ],
                );
              },
            ),
            StreamBuilder<Duration?>(
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = _audioPlayer.duration ?? Duration.zero;

                return Column(
                  children: [
                    Slider(
                      value: position.inSeconds.toDouble(),
                      min: 0.0,
                      max: duration.inSeconds
                          .toDouble()
                          .clamp(0.0, double.infinity),
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(position)),
                          Text(_formatDuration(duration)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "${hours != "00" ? "$hours:" : ""}$minutes:$seconds";
  }
}
