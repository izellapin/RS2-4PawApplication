import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'services/service_locator.dart';
import 'pages/profile_page.dart';
import 'services/auth_service.dart';
import 'models/auth.dart';
import 'models/user.dart' as models;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await serviceLocator.initialize();
  
  // Configure window for desktop
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: '4Paw Veterinarska Stanica - Admin Panel',
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const VeterinaryAdminApp());
}

class VeterinaryAdminApp extends StatelessWidget {
  const VeterinaryAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>(
      create: (_) => serviceLocator.authService,
      child: MaterialApp(
        title: '4Paw Admin Panel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, _) {
            if (authService.isLoading) {
              return const SplashScreen();
            }
            
            return authService.isAuthenticated 
              ? MainDashboard(userRole: _convertToOldUserRole(authService.currentAuth!.role))
              : const LoginScreen();
          },
        ),
      ),
    );
  }
  
  // Helper method to convert new UserRole to old enum
  UserRole _convertToOldUserRole(models.UserRole newRole) {
    switch (newRole) {
      case models.UserRole.admin:
        return UserRole.admin;
      case models.UserRole.veterinarian:
        return UserRole.veterinarian;
      default:
        return UserRole.veterinarian; // fallback
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2E7D32),
            const Color(0xFF388E3C),
          ],
        ),
      ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            elevation: 8,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
      child: Column(
                  mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pets,
                      size: 64,
                      color: const Color(0xFF2E7D32),
          ),
          const SizedBox(height: 16),
          const Text(
                      '4Paw Admin Panel',
            style: TextStyle(
                        fontSize: 24,
              fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
                      'Prijavite se u sistem',
            style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email adresa',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Unesite email adresu';
                        }
                        if (!value.contains('@')) {
                          return 'Unesite validnu email adresu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Lozinka',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Unesite lozinku';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Prijavite se'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _usernameController.text.trim();
        final password = _passwordController.text;
        
        // Create login request
        final loginRequest = LoginRequest(
          email: email,
          password: password,
          clientType: 'Desktop',
        );

        // Call API
        final authResponse = await serviceLocator.apiClient.login(loginRequest);
        
        // Save auth data
        final success = await serviceLocator.authService.login(authResponse);
        
        if (success) {
          // Navigation will be handled automatically by Consumer in VeterinaryAdminApp
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dobrodošli, ${authResponse.firstName}!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Failed to save authentication data');
        }
      } catch (error) {
        if (mounted) {
          String errorMessage = 'Došlo je do greške prilikom prijave';
          
          if (error is ApiError) {
            errorMessage = error.message;
          } else {
            errorMessage = error.toString();
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

enum UserRole { admin, veterinarian }

class MainDashboard extends StatefulWidget {
  final UserRole userRole;

  const MainDashboard({super.key, required this.userRole});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  List<NavigationItem> get _navigationItems {
    if (widget.userRole == UserRole.admin) {
      return [
        NavigationItem(Icons.dashboard, 'Dashboard'),
        NavigationItem(Icons.people, 'Korisnici'),
        NavigationItem(Icons.person_add, 'Veterinari'),
        NavigationItem(Icons.medical_services, 'Usluge'),
        NavigationItem(Icons.calendar_month, 'Termini'),
        NavigationItem(Icons.analytics, 'Izveštaji'),
        NavigationItem(Icons.settings, 'Podešavanja'),
      ];
    } else {
      return [
        NavigationItem(Icons.dashboard, 'Dashboard'),
        NavigationItem(Icons.calendar_today, 'Moji Termini'),
        NavigationItem(Icons.pets, 'Pacijenti'),
        NavigationItem(Icons.medical_information, 'Kartoni'),
        NavigationItem(Icons.receipt, 'Recepti'),
        NavigationItem(Icons.person, 'Profil'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: const Color(0xFF2E7D32),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.pets,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.userRole == UserRole.admin ? '4Paw Admin Panel' : '4Paw Vet Panel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.userRole == UserRole.admin ? 'Administrator' : 'Veterinar',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24),
                // Navigation
                Expanded(
                  child: ListView.builder(
                    itemCount: _navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = _navigationItems[index];
                      final isSelected = _selectedIndex == index;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: ListTile(
                          leading: Icon(
                            item.icon,
                            color: isSelected ? const Color(0xFF2E7D32) : Colors.white70,
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF2E7D32) : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Logout
                Container(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white70),
                    title: const Text(
                      'Odjavi se',
                      style: TextStyle(color: Colors.white70),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () async {
                      // Show confirmation dialog
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Odjava'),
                          content: const Text('Da li ste sigurni da se želite odjaviti?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Otkaži'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Odjavi se'),
                            ),
                          ],
                        ),
                      );
                      
                      if (shouldLogout == true) {
                        try {
                          // Try to call logout API
                          final refreshToken = await serviceLocator.authService.getRefreshToken();
                          if (refreshToken != null) {
                            await serviceLocator.apiClient.logout(refreshToken);
                          }
                        } catch (e) {
                          // Ignore API errors during logout
                          print('Logout API error (ignored): $e');
                        }
                        
                        // Clear local auth data
                        await serviceLocator.authService.logout();
                        
                        // Navigation will be handled automatically by Consumer
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return widget.userRole == UserRole.admin 
          ? _buildUsersPage() 
          : _buildMyAppointmentsPage();
      case 2:
        return widget.userRole == UserRole.admin 
          ? _buildVeterinariansPage() 
          : _buildPatientsPage();
      case 3:
        return widget.userRole == UserRole.admin 
          ? _buildServicesPage() 
          : _buildMedicalRecordsPage();
      case 4:
        return widget.userRole == UserRole.admin 
          ? _buildAppointmentsPage() 
          : _buildPrescriptionsPage();
      case 5:
        return widget.userRole == UserRole.admin 
          ? _buildReportsPage() 
          : _buildProfilePage();
      case 6:
        return widget.userRole == UserRole.admin 
          ? _buildSettingsPage() 
          : _buildComingSoon();
      default:
        return _buildComingSoon();
    }
  }

  Widget _buildDashboard() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Ukupno Termina',
                  '24',
                  Icons.calendar_month,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  widget.userRole == UserRole.admin ? 'Aktivni Korisnici' : 'Moji Pacijenti',
                  widget.userRole == UserRole.admin ? '156' : '45',
                  Icons.people,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Danas',
                  '8',
                  Icons.today,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Hitni Slučajevi',
                  '2',
                  Icons.warning,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Recent activity
          Text(
            'Poslednja Aktivnost',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: ListView(
                    padding: const EdgeInsets.all(16),
                      children: [
                  _buildActivityItem(
                    'Novi termin zakazan',
                    'Marko Petrović - Rex (Nemački ovčar)',
                    '10:30',
                    Icons.calendar_today,
                  ),
                  _buildActivityItem(
                    'Pregled završen',
                    'Ana Jovanović - Maca (Persijska)',
                    '09:15',
                    Icons.check_circle,
                  ),
                  _buildActivityItem(
                    'Hitni slučaj',
                    'Stefan Nikolić - Buddy (Labrador)',
                    '08:45',
                    Icons.emergency,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF2E7D32),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  // Admin stranice
  Widget _buildUsersPage() {
    return _buildPageWithApiData(
      title: 'Korisnici',
      icon: Icons.people,
      apiCall: () => serviceLocator.apiClient.getUsers(),
    );
  }

  Widget _buildVeterinariansPage() {
    return _buildPageWithApiData(
      title: 'Veterinari',
      icon: Icons.person_add,
      apiCall: () => serviceLocator.apiClient.getUsers(), // All users for now
    );
  }

  Widget _buildServicesPage() {
    return _buildPageWithApiData(
      title: 'Usluge',
      icon: Icons.medical_services,
      apiCall: () => serviceLocator.apiClient.getServices(),
    );
  }

  Widget _buildAppointmentsPage() {
    return _buildPageWithApiData(
      title: 'Svi Termini',
      icon: Icons.calendar_month,
      apiCall: () => Future.value([]), // TODO: Implement appointments API
    );
  }

  Widget _buildReportsPage() {
    return _buildComingSoon('Izveštaji', Icons.analytics);
  }

  Widget _buildSettingsPage() {
    return _buildComingSoon('Podešavanja', Icons.settings);
  }

  // Veterinar stranice
  Widget _buildMyAppointmentsPage() {
    return _buildPageWithApiData(
      title: 'Moji Termini',
      icon: Icons.calendar_today,
      apiCall: () => Future.value([]), // TODO: Implement vet appointments API
    );
  }

  Widget _buildPatientsPage() {
    return _buildPageWithApiData(
      title: 'Pacijenti',
      icon: Icons.pets,
      apiCall: () => Future.value([]), // TODO: Implement pets API
    );
  }

  Widget _buildMedicalRecordsPage() {
    return _buildPageWithApiData(
      title: 'Medicinski Kartoni',
      icon: Icons.medical_information,
      apiCall: () => Future.value([]), // TODO: Implement medical records API
    );
  }

  Widget _buildPrescriptionsPage() {
    return _buildPageWithApiData(
      title: 'Recepti',
      icon: Icons.receipt,
      apiCall: () => Future.value([]), // TODO: Implement prescriptions API
    );
  }

  Widget _buildProfilePage() {
    return _buildCurrentUserProfile();
  }

  // Generic stranica sa API podacima
  Widget _buildPageWithApiData({
    required String title,
    required IconData icon,
    required Future<List<dynamic>> Function() apiCall,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 32, color: const Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: apiCall(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Greška pri učitavanju podataka',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Pokušaj ponovo'),
                        ),
                      ],
                    ),
                  );
                }

                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Nema podataka',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF2E7D32),
                          child: Icon(icon, color: Colors.white),
                        ),
                        title: Text(
                          item['name'] ?? item['firstName'] ?? item['title'] ?? 'N/A',
                        ),
                        subtitle: Text(
                          item['email'] ?? item['description'] ?? item['type'] ?? '',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // TODO: Navigate to details page
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Detalji za: ${item['name'] ?? 'N/A'}'),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Profil trenutnog korisnika sa CRUD operacijama
  Widget _buildCurrentUserProfile() {
    return const ProfilePage();
  }

  Widget _buildComingSoon([String? title, IconData? icon]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.construction,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            title ?? 'Uskoro...',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Text(
            'Ova funkcionalnost je u razvoju',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String title;

  NavigationItem(this.icon, this.title);
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF388E3C),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                '4Paw Veterinarska Stanica',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Admin Panel',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}