import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tixme/const/app_color.dart';
import 'package:tixme/services/ticket_service.dart';
import 'package:tixme/services/schedule_service.dart';
import 'package:tixme/services/session_service.dart';
import 'package:tixme/models/schedule_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookPage extends StatefulWidget {
  final String movieTitle;
  final String posterUrl;
  final String heroTag;
  final int filmId;

  const BookPage({
    super.key,
    required this.movieTitle,
    required this.posterUrl,
    required this.heroTag,
    required this.filmId,
  });

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  String? _selectedDate;
  String? _selectedTime;
  String? _selectedCinema;
  int _ticketQuantity = 1;
  bool _isLoading = false;
  bool _isLoadingSchedules = false;
  final TicketService _ticketService = TicketService();
  final ScheduleService _scheduleService = ScheduleService();

  List<String> _availableDates = [];
  List<String> _availableTimes = [];
  List<String> _availableCinemas = [
    'CGV Central Park',
    'XXI Mall Taman Anggrek',
    'Cinema 21 Grand Indonesia',
    'Plaza Senayan XXI',
  ];

  List<ScheduleData> _allSchedules = [];

  @override
  void initState() {
    super.initState();
    _loadCinemasFromLocal();
    _loadSchedulesFromAPI();
  }

  Future<void> _loadCinemasFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final cinemas = prefs.getStringList('cinemas') ?? _availableCinemas;
    setState(() {
      _availableCinemas = cinemas;
      _selectedCinema = cinemas.isNotEmpty ? cinemas[0] : null;
    });
  }

  Future<void> _loadSchedulesFromAPI() async {
    setState(() => _isLoadingSchedules = true);

    try {
      // Get token first
      String? token = await AuthPreferences.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      print('Loading schedules for film ID: ${widget.filmId}');
      final schedules = await _scheduleService.getSchedulesByFilmId(
        widget.filmId,
        token,
      );

      print('Received ${schedules.length} schedules');

      if (mounted) {
        if (schedules.isNotEmpty) {
          _allSchedules = schedules;

          // Extract unique dates and times
          final dates = <String>{};
          final times = <String>{};

          for (final schedule in _allSchedules) {
            final dateStr =
                '${schedule.startTime.year}-${schedule.startTime.month.toString().padLeft(2, '0')}-${schedule.startTime.day.toString().padLeft(2, '0')}';
            final timeStr =
                '${schedule.startTime.hour.toString().padLeft(2, '0')}:${schedule.startTime.minute.toString().padLeft(2, '0')}';

            dates.add(dateStr);
            times.add(timeStr);
          }

          setState(() {
            _availableDates = dates.toList()..sort();
            _availableTimes = times.toList()..sort();

            if (_availableDates.isNotEmpty) {
              _selectedDate = _availableDates[0];
            }
            if (_availableTimes.isNotEmpty) {
              _selectedTime = _availableTimes[0];
            }
          });

          print('Available dates: $_availableDates');
          print('Available times: $_availableTimes');
        } else {
          // Show message when no schedules available
          setState(() {
            _availableDates = [];
            _availableTimes = [];
            _selectedDate = null;
            _selectedTime = null;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No schedules available for this movie'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error loading schedules: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load schedules: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingSchedules = false);
      }
    }
  }

  Future<void> _bookTicket() async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _selectedCinema == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? token = await AuthPreferences.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      // Temukan schedule yang cocok
      ScheduleData? selectedSchedule;
      for (final schedule in _allSchedules) {
        final dateStr =
            '${schedule.startTime.year}-${schedule.startTime.month.toString().padLeft(2, '0')}-${schedule.startTime.day.toString().padLeft(2, '0')}';
        final timeStr =
            '${schedule.startTime.hour.toString().padLeft(2, '0')}:${schedule.startTime.minute.toString().padLeft(2, '0')}';
        if (dateStr == _selectedDate && timeStr == _selectedTime) {
          selectedSchedule = schedule;
          break;
        }
      }
      if (selectedSchedule == null) {
        throw Exception('Selected schedule not found');
      }

      // Simpan data lain ke local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_cinema', _selectedCinema!);
      await prefs.setInt('last_quantity', _ticketQuantity);

      // POST hanya schedule_id dan quantity
      await _ticketService.bookTicket(
        scheduleId: selectedSchedule.id,
        quantity: _ticketQuantity,
        token: token,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ticket booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book ticket: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Book Ticket',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColor.primary,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      if (_isLoadingSchedules)
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColor.primary,
                              ),
                            ),
                          ),
                        )
                      else if (_availableDates.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No schedules available',
                                  style: GoogleFonts.lexend(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Please check back later for available showtimes',
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Select Date'),
                              SizedBox(height: 12),
                              _buildHorizontalChips(
                                _availableDates,
                                _selectedDate,
                                (val) => setState(() => _selectedDate = val),
                                _formatDate,
                              ),

                              SizedBox(height: 24),
                              _buildSectionTitle('Select Cinema'),
                              SizedBox(height: 12),
                              _buildCinemaDropdown(),

                              SizedBox(height: 24),
                              _buildSectionTitle('Select Time'),
                              SizedBox(height: 12),
                              _buildHorizontalChips(
                                _availableTimes,
                                _selectedTime,
                                (val) => setState(() => _selectedTime = val),
                              ),

                              SizedBox(height: 24),
                              _buildSectionTitle('Number of Tickets'),
                              SizedBox(height: 12),
                              _buildTicketQuantitySelector(),

                              SizedBox(height: 32),

                              SizedBox(height: 24),
                              _buildBookButton(),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primary.withOpacity(0.8)],
        ),
      ),
      child: Row(
        children: [
          Hero(
            tag: widget.heroTag,
            child: Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.movie, color: Colors.grey[600], size: 40),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.movieTitle,
                  style: GoogleFonts.lexend(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Select your preferred showtime and cinema',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lexend(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildHorizontalChips(
    List<String> items,
    String? selected,
    Function(String) onSelect, [
    String Function(String)? formatter,
  ]) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selected == item;
          return Container(
            margin: EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onSelect(item),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColor.primary
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  formatter != null ? formatter(item) : item,
                  style: GoogleFonts.lexend(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCinemaDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCinema,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _availableCinemas.map((cinema) {
        return DropdownMenuItem(
          value: cinema,
          child: Text(
            cinema,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCinema = value),
    );
  }

  Widget _buildTicketQuantitySelector() {
    return Row(
      children: [
        Icon(Icons.confirmation_number, color: AppColor.primary),
        SizedBox(width: 12),
        Text(
          'Quantity',
          style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Spacer(),
        _buildCounterButton(
          Icons.remove,
          _ticketQuantity > 1,
          () => setState(() => _ticketQuantity--),
        ),
        SizedBox(width: 16),
        Text(
          '$_ticketQuantity',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.primary,
          ),
        ),
        SizedBox(width: 16),
        _buildCounterButton(
          Icons.add,
          _ticketQuantity < 10,
          () => setState(() => _ticketQuantity++),
        ),
      ],
    );
  }

  Widget _buildCounterButton(
    IconData icon,
    bool enabled,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? AppColor.primary : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(
          icon,
          color: enabled ? Colors.white : Colors.grey[600],
          size: 20,
        ),
        constraints: BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _bookTicket,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Book Ticket',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    if (parts.length == 3) {
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final monthIndex = int.parse(parts[1]) - 1;
      return '${parts[2]} ${monthNames[monthIndex]}';
    }
    return date;
  }
}
