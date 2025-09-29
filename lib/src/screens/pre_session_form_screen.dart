import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/patient.dart';
import '../models/template.dart';
import '../models/doctor.dart';
import '../services/patient_service.dart';
import '../services/template_service.dart';
import '../services/auth_service.dart';

class PreSessionFormScreen extends StatefulWidget {
  final String patientId;

  const PreSessionFormScreen({super.key, required this.patientId});

  @override
  State<PreSessionFormScreen> createState() => _PreSessionFormScreenState();
}

class _PreSessionFormScreenState extends State<PreSessionFormScreen> {
  Patient? _patient;
  Doctor? _currentDoctor;
  List<Template> _templates = [];
  Template? _selectedTemplate;
  bool _isLoading = true;

  final TextEditingController _sessionTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _sessionTitleController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current doctor
      _currentDoctor = await AuthService.getCurrentDoctor();
      if (_currentDoctor == null) {
        _showError('Authentication required');
        return;
      }

      // Load patient details and templates concurrently
      final results = await Future.wait([
        PatientService.getPatientDetails(widget.patientId),
        TemplateService.getTemplatesForDoctor(_currentDoctor!.id),
      ]);

      _patient = results[0] as Patient;
      _templates = results[1] as List<Template>;

      // Set default session title
      _sessionTitleController.text =
          'Session with ${_patient!.name} - ${DateTime.now().toString().substring(0, 16)}';

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load data: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _startSession() {
    if (_selectedTemplate == null) {
      _showError('Please select a template before starting the session');
      return;
    }

    if (_sessionTitleController.text.trim().isEmpty) {
      _showError('Please enter a session title');
      return;
    }

    // Navigate to session screen with the selected template and session title
    context.pushReplacement(
      '/session/${widget.patientId}',
      extra: {
        'templateId': _selectedTemplate!.id,
        'sessionTitle': _sessionTitleController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Preparing Session...'),
          backgroundColor: Colors.blueGrey.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_patient == null || _currentDoctor == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.blueGrey.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Failed to load patient data. Please try again.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Start Session - ${_patient!.name}'),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Information Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.blueGrey.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Patient Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPatientInfoRow('Name', _patient!.name),
                    _buildPatientInfoRow('Email', _patient!.email),
                    if (_patient!.pronouns != null)
                      _buildPatientInfoRow('Pronouns', _patient!.pronouns!),
                    if (_patient!.background != null)
                      _buildPatientInfoSection(
                        'Background',
                        _patient!.background!,
                      ),
                    if (_patient!.medicalHistory != null)
                      _buildPatientInfoSection(
                        'Medical History',
                        _patient!.medicalHistory!,
                      ),
                    if (_patient!.familyHistory != null)
                      _buildPatientInfoSection(
                        'Family History',
                        _patient!.familyHistory!,
                      ),
                    if (_patient!.socialHistory != null)
                      _buildPatientInfoSection(
                        'Social History',
                        _patient!.socialHistory!,
                      ),
                    if (_patient!.previousTreatment != null)
                      _buildPatientInfoSection(
                        'Previous Treatment',
                        _patient!.previousTreatment!,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Session Configuration Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings, color: Colors.blueGrey.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Session Configuration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Session Title Input
                    Text(
                      'Session Title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _sessionTitleController,
                      decoration: InputDecoration(
                        hintText: 'Enter session title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Template Selection
                    Text(
                      'Select Template',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_templates.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'No templates available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      Column(
                        children: _templates.map((template) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: RadioListTile<Template>(
                              title: Text(template.title),
                              subtitle: Text(
                                'Type: ${template.type.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              value: template,
                              groupValue: _selectedTemplate,
                              onChanged: (Template? value) {
                                setState(() {
                                  _selectedTemplate = value;
                                });
                              },
                              activeColor: Colors.blueGrey.shade700,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Start Session',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildPatientInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
