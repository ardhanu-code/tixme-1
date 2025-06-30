import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tixme/const/app_color.dart';
import 'package:tixme/models/film_model.dart';
import 'package:tixme/screens/admin/admin_page.dart';
import 'package:tixme/screens/movies/all_coming_soon_movie.dart';
import 'package:tixme/screens/movies/all_movie_now_showing.dart';
import 'package:tixme/screens/movies/book_page.dart';
import 'package:tixme/screens/movies/details_screen.dart';
import 'package:tixme/services/film_service.dart';
import 'package:tixme/services/session_service.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  List<Data> nowPlayingFilms = []; //penampung data
  List<Data> comingSoonFilms = []; //penampung data
  bool isLoading = true;

  String _userName = 'User';
  String _userEmail = '';

  final List<String> imageBanner = [
    'https://imageio.forbes.com/blogs-images/scottmendelson/files/2016/02/WHAM_10X15-FirePl_%C6%924.0_MECH-1200x800.jpg?format=jpg&height=600&width=1200&fit=bounds',
    'https://rukminim2.flixcart.com/image/850/1000/l2z26q80/poster/4/r/k/small-yaa-fast-furious-cool-art-effect-movie-poster-original-image72hwzkpexdg.jpeg?q=20&crop=false',
    'https://m.media-amazon.com/images/I/71wtbS6IrLL.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchAndFilterFilms();
  }

  Future<void> _loadUserData() async {
    try {
      final ambilToken = await AuthPreferences.getToken();
      final userName = await AuthPreferences.getUsername();
      final userEmail = await AuthPreferences.getEmail();
      if (mounted) {
        setState(() {
          _userName = userName ?? 'User';
          _userEmail = userEmail ?? '';
          print('DEBUG USERNAME: $userName');
          print('DEBUG EMAIL: $userEmail');
          print('DEBUG TOKEN: $ambilToken'); // tambahkan ini
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> fetchAndFilterFilms() async {
    try {
      final response = await FilmService().getFilms();
      //ini datanya
      final List<Data> allFilms = response.data;

      if (mounted) {
        setState(() {
          //data diatas diambil untuk ditampung dalam
          //variabel penampung
          nowPlayingFilms = allFilms
              .where(
                (film) =>
                    film.stats.toLowerCase().replaceAll(' ', '_') ==
                        'now_showing' ||
                    film.stats.toLowerCase().replaceAll(' ', '_') ==
                        'now_playing',
              )
              .toList();

          comingSoonFilms = allFilms
              .where(
                (film) =>
                    film.stats.toLowerCase().replaceAll(' ', '_') ==
                    'coming_soon',
              )
              .toList();

          isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to fetch films: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColor.primary),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildUserHeader(),
                    const SizedBox(height: 14),
                    _buildCarouselBanner(),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Now Playing', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AllMovieNowShowing()),
                      ).then((_) {
                        if (mounted) {
                          fetchAndFilterFilms();
                        }
                      });
                    }),
                    _buildMovieList(nowPlayingFilms, 'now_playing'),
                    const SizedBox(height: 8),
                    _buildSectionHeader('Coming Soon', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AllComingSoonMovie()),
                      ).then((_) {
                        if (mounted) {
                          fetchAndFilterFilms();
                        }
                      });
                    }),
                    _buildMovieList(comingSoonFilms, 'coming_soon'),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Row(
        children: [
          const SizedBox(width: 18),
          const CircleAvatar(radius: 26, child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userName,
                style: GoogleFonts.lexend(fontWeight: FontWeight.w500),
              ),
              Text(
                _userEmail,
                style: GoogleFonts.lexend(fontWeight: FontWeight.w200),
              ),
            ],
          ),
          const Spacer(),
          _buildIconBtn(Icons.notifications_on_outlined, () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'This fiture isn\'t available, wait for version update!',
                ),
                backgroundColor: Colors.amber[800],
              ),
            );
          }),
          const SizedBox(width: 8),
          _buildIconBtn(Icons.admin_panel_settings_outlined, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminDashboardScreen()),
            ).then((_) {
              if (mounted) {
                fetchAndFilterFilms();
              }
            });
          }),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap) {
    return Container(
      width: 45,
      height: 45,
      decoration: const ShapeDecoration(
        shape: OvalBorder(side: BorderSide(color: Colors.black26)),
      ),
      child: IconButton(onPressed: onTap, icon: Icon(icon)),
    );
  }

  Widget _buildCarouselBanner() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 220,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 1.0, // Full width, no side items
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
      items: imageBanner.map((url) => _buildImageBanner(url)).toList(),
    );
  }

  Widget _buildImageBanner(String url) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(url, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: onTap,
                child: Text(
                  'View All',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: AppColor.primary,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColor.primary,
                size: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMovieList(List<Data> films, String tagPrefix) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SizedBox(
        height: 340,
        child: PageView.builder(
          padEnds: false,
          itemCount: films.length,
          controller: PageController(viewportFraction: 0.5),
          itemBuilder: (context, index) =>
              _buildMovieCard(films[index], index, tagPrefix),
        ),
      ),
    );
  }

  Widget _buildMovieCard(Data film, int index, String tagPrefix) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailsMovie(
                    posterUrl: film.imageUrl,
                    movieTitle: film.title,
                    heroTag: '${tagPrefix}_$index',
                  ),
                ),
              ).then((_) {
                if (mounted) {
                  fetchAndFilterFilms();
                }
              });
            },
            child: Hero(
              tag: '${tagPrefix}_$index',
              child: Container(
                width: 120,
                height: 240,
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
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            film.title,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              if (tagPrefix == 'coming_soon') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Coming soon!'),
                    backgroundColor: AppColor.primary,
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookPage(
                      filmId: film.id,
                      posterUrl: film.imageUrl,
                      movieTitle: film.title,
                      heroTag: '${tagPrefix}_$index',
                    ),
                  ),
                ).then((_) {
                  if (mounted) {
                    fetchAndFilterFilms();
                  }
                });
              }
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: const BorderSide(color: AppColor.primary),
            ),
            child: Text(
              tagPrefix == 'coming_soon' ? 'Notify Me' : 'Book Now',
              style: GoogleFonts.lexend(
                color: AppColor.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
