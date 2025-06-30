import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tixme/const/app_color.dart';
import 'package:tixme/models/film_model.dart';
import 'package:tixme/screens/admin/edit_film_page.dart';
import 'package:tixme/services/film_service.dart';
import 'package:tixme/services/session_service.dart';

class ManageFilmsPage extends StatefulWidget {
  const ManageFilmsPage({Key? key}) : super(key: key);

  @override
  State<ManageFilmsPage> createState() => _ManageFilmsPageState();
}

class _ManageFilmsPageState extends State<ManageFilmsPage> {
  List<Data> _films = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFilms();
  }

  Future<void> _fetchFilms() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await FilmService().getFilms();
      setState(() {
        _films = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load films: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteFilm(String id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final token = await AuthPreferences.getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Token not found. Please login again."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      await FilmService().deleteFilm(int.parse(id), token);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Film deleted successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
      _fetchFilms();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete film: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editFilm(Data film) async {
    final updatedFilm = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditFilmPage(film: film)),
    );
    if (updatedFilm != null) {
      _fetchFilms();
    }
  }

  Widget _buildFilmCard(Data film) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child:
                  film.imageUrl.isNotEmpty
                      ? Image.network(
                        film.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 48),
                              ),
                            ),
                      )
                      : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              film.title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              film.stats == 'now_showing' ? 'Now Showing' : 'Coming Soon',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _editFilm(film),
                    label: const Text("Edit"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      textStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : () => showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text("Delete Film"),
                                    content: const Text(
                                      "Are you sure you want to delete this film?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteFilm(film.id.toString());
                                        },
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                    label: const Text("Delete"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      textStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manage Films",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColor.primary,
                          ),
                        )
                        : _films.isEmpty
                        ? Center(
                          child: Text(
                            "No films found.",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                        : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.68,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                          itemCount: _films.length,
                          itemBuilder: (context, index) {
                            return _buildFilmCard(_films[index]);
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
