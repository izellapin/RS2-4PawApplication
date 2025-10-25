import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veterinarska_shared/veterinarska_shared.dart';
import '../auth/login_screen.dart';

class MobileProfileScreen extends StatefulWidget {
  const MobileProfileScreen({super.key});

  @override
  State<MobileProfileScreen> createState() => _MobileProfileScreenState();
}

class _MobileProfileScreenState extends State<MobileProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moj profil'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFF2E7D32),
                            child: Text(
                              '${user.firstName[0]}${user.lastName[0]}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Chip(
                            label: Text(
                              _getRoleText(user.role),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: const Color(0xFF2E7D32),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Profile information
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Korisničko ime'),
                          subtitle: Text(user.username),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          subtitle: Text(user.email),
                          trailing: user.isEmailVerified
                              ? const Icon(Icons.verified, color: Colors.green)
                              : const Icon(Icons.warning, color: Colors.orange),
                        ),
                        if (user.phoneNumber != null) ...[
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: const Text('Telefon'),
                            subtitle: Text(user.phoneNumber!),
                          ),
                        ],
                        if (user.address != null) ...[
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.location_on),
                            title: const Text('Adresa'),
                            subtitle: Text(user.address!),
                          ),
                        ],
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Član od'),
                          subtitle: Text(
                            '${user.dateCreated.day}.${user.dateCreated.month}.${user.dateCreated.year}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Statistics
                  FutureBuilder<Map<String, int>>(
                    future: _loadUserStatistics(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final stats = snapshot.data!;
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Statistike',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      'Ljubimci',
                                      stats['pets'] ?? 0,
                                      Icons.pets,
                                    ),
                                    _buildStatItem(
                                      'Termini',
                                      stats['appointments'] ?? 0,
                                      Icons.calendar_today,
                                    ),
                                    _buildStatItem(
                                      'Završeni',
                                      stats['completed'] ?? 0,
                                      Icons.check_circle,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Actions
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Uredi profil'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // TODO: Implement edit profile
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funkcionalnost će biti dodana uskoro'),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notifikacije'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // TODO: Implement notifications settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funkcionalnost će biti dodana uskoro'),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.help),
                          title: const Text('Pomoć i podrška'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // TODO: Implement help
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funkcionalnost će biti dodana uskoro'),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: const Text('O aplikaciji'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _showAboutDialog(),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Odjavi se',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () => _showLogoutConfirmation(),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
  
  Widget _buildStatItem(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: const Color(0xFF2E7D32)),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.petOwner:
        return 'Vlasnik ljubimca';
      case UserRole.veterinarian:
        return 'Veterinar';
      case UserRole.vetTechnician:
        return 'Veterinarski tehničar';
      case UserRole.receptionist:
        return 'Recepcioner';
      case UserRole.admin:
        return 'Administrator';
    }
  }
  
  Future<Map<String, int>> _loadUserStatistics() async {
    try {
      final authService = serviceLocator.authService;
      if (authService.currentUser == null) return {};
      
      final apiClient = serviceLocator.apiClient;
      final pets = await apiClient.getUserPets(authService.currentUser!.id);
      final appointments = await apiClient.getUserAppointments(authService.currentUser!.id);
      
      final completedAppointments = appointments.where((apt) => 
        apt.status == AppointmentStatus.completed
      ).length;
      
      return {
        'pets': pets.length,
        'appointments': appointments.length,
        'completed': completedAppointments,
      };
    } catch (e) {
      print('Error loading statistics: $e');
      return {};
    }
  }
  
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O aplikaciji'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '4Paw Veterinary Clinic',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('Verzija: 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Mobilna aplikacija za vlasnike ljubimaca koja omogućava:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Registraciju i upravljanje ljubimcima'),
            Text('• Zakazivanje termina kod veterinara'),
            Text('• Pregled istorije termina'),
            Text('• Upravljanje profilom'),
            SizedBox(height: 16),
            Text(
              'Razvijeno za 4Paw Veterinary Clinic',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
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
  
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda odjave'),
        content: const Text('Da li ste sigurni da se želite odjaviti?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Otkaži'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MobileLoginScreen()),
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Odjavi se'),
          ),
        ],
      ),
    );
  }
}










