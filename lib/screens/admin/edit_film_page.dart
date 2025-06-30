import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tixme/const/app_color.dart';
import 'package:tixme/services/session_service.dart';

import '../../models/film_model.dart';
import '../../services/film_service.dart';

class EditFilmPage extends StatefulWidget {
  final Data film;
  const EditFilmPage({Key? key, required this.film}) : super(key: key);

  @override
  State<EditFilmPage> createState() => _EditFilmPageState();
}

class _EditFilmPageState extends State<EditFilmPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _genreController;
  late TextEditingController _directorController;
  late TextEditingController _writerController;
  late TextEditingController _statsController;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  File? _selectedImageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.film.title ?? '');
    _descController = TextEditingController(
      text: widget.film.description ?? '',
    );
    _genreController = TextEditingController(text: widget.film.genre ?? '');
    _directorController = TextEditingController(
      text: widget.film.director ?? '',
    );
    _writerController = TextEditingController(text: widget.film.writer ?? '');
    _statsController = TextEditingController(text: widget.film.stats ?? '');
    _imageUrl = widget.film.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _genreController.dispose();
    _directorController.dispose();
    _writerController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _selectedImageFile = File(picked.path);
        // Optionally clear the imageUrl if a new image is picked
        // _imageUrl = null;
      });
    }
  }

  Future<void> _updateFilm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final token = await AuthPreferences.getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _errorMessage = "Token not found. Please login again.";
          _isLoading = false;
        });
        // Show snackbar for error
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

      final response = await FilmService().updateFilm(
        id: widget.film.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        genre: _genreController.text.trim(),
        director: _directorController.text.trim(),
        writer: _writerController.text.trim(),
        stats: _statsController.text.trim(),
        imageUrl: _selectedImageFile == null ? (_imageUrl ?? '') : '',
        imagePath: _selectedImageFile?.path,
        token: token,
      );

      setState(() {
        _successMessage = "Film updated successfully!";
        _isLoading = false;
      });

      // Show snackbar for success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Film updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }

      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.of(context).pop(response.data);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      // Show snackbar for error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update film: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    Widget imageWidget;
    if (_selectedImageFile != null) {
      imageWidget = Image.file(
        _selectedImageFile!,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
      );
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      imageWidget = Image.network(
        _imageUrl!,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              width: double.infinity,
              height: 180,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.broken_image, size: 48)),
            ),
      );
    } else {
      imageWidget = Container(
        width: double.infinity,
        height: 180,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image, size: 48, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _pickImage,
          icon: const Icon(Icons.image),
          label: Text("Choose Image", style: GoogleFonts.poppins()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Film",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildImagePicker(),
                const SizedBox(height: 16),
                _buildTextField(
                  "Title",
                  _titleController,
                  validator:
                      (v) => v == null || v.isEmpty ? "Title required" : null,
                ),
                _buildTextField(
                  "Description",
                  _descController,
                  maxLines: 3,
                  validator:
                      (v) =>
                          v == null || v.isEmpty
                              ? "Description required"
                              : null,
                ),
                _buildTextField(
                  "Genre",
                  _genreController,
                  validator:
                      (v) => v == null || v.isEmpty ? "Genre required" : null,
                ),
                _buildTextField("Director", _directorController),
                _buildTextField("Writer", _writerController),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value:
                      _statsController.text.isNotEmpty
                          ? (_statsController.text.toLowerCase().replaceAll(
                                    ' ',
                                    '_',
                                  ) ==
                                  'now_showing'
                              ? 'now_showing'
                              : (_statsController.text.toLowerCase().replaceAll(
                                        ' ',
                                        '_',
                                      ) ==
                                      'coming_soon'
                                  ? 'coming_soon'
                                  : null))
                          : null,
                  decoration: InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'now_showing',
                      child: Text('Now Showing', style: GoogleFonts.lexend()),
                    ),
                    DropdownMenuItem(
                      value: 'coming_soon',
                      child: Text('Coming Soon', style: GoogleFonts.lexend()),
                    ),
                  ],
                  validator:
                      (v) => v == null || v.isEmpty ? "Status required" : null,
                  onChanged: (value) {
                    if (value != null) {
                      _statsController.text = value;
                    }
                  },
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  ),
                if (_successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _successMessage!,
                      style: GoogleFonts.poppins(color: Colors.green),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateFilm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                            : Text(
                              "Update Film",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
