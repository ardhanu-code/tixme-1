import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tixme/const/app_color.dart';
import 'package:tixme/models/schedule_model.dart' as schedule_model;
import 'package:tixme/models/ticket_model.dart';
import 'package:tixme/services/session_service.dart';
import 'package:tixme/services/schedule_service.dart';
import 'package:tixme/services/ticket_service.dart';

class UpdateTicketScreen extends StatefulWidget {
  final int ticketId;
  final TicketData currentTicket;

  const UpdateTicketScreen({
    super.key,
    required this.ticketId,
    required this.currentTicket,
  });

  @override
  State<UpdateTicketScreen> createState() => _UpdateTicketScreenState();
}

class _UpdateTicketScreenState extends State<UpdateTicketScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final TicketService _ticketService = TicketService();

  List<schedule_model.ScheduleData> _schedules = [];
  schedule_model.ScheduleData? _selectedSchedule;
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
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final result = await _scheduleService.getSchedules(token);

      setState(() {
        _schedules = result.data
            .where((schedule) => schedule.film?.stats == 'now_playing')
            .toList();
        _isLoadingSchedule = false;
      });
    } catch (e) {
      setState(() => _isLoadingSchedule = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat jadwal: $e', style: GoogleFonts.lexend()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitScheduleUpdate() async {
    if (_selectedSchedule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pilih jadwal terlebih dahulu',
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await AuthPreferences.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan.');
      }

      await _ticketService.updateTicketSchedule(
        ticketId: widget.ticketId,
        newScheduleId: _selectedSchedule!.id,
        token: token,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Jadwal berhasil diperbarui!',
              style: GoogleFonts.lexend(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memperbarui jadwal: $e',
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildCurrentScheduleCard() {
    final film = widget.currentTicket.schedule.film;
    final scheduleTime = widget.currentTicket.schedule.startTime;

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
            film.title,
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            _formatDateTime(scheduleTime),
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
          style: GoogleFonts.lexend(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColor.primary,
        centerTitle: false,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
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
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                  ),
                )
              : _schedules.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCurrentScheduleCard(),
                      Text(
                        'Pilih Jadwal Baru',
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<schedule_model.ScheduleData>(
                          value: _selectedSchedule,
                          items: _schedules.map((schedule) {
                            return DropdownMenuItem(
                              value: schedule,
                              child: Container(
                                width: double.infinity,
                                child: Text(
                                  '${schedule.film?.title ?? 'Unknown'} - ${_formatDateTime(schedule.startTime)}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedSchedule = value);
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(Icons.schedule, color: AppColor.primary),
                          ),
                          isExpanded: true,
                        ),
                      ),
                      SizedBox(height: 32),
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
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Simpan Perubahan',
                                  style: GoogleFonts.lexend(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
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

  Widget _buildEmptyState() {
    return Center(
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
            style: GoogleFonts.lexend(color: Colors.grey[500], fontSize: 14),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isLoadingSchedule = true;
                _schedules = [];
                _selectedSchedule = null;
              });
              _loadSchedules();
            },
            icon: Icon(Icons.refresh),
            label: Text('Refresh', style: GoogleFonts.lexend()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
