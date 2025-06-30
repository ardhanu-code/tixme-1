import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tixme/const/app_color.dart';
import 'package:tixme/models/ticket_model.dart';
import 'package:tixme/screens/tickets/update_ticket.dart';
import 'package:tixme/services/session_service.dart';
import 'package:tixme/services/ticket_service.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final TicketService _ticketService = TicketService();
  final TextEditingController _searchController = TextEditingController();

  List<TicketData> _allTickets = [];
  List<TicketData> _filteredTickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
    _searchController.addListener(_filterTickets);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTickets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTickets = _allTickets.where((ticket) {
        return ticket.schedule.film.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);

    try {
      final token = await AuthPreferences.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      print('Loading tickets...');
      final tickets = await _ticketService.getUserTickets(token);
      print('Loaded ${tickets.length} tickets');

      setState(() {
        _allTickets = tickets;
        _filteredTickets = tickets;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading tickets: $e');
      setState(() => _isLoading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat tiket: $e', style: GoogleFonts.lexend()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: Text(
          'My Tickets',
          style: GoogleFonts.lexend(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _loadTickets,
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memuat tiket...',
                    style: GoogleFonts.lexend(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nama film...',
                      hintStyle: GoogleFonts.lexend(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: AppColor.primary),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: GoogleFonts.lexend(),
                  ),
                ),

                // Tickets List
                Expanded(
                  child: _filteredTickets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.confirmation_number_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                _allTickets.isEmpty
                                    ? 'Tidak ada tiket ditemukan'
                                    : 'Tidak ada tiket yang cocok',
                                style: GoogleFonts.lexend(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                _allTickets.isEmpty
                                    ? 'Belum ada tiket yang dibeli'
                                    : 'Coba kata kunci yang berbeda',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                              if (_allTickets.isEmpty) ...[
                                SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Navigate to movie booking page
                                    Navigator.pushNamed(context, '/movies');
                                  },
                                  icon: Icon(Icons.movie),
                                  label: Text(
                                    'Booking Tiket',
                                    style: GoogleFonts.lexend(),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredTickets.length,
                          itemBuilder: (context, index) =>
                              _buildTicketCard(_filteredTickets[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTicketCard(TicketData ticket) {
    final film = ticket.schedule.film;
    final schedule = ticket.schedule;

    return GestureDetector(
      onLongPress: () => _showCancelDialog(ticket),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Movie Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  film.imageUrl,
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 120,
                    color: Colors.grey[300],
                    child: Icon(Icons.movie, color: Colors.grey[600], size: 32),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Ticket Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      film.title,
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColor.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Date: ${_formatDate(schedule.startTime)}',
                    ),
                    _buildInfoRow(
                      Icons.access_time,
                      'Time: ${_formatTime(schedule.startTime)}',
                    ),
                    _buildInfoRow(
                      Icons.confirmation_number,
                      'Quantity: ${ticket.quantity}',
                    ),
                    Text(
                      'Press for action details',
                      style: GoogleFonts.lexend(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(TicketData ticket) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Kelola Tiket',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apa yang ingin kamu lakukan dengan tiket "${ticket.schedule.film.title}"?',
          style: GoogleFonts.lexend(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelTicket(ticket.id);
            },
            child: Text(
              'Batalkan Tiket',
              style: GoogleFonts.lexend(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UpdateTicketScreen(
                    ticketId: ticket.id,
                    currentTicket: ticket,
                  ),
                ),
              );
            },
            child: Text(
              'Ubah Jadwal',
              style: GoogleFonts.lexend(color: AppColor.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelTicket(int ticketId) async {
    try {
      final token = await AuthPreferences.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan.');
      }

      await _ticketService.cancelTicket(ticketId, token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tiket berhasil dibatalkan.',
              style: GoogleFonts.lexend(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadTickets(); // Reload tickets
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal membatalkan tiket: $e',
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
