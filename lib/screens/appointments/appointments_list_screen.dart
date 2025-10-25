import 'package:flutter/material.dart';
import 'package:veterinarska_shared/veterinarska_shared.dart';
import 'book_appointment_screen.dart';

class MobileAppointmentsListScreen extends StatefulWidget {
  const MobileAppointmentsListScreen({super.key});

  @override
  State<MobileAppointmentsListScreen> createState() => _MobileAppointmentsListScreenState();
}

class _MobileAppointmentsListScreenState extends State<MobileAppointmentsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moji termini'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookAppointmentScreen(),
              ),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _loadMyAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Greška: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Pokušaj ponovo'),
                  ),
                ],
              ),
            );
          }
          
          final appointments = snapshot.data ?? [];
          
          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Nemate zakazane termine',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Zakažite svoj prvi termin za pregled vašeg ljubimca',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookAppointmentScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Zakaži termin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }
          
          // Group appointments by status
          final upcomingAppointments = appointments.where((apt) => 
            apt.appointmentDate.isAfter(DateTime.now()) &&
            apt.status != AppointmentStatus.cancelled
          ).toList()..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
          
          final pastAppointments = appointments.where((apt) => 
            apt.appointmentDate.isBefore(DateTime.now()) ||
            apt.status == AppointmentStatus.completed ||
            apt.status == AppointmentStatus.cancelled
          ).toList()..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Istorija termina sekcija
              if (pastAppointments.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Istorija vaših termina',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...pastAppointments.take(3).map((appointment) => 
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(appointment.appointmentDate),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${appointment.startTime} - ${appointment.endTime}',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.pets, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(appointment.pet?.name ?? 'Nepoznato'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(appointment.veterinarian?.firstName ?? 'Nepoznato'),
                                ],
                              ),
                              if (appointment.service?.name != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.medical_services, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(appointment.service!.name),
                                  ],
                                ),
                              ],
                              if (appointment.reason != null && appointment.reason!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.note, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        appointment.reason!,
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ).toList()),
                      if (pastAppointments.length > 3) ...[
                        const SizedBox(height: 8),
                        Text(
                          '... i ${pastAppointments.length - 3} više termina',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Zakazani termini sekcija
                const Text(
                'Zakazani termini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
              
              if (upcomingAppointments.isNotEmpty) ...[
                ...upcomingAppointments.map((appointment) => 
                  _buildAppointmentCard(appointment, isUpcoming: true)
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'Nemate zakazanih termina',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Prošli termini sekcija
              if (pastAppointments.isNotEmpty) ...[
                const Text(
                  'Prošli termini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...pastAppointments.map((appointment) => 
                  _buildAppointmentCard(appointment, isUpcoming: false)
                ),
              ],
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildAppointmentCard(Appointment appointment, {required bool isUpcoming}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(appointment.status),
          child: Icon(
            _getStatusIcon(appointment.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          appointment.typeText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${appointment.formattedDate} - ${appointment.timeRange}'),
            if (appointment.petName != null)
              Text('Pacijent: ${appointment.petName}'),
            if (appointment.veterinarianName != null)
              Text('Veterinar: ${appointment.veterinarianName}'),
            if (appointment.reason != null && appointment.reason!.isNotEmpty)
              Text('Razlog: ${appointment.reason}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(
                appointment.statusText,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: _getStatusColor(appointment.status).withOpacity(0.2),
            ),
            if (isUpcoming && appointment.status == AppointmentStatus.scheduled)
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'cancel':
                      _showCancelConfirmation(appointment);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'cancel',
                    child: ListTile(
                      leading: Icon(Icons.cancel, color: Colors.red),
                      title: Text('Otkaži termin', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
          ],
        ),
        onTap: () => _showAppointmentDetails(appointment),
      ),
    );
  }
  
  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.inProgress:
        return Colors.orange;
      case AppointmentStatus.completed:
        return Colors.grey;
      case AppointmentStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Icons.schedule;
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.inProgress:
        return Icons.hourglass_empty;
      case AppointmentStatus.completed:
        return Icons.done;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
  
  Future<List<Appointment>> _loadMyAppointments() async {
    try {
      final authService = serviceLocator.authService;
      if (authService.currentUser == null) return [];
      
      final apiClient = serviceLocator.apiClient;
      return await apiClient.getUserAppointments(authService.currentUser!.id);
    } catch (e) {
      print('Error loading appointments: $e');
      throw e;
    }
  }
  
  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appointment.typeText),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Datum', appointment.formattedDate),
            _buildDetailRow('Vreme', appointment.timeRange),
            _buildDetailRow('Status', appointment.statusText),
            if (appointment.petName != null)
              _buildDetailRow('Pacijent', appointment.petName!),
            if (appointment.veterinarianName != null)
              _buildDetailRow('Veterinar', appointment.veterinarianName!),
            if (appointment.reason != null && appointment.reason!.isNotEmpty)
              _buildDetailRow('Razlog', appointment.reason!),
            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              _buildDetailRow('Napomene', appointment.notes!),
            if (appointment.estimatedCost != null)
              _buildDetailRow('Procenjena cena', '${appointment.estimatedCost} KM'),
            if (appointment.actualCost != null)
              _buildDetailRow('Finalna cena', '${appointment.actualCost} KM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Zatvori'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  void _showCancelConfirmation(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Otkaži termin'),
        content: Text('Da li ste sigurni da želite da otkažete termin za ${appointment.formattedDate}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ne'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _cancelAppointment(appointment.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Da, otkaži'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _cancelAppointment(int appointmentId) async {
    try {
      final apiClient = serviceLocator.apiClient;
      await apiClient.cancelAppointment(appointmentId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Termin je uspešno otkazan'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri otkazivanju: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}






