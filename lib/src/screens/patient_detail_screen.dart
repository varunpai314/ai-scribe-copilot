import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/patient.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  Patient? _patient;
  bool _isLoading = true;
  bool _isEditing = false;

  // Controllers for editing
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _pronounsController = TextEditingController();
  final _backgroundController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _familyHistoryController = TextEditingController();
  final _socialHistoryController = TextEditingController();
  final _previousTreatmentController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadPatientDetails();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _pronounsController.dispose();
    _backgroundController.dispose();
    _medicalHistoryController.dispose();
    _familyHistoryController.dispose();
    _socialHistoryController.dispose();
    _previousTreatmentController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientDetails() async {
    try {
      // TODO: Implement get patient by ID in PatientService
      // For now, we'll show a placeholder
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient details loading - Feature coming soon!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading patient: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _populateControllers() {
    if (_patient == null) return;

    _fullNameController.text = _patient!.name;
    _emailController.text = _patient!.email;
    // _selectedDate = _patient!.dateOfBirth;
    if (_selectedDate != null) {
      _dobController.text =
          "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
    }
    _pronounsController.text = _patient!.pronouns ?? '';
    _backgroundController.text = _patient!.background ?? '';
    _medicalHistoryController.text = _patient!.medicalHistory ?? '';
    _familyHistoryController.text = _patient!.familyHistory ?? '';
    _socialHistoryController.text = _patient!.socialHistory ?? '';
    _previousTreatmentController.text = _patient!.previousTreatment ?? '';
  }

  // String _calculateAge(DateTime dateOfBirth) {
  //   final now = DateTime.now();
  //   final age = now.year - dateOfBirth.year;
  //   final hasHadBirthday =
  //       now.month > dateOfBirth.month ||
  //       (now.month == dateOfBirth.month && now.day >= dateOfBirth.day);

  //   return hasHadBirthday ? '$age years old' : '${age - 1} years old';
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blueGrey.shade700),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          _patient?.name ?? 'Patient Details',
          style: TextStyle(
            color: Colors.blueGrey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: Colors.blueGrey.shade700,
            ),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // TODO: Save changes
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Save functionality - Coming soon!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  _populateControllers();
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPatientDetailContent(),
    );
  }

  Widget _buildPatientDetailContent() {
    // Mock patient data for demo purposes
    final mockPatient = Patient(
      id: widget.patientId,
      doctorId: 'mock-doctor-id',
      name: 'John Doe',
      email: 'john.doe@email.com',
      // dateOfBirth: DateTime(1985, 5, 15),
      // gender: 'Male',
      pronouns: 'he/him',
      background: 'Software engineer with active lifestyle',
      medicalHistory: 'No significant medical history. Regular checkups.',
      familyHistory: 'Father has diabetes, mother has hypertension',
      socialHistory: 'Non-smoker, occasional alcohol consumption',
      previousTreatment: 'Flu vaccination last year',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Header Card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blueGrey.shade700,
                    child: Text(
                      mockPatient.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mockPatient.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mockPatient.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey.shade600,
                          ),
                        ),
                        // if (mockPatient.dateOfBirth != null) ...[
                        //   const SizedBox(height: 4),
                        //   Text(
                        //     _calculateAge(mockPatient.dateOfBirth!),
                        //     style: TextStyle(
                        //       fontSize: 14,
                        //       color: Colors.blueGrey.shade500,
                        //     ),
                        //   ),
                        // ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Basic Information Section
          _buildSectionHeader('Basic Information'),
          const SizedBox(height: 12),
          _buildDetailCard([
            // _buildDetailRow(
            //   'Gender',
            //   mockPatient.gender ?? 'Not specified',
            //   Icons.wc_outlined,
            // ),
            _buildDetailRow(
              'Pronouns',
              mockPatient.pronouns ?? 'Not specified',
              Icons.badge_outlined,
            ),
            // if (mockPatient.dateOfBirth != null)
            //   _buildDetailRow(
            //     'Date of Birth',
            //     '${mockPatient.dateOfBirth!.day}/${mockPatient.dateOfBirth!.month}/${mockPatient.dateOfBirth!.year}',
            //     Icons.cake_outlined,
            //   ),
          ]),

          const SizedBox(height: 20),

          // Medical Information Section
          _buildSectionHeader('Medical Information'),
          const SizedBox(height: 12),
          _buildDetailCard([
            if (mockPatient.medicalHistory?.isNotEmpty == true)
              _buildDetailRow(
                'Medical History',
                mockPatient.medicalHistory!,
                Icons.medical_information_outlined,
              ),
            if (mockPatient.familyHistory?.isNotEmpty == true)
              _buildDetailRow(
                'Family History',
                mockPatient.familyHistory!,
                Icons.family_restroom_outlined,
              ),
            if (mockPatient.socialHistory?.isNotEmpty == true)
              _buildDetailRow(
                'Social History',
                mockPatient.socialHistory!,
                Icons.people_outline,
              ),
            if (mockPatient.previousTreatment?.isNotEmpty == true)
              _buildDetailRow(
                'Previous Treatment',
                mockPatient.previousTreatment!,
                Icons.history_outlined,
              ),
          ]),

          const SizedBox(height: 20),

          // Background Information
          if (mockPatient.background?.isNotEmpty == true) ...[
            _buildSectionHeader('Background Information'),
            const SizedBox(height: 12),
            _buildDetailCard([
              _buildDetailRow(
                'Background',
                mockPatient.background!,
                Icons.info_outline,
              ),
            ]),
            const SizedBox(height: 20),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Starting session with ${mockPatient.name}',
                        ),
                        backgroundColor: Colors.green.shade600,
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit functionality - Coming soon!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Patient'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blueGrey.shade700,
                    side: BorderSide(color: Colors.blueGrey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey.shade700,
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
