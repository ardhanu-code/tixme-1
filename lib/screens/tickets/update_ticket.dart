import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tixme/const/app_color.dart';
import 'package:tixme/models/schedule_model.dart';
import 'package:tixme/services/session_service.dart';
import 'package:tixme/services/schedule_service.dart';
import 'package:tixme/services/ticket_service.dart';

class UpdateTicketScreen extends StatefulWidget {
  final int ticketId;
  final Map<String, dynamic>? currentTicket;

  const UpdateTicketScreen({
    super.key,
    required this.ticketId,
    this.currentTicket,
  });

  @override
  State<UpdateTicketScreen> createState() => _UpdateTicketScreenState();
}

class _UpdateTicketScreenState extends State<UpdateTicketScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final TicketService _ticketService = TicketService();

  List<ScheduleData> _schedules = [];
  ScheduleData? _selectedSchedule;
  bool _isLoading = false;
  bool _isLoadingSchedule = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      final token = await AuthPreferences.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("Token tidak ditemukan.");
      }

      final result = await _scheduleService.getSchedules(token);

      setState(() {
        _schedules = (result.data ?? []).where((schedule) {
          return schedule.film?.stats == 'now_playing';
        }).toList();
        _isLoadingSchedule = false;
      });
    } catch (e) {
      print('Error loading schedules: $e'); // Debug print
      setState(() => _isLoadingSchedule = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat jadwal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitScheduleUpdate() async {
    if (_selectedSchedule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih jadwal terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await AuthPreferences.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("Token tidak ditemukan.");
      }

      await _ticketService.updateTicketSchedule(
        ticketId: widget.ticketId,
        newScheduleId: _selectedSchedule!.id!,
        token: token,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jadwal berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui jadwal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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

  Widget _buildCurrentScheduleCard() {
    if (widget.currentTicket == null) return SizedBox.shrink();

    final film = widget.currentTicket!['film'] ?? {};

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jadwal Saat Ini',
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            film['title'] ?? 'Unknown Film',
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            widget.currentTicket!['start_time'] != null
                ? _formatDateTime(
                    DateTime.parse(widget.currentTicket!['start_time']),
                  )
                : 'Jadwal tidak tersedia',
            style: GoogleFonts.lexend(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ubah Jadwal Tiket',
          style: GoogleFonts.lexend(color: Colors.white),
        ),
        backgroundColor: AppColor.primary,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // Add refresh button to manually reload schedules
          IconButton(
            onPressed: () {
              setState(() {
                _isLoadingSchedule = true;
                _schedules = [];
                _selectedSchedule = null;
              });
              _loadSchedules();
            },
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoadingSchedule
              ? Center(child: CircularProgressIndicator())
              : _schedules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada jadwal tersedia',
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Coba refresh atau hubungi admin',
                        style: GoogleFonts.lexend(color: Colors.grey[500]),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoadingSchedule = true;
                            _schedules = [];
                            _selectedSchedule = null;
                          });
                          _loadSchedules();
                        },
                        child: Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Schedule Card
                      _buildCurrentScheduleCard(),

                      // Dropdown Schedule
                      Text(
                        'Pilih Jadwal Baru',
                        style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<ScheduleData>(
                        value: _selectedSchedule,
                        items: _schedules.map((schedule) {
                          return DropdownMenuItem(
                            value: schedule,
                            child: Text(
                              '${schedule.film?.title ?? "Unknown"} - ${_formatDateTime(schedule.startTime!)}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedSchedule = value);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null) return 'Pilih jadwal';
                          return null;
                        },
                      ),

                      SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitScheduleUpdate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Simpan Perubahan',
                                  style: GoogleFonts.lexend(
                                    color: Colors.white,
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
