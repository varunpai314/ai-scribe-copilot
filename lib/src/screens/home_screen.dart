import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/patient_service.dart';
import '../models/doctor.dart';
import '../models/patient.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Doctor? _currentDoctor;
  List<Patient> _patients = [];
  bool _isLoading = true;
  bool _isLoadingPatients = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentDoctor();
  }

  Future<void> _loadCurrentDoctor() async {
    try {
      final doctor = await AuthService.getCurrentDoctor();
      setState(() {
        _currentDoctor = doctor;
      });

      // Load patients after loading doctor
      if (doctor != null) {
        await _loadPatients();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPatients() async {
    if (_currentDoctor == null) return;

    setState(() {
      _isLoadingPatients = true;
    });

    try {
      final patients = await PatientService.getPatients(_currentDoctor!.id);
      setState(() {
        _patients = patients;
        _isLoading = false;
        _isLoadingPatients = false;
      });
    } catch (e) {
      setState(() {
        _patients = [];
        _isLoading = false;
        _isLoadingPatients = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load patients: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _refreshPatients() async {
    await _loadPatients();
  }

  Widget _buildWelcomeScreen(double width) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image(
            image: const AssetImage('assets/medinote_logo.png'),
            width: width * 2 / 5,
          ),
          const SizedBox(height: 64),
          Image.asset('assets/doc_vector.png', width: width * 4 / 5),
          const SizedBox(height: 32),
          Text(
            'No patients yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add your first patient to get started',
            style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade500),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/add_patient');
            },
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 24),
            label: const Text(
              'Add Patient',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(180, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsList() {
    return RefreshIndicator(
      onRefresh: _refreshPatients,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Patients (${_patients.length})',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
                if (_isLoadingPatients)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blueGrey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final patient = _patients[index];
                return _buildPatientCard(patient);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Avatar, Name, and Details Arrow
            Row(
              children: [
                // Patient Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blueGrey.shade700,
                  child: Text(
                    patient.name.isNotEmpty
                        ? patient.name[0].toUpperCase()
                        : 'P',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Patient Name and Basic Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        patient.email,
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Details Arrow Button
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GestureDetector(
                    onTap: () => _navigateToPatientDetails(patient),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blueGrey.shade600,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Patient Details Row
            Row(
              children: [
                // Age/DOB Info
                // if (patient.dateOfBirth != null) ...[
                //   _buildInfoChip(
                //     icon: Icons.cake_outlined,
                //     label: _calculateAge(patient.dateOfBirth!),
                //     color: Colors.orange.shade100,
                //     textColor: Colors.orange.shade700,
                //   ),
                //   const SizedBox(width: 8),
                // ],

                // // Gender Info
                // if (patient.gender != null) ...[
                //   _buildInfoChip(
                //     icon: Icons.wc_outlined,
                //     label: patient.gender!,
                //     color: Colors.blue.shade100,
                //     textColor: Colors.blue.shade700,
                //   ),
                //   const SizedBox(width: 8),
                // ],

                // Pronouns Info
                if (patient.pronouns != null) ...[
                  _buildInfoChip(
                    icon: Icons.badge_outlined,
                    label: patient.pronouns!,
                    color: Colors.purple.shade100,
                    textColor: Colors.purple.shade700,
                  ),
                ],
              ],
            ),

            // Medical History Preview
            if (patient.medicalHistory != null &&
                patient.medicalHistory!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.medical_information_outlined,
                      color: Colors.green.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Medical History: ${_truncateText(patient.medicalHistory!, 60)}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Start Session Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startSession(patient),
                icon: const Icon(Icons.play_arrow, size: 20),
                label: const Text(
                  'Start Session',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService.logout();
      if (mounted) {
        context.go('/auth');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey.shade600),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          _currentDoctor != null
              ? 'Welcome, Dr. ${_currentDoctor!.name}'
              : 'Welcome, Doctor',
          style: TextStyle(
            color: Colors.blueGrey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
          ),
          overflow: TextOverflow.fade,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 24),
            tooltip: 'Logout',
            onPressed: _showLogoutDialog,
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blueGrey.shade100],
          ),
        ),
        child: _patients.isEmpty
            ? _buildWelcomeScreen(width)
            : _buildPatientsList(),
      ),
      floatingActionButton: _patients.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                context.go('/add_patient');
              },
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add Patient'),
              backgroundColor: Colors.blueGrey.shade700,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  // Helper method to build info chips
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to calculate age from date of birth
  // String _calculateAge(DateTime dateOfBirth) {
  //   final now = DateTime.now();
  //   final age = now.year - dateOfBirth.year;
  //   final hasHadBirthday =
  //       now.month > dateOfBirth.month ||
  //       (now.month == dateOfBirth.month && now.day >= dateOfBirth.day);

  //   final actualAge = hasHadBirthday ? age : age - 1;
  //   return '${actualAge}y';
  // }

  // Helper method to truncate text
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Navigation method for patient details
  void _navigateToPatientDetails(Patient patient) {
    context.go('/patient_details/${patient.id}');
  }

  // Method to start a session with patient
  void _startSession(Patient patient) {
    // Navigate to pre-session form to configure session before starting
    context.push('/pre-session/${patient.id}');
  }
}
