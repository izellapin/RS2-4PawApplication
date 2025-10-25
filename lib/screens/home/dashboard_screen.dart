import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veterinarska_shared/veterinarska_shared.dart';
import '../appointments/book_appointment_screen.dart';
import '../pets/add_pet_screen.dart';

class MobileDashboardScreen extends StatefulWidget {
  const MobileDashboardScreen({super.key});

  @override
  State<MobileDashboardScreen> createState() => _MobileDashboardScreenState();
}

class _MobileDashboardScreenState extends State<MobileDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('4Paw'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pozdrav
            Text(
              'Dobrodošli, ${user?.firstName ?? 'Korisniče'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Kako su danas vaši ljubimci?',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            
            const SizedBox(height: 24),
            
            // Quick actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'Zakaži termin',
                    Icons.add_circle,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookAppointmentScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionCard(
                    'Dodaj ljubimca',
                    Icons.pets,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddPetScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Nadolazeći termini
            const Text(
              'Nadolazeći termini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Lista termina
            FutureBuilder<List<Appointment>>(
              future: _loadUpcomingAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Greška pri učitavanju termina: ${snapshot.error}'),
                    ),
                  );
                }
                
                final appointments = snapshot.data ?? [];
                
                if (appointments.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          const Text('Nemate zakazane termine'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BookAppointmentScreen(),
                              ),
                            ),
                            child: const Text('Zakaži termin'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: appointments.take(3).map((appointment) => 
                    _buildAppointmentCard(appointment)
                  ).toList(),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Moji ljubimci
            const Text(
              'Moji ljubimci',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            FutureBuilder<List<Pet>>(
              future: _loadMyPets(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Greška pri učitavanju ljubimaca: ${snapshot.error}'),
                    ),
                  );
                }
                
                final pets = snapshot.data ?? [];
                
                if (pets.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.pets, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          const Text('Nemate registrovane ljubimce'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddPetScreen(),
                              ),
                            ),
                            child: const Text('Dodaj ljubimca'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  child: Text(
                                    pet.name[0],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pet.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  pet.species,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2E7D32),
          child: Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(appointment.typeText),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${appointment.formattedDate} - ${appointment.timeRange}'),
            if (appointment.petName != null)
              Text('Pacijent: ${appointment.petName}'),
          ],
        ),
        trailing: Chip(
          label: Text(
            appointment.statusText,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: _getStatusColor(appointment.status),
        ),
      ),
    );
  }
  
  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blue[100]!;
      case AppointmentStatus.confirmed:
        return Colors.green[100]!;
      case AppointmentStatus.inProgress:
        return Colors.orange[100]!;
      case AppointmentStatus.completed:
        return Colors.grey[100]!;
      case AppointmentStatus.cancelled:
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
  
  Future<List<Appointment>> _loadUpcomingAppointments() async {
    try {
      final authService = serviceLocator.authService;
      if (authService.currentUser == null) return [];
      
      final apiClient = serviceLocator.apiClient;
      final appointments = await apiClient.getUserAppointments(authService.currentUser!.id);
      
      // Filter upcoming appointments
      final now = DateTime.now();
      return appointments.where((apt) => 
        apt.appointmentDate.isAfter(now) &&
        apt.status != AppointmentStatus.cancelled
      ).toList()..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    } catch (e) {
      print('Error loading appointments: $e');
      return [];
    }
  }
  
  Future<List<Pet>> _loadMyPets() async {
    try {
      final authService = serviceLocator.authService;
      if (authService.currentUser == null) return [];
      
      final apiClient = serviceLocator.apiClient;
      return await apiClient.getUserPets(authService.currentUser!.id);
    } catch (e) {
      print('Error loading pets: $e');
      return [];
    }
  }
}










