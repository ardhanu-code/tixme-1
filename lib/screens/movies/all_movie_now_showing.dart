import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tixme/const/app_color.dart';
import 'package:tixme/screens/movies/details_screen.dart';
import 'package:tixme/screens/movies/book_page.dart';
import 'package:tixme/models/film_model.dart';
import 'package:tixme/services/film_service.dart';

class AllMovieNowShowing extends StatefulWidget {
  const AllMovieNowShowing({super.key});

  @override
  State<AllMovieNowShowing> createState() => _AllMovieNowShowingState();
}

class _AllMovieNowShowingState extends State<AllMovieNowShowing> {
  List<Data> nowPlayingFilms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNowPlayingFilms();
  }

  Future<void> fetchNowPlayingFilms() async {
    try {
      final response = await FilmService().getFilms();
      final List<Data> allFilms = response.data;

      setState(() {
        nowPlayingFilms = allFilms
            .where(
              (film) =>
                  film.stats.toLowerCase().replaceAll(' ', '_') ==
                      'now_showing' ||
                  film.stats.toLowerCase().replaceAll(' ', '_') ==
                      'now_playing',
            )
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching films: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Now Playing',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : nowPlayingFilms.isEmpty
            ? const Center(child: Text('No movies available'))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: nowPlayingFilms.length,
                  itemBuilder: (context, index) {
                    final film = nowPlayingFilms[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsMovie(
                                    posterUrl: film.imageUrl,
                                    movieTitle: film.title,
                                    heroTag: 'all_movies_$index',
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: 'all_movies_$index',
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(film.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          film.title,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookPage(
                                  filmId: film.id,
                                  posterUrl: film.imageUrl,
                                  movieTitle: film.title,
                                  heroTag: 'all_movies_$index',
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            side: BorderSide(color: AppColor.primary),
                            minimumSize: Size(double.infinity, 36),
                          ),
                          child: Text(
                            'Book Now',
                            style: GoogleFonts.lexend(
                              color: AppColor.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
