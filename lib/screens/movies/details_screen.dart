import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tixme/models/film_model.dart';
import 'package:tixme/services/film_service.dart';
import 'package:tixme/services/session_service.dart';

class DetailsMovie extends StatefulWidget {
  final String posterUrl;
  final String movieTitle;
  final String heroTag;

  const DetailsMovie({
    super.key,
    required this.posterUrl,
    required this.movieTitle,
    required this.heroTag,
  });

  @override
  State<DetailsMovie> createState() => _DetailsMovieState();
}

class _DetailsMovieState extends State<DetailsMovie> {
  List<Data> details = [];
  bool isLoading = true;
  Data? selectedMovie;

  String _formatStatus(String? status) {
    if (status == null) return 'N/A';
    switch (status.toLowerCase()) {
      case 'now_playing':
        return 'Now Showing';
      case 'coming_soon':
        return 'Coming Soon';
      default:
        return status;
    }
  }

  Future<void> getDetails() async {
    try {
      //final getToken = await AuthPreferences.getToken();
      final response = await FilmService().getFilms();
      final List<Data> allFilm = response.data;

      // Find the movie that matches the title
      final movie = allFilm.firstWhere(
        (film) => film.title == widget.movieTitle,
        orElse: () => allFilm.first,
      );

      setState(() {
        details = allFilm;
        selectedMovie = movie;
        isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch films: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details', style: GoogleFonts.lexend()),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              setState(() async {
                await getDetails();
              });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(18.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Hero(
                              tag: widget.heroTag,
                              child: Container(
                                height: 220,
                                width: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(widget.posterUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 220,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedMovie?.title ?? widget.movieTitle,
                                    style: GoogleFonts.lexend(fontSize: 24),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    softWrap: true,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Genre: ${selectedMovie?.genre ?? 'N/A'}',
                                    style: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Director: ${selectedMovie?.director ?? 'N/A'}',
                                    style: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Writer: ${selectedMovie?.writer ?? 'N/A'}',
                                    style: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Status: ${_formatStatus(selectedMovie?.stats)}',
                                    style: GoogleFonts.lexend(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Coming Soon!'),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.black12),
                          ),
                          minimumSize: Size(double.infinity, 45),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite, color: Colors.red, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Watchlist',
                              style: GoogleFonts.lexend(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Synopsis',
                                style: GoogleFonts.lexend(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                selectedMovie?.description ??
                                    'Synopsis not available.',
                                textAlign: TextAlign.left,
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
