import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tixme/const/app_color.dart';
import 'package:tixme/screens/tickets/update_ticket.dart';
import 'package:tixme/services/ticket_service.dart';
import 'package:tixme/services/session_service.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  bool _isLoadingTickets = true;
  final TicketService _ticketService = TicketService();
  List<Map<String, dynamic>> _allTickets = [];
  List<Map<String, dynamic>> _filteredTickets = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTickets();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoadingTickets = true);

    try {
      final token = await AuthPreferences.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final result = await _ticketService.getUserTickets(token);
      final tickets = List<Map<String, dynamic>>.from(result['data'] ?? []);
      setState(() {
        _allTickets = tickets;
        _filteredTickets = tickets;
        _isLoadingTickets = false;
      });
    } catch (e) {
      setState(() => _isLoadingTickets = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat tiket: $e', style: GoogleFonts.lexend()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTickets = _allTickets.where((ticket) {
        final title = ticket['schedule']?['film']?['title'] ?? '';
        return title.toLowerCase().contains(query);
      }).toList();
    });
  }

  String _formatDate(String? dateTimeStr) {
    final dateTime = DateTime.tryParse(dateTimeStr ?? '');
    return dateTime != null
        ? '${dateTime.day}/${dateTime.month}/${dateTime.year}'
        : 'N/A';
  }

  String _formatTime(String? dateTimeStr) {
    final dateTime = DateTime.tryParse(dateTimeStr ?? '');
    return dateTime != null
        ? '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
        : 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: Text(
          'My Tickets',
          style: GoogleFonts.lexend(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _loadTickets,
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: _isLoadingTickets
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nama film...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: GoogleFonts.lexend(),
                  ),
                ),
                Expanded(
                  child: _filteredTickets.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada tiket ditemukan.',
                            style: GoogleFonts.lexend(),
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

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final film = ticket['film'] ?? {};

    return GestureDetector(
      onLongPress: () => _showCancelDialog(ticket),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: film['image_url'] != null
                        ? Image.network(
                            film['image_url'],
                            width: 80,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 80,
                            height: 120,
                            color: Colors.grey[300],
                            child: Icon(Icons.movie, color: Colors.grey[600]),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          film['title'] ?? 'Unknown Film',
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColor.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${_formatDate(ticket['start_time'])}',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Time: ${_formatTime(ticket['start_time'])}',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Quantity: ${ticket['quantity']}',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
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
        ),
      ),
    );
  }

  void _showCancelDialog(Map<String, dynamic> ticket) {
    final film = ticket['film'] ?? {};
    final filmTitle = film['title'] ?? 'this ticket';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Kelola Tiket',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apa yang ingin kamu lakukan dengan tiket "$filmTitle"?',
          style: GoogleFonts.lexend(),
        ),
        actions: [
          // TextButton(
          //   onPressed: () => Navigator.pop(context),
          //   child: Text('Kembali', style: GoogleFonts.lexend()),
          // ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelTicket(ticket['id']);
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
                    ticketId: ticket['id'],
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
        _loadTickets();
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
