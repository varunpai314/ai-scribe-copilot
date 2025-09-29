import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';
import '../services/auth_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  // TODO: Add these fields after running database migration
  // final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _pronounsController = TextEditingController();
  final _backgroundController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _familyHistoryController = TextEditingController();
  final _socialHistoryController = TextEditingController();
  final _previousTreatmentController = TextEditingController();

  // TODO: Add these fields after running database migration
  // String _selectedGender = '';
  // DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    // TODO: Add these fields after running database migration
    // _dobController.dispose();
    _emailController.dispose();
    _pronounsController.dispose();
    _backgroundController.dispose();
    _medicalHistoryController.dispose();
    _familyHistoryController.dispose();
    _socialHistoryController.dispose();
    _previousTreatmentController.dispose();
    super.dispose();
  }

  // TODO: Add this method after running database migration
  // Future<void> _selectDate() async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
  //     firstDate: DateTime(1900),
  //     lastDate: DateTime.now(),
  //     builder: (context, child) {
  //       return Theme(
  //         data: Theme.of(context).copyWith(
  //           colorScheme: ColorScheme.light(
  //             primary: Colors.blueGrey.shade700,
  //             onPrimary: Colors.white,
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       _selectedDate = picked;
  //       _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
  //     });
  //   }
  // }

  // TODO: Add this method after running database migration
  // void _showGenderBottomSheet() {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Container(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               'Select Gender',
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 16),
  //             ...[
  //               ('Male', 'He/Him'),
  //               ('Female', 'She/Her'),
  //               ('Non-binary', 'They/Them'),
  //               ('Other', 'Other'),
  //               ('Prefer not to say', 'Prefer not to say'),
  //             ].map(
  //               (option) => ListTile(
  //                 title: Text(option.$1),
  //                 onTap: () {
  //                   setState(() {
  //                     _selectedGender = option.$1;
  //                     _pronounsController.text = option.$2;
  //                   });
  //                   Navigator.pop(context);
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // TODO: Add gender validation after running database migration
    // // Validate required gender field
    // if (_selectedGender.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please select a gender'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current doctor ID from authentication
      final String? doctorId = await AuthService.getCurrentDoctorId();
      if (doctorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication error. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final request = PatientCreateRequest(
        doctorId: doctorId,
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        // TODO: Add after database migration
        // dateOfBirth: _selectedDate,
        // gender: _selectedGender, // Now required, so always has a value
        pronouns: _pronounsController.text.trim().isNotEmpty
            ? _pronounsController.text.trim()
            : null,
        background: _backgroundController.text.trim().isNotEmpty
            ? _backgroundController.text.trim()
            : null,
        medicalHistory: _medicalHistoryController.text.trim().isNotEmpty
            ? _medicalHistoryController.text.trim()
            : null,
        familyHistory: _familyHistoryController.text.trim().isNotEmpty
            ? _familyHistoryController.text.trim()
            : null,
        socialHistory: _socialHistoryController.text.trim().isNotEmpty
            ? _socialHistoryController.text.trim()
            : null,
        previousTreatment: _previousTreatmentController.text.trim().isNotEmpty
            ? _previousTreatmentController.text.trim()
            : null,
      );

      final response = await PatientService.addPatient(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Patient "${response.patient.name}" added successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } on PatientServiceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: ${e.toString()}'),
            backgroundColor: Colors.red,
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
          'Add New Patient',
          style: TextStyle(
            color: Colors.blueGrey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _buildSectionHeader('Basic Information'),
                      const SizedBox(height: 12),

                      // Full Name Field (Required)
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field (Required)
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter email address';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // TODO: Add Date of Birth field after database migration
                      // // Date of Birth Field (Required)
                      // _buildTextField(
                      //   controller: _dobController,
                      //   label: 'Date of Birth',
                      //   icon: Icons.calendar_today_outlined,
                      //   isRequired: true,
                      //   readOnly: true,
                      //   onTap: _selectDate,
                      // ),
                      // const SizedBox(height: 16),

                      // TODO: Add Gender field after database migration
                      // // Gender Field (Required)
                      // GestureDetector(
                      //   onTap: _showGenderBottomSheet,
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 16,
                      //       vertical: 16,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(12),
                      //       border: Border.all(
                      //         color: _selectedGender.isEmpty
                      //             ? Colors.red.shade300
                      //             : Colors.blueGrey.shade300,
                      //       ),
                      //     ),
                      //     child: Row(
                      //       children: [
                      //         Icon(
                      //           Icons.wc_outlined,
                      //           color: Colors.grey.shade600,
                      //           size: 20,
                      //         ),
                      //         const SizedBox(width: 12),
                      //         Expanded(
                      //           child: RichText(
                      //             text: TextSpan(
                      //               children: [
                      //                 TextSpan(
                      //                   text: _selectedGender.isEmpty
                      //                       ? 'Gender'
                      //                       : _selectedGender,
                      //                   style: TextStyle(
                      //                     color: _selectedGender.isEmpty
                      //                         ? Colors.grey.shade500
                      //                         : Colors.blueGrey.shade700,
                      //                     fontSize: 16,
                      //                   ),
                      //                 ),
                      //                 TextSpan(
                      //                   text: ' *',
                      //                   style: TextStyle(
                      //                     color: Colors.red.shade600,
                      //                     fontSize: 16,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //         Icon(
                      //           Icons.keyboard_arrow_down,
                      //           color: Colors.grey.shade600,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 16),

                      // Pronouns Field (Optional)
                      _buildTextField(
                        controller: _pronounsController,
                        label: 'Pronouns',
                        icon: Icons.badge_outlined,
                        hint: 'e.g., he/him, she/her, they/them',
                      ),
                      const SizedBox(height: 16),

                      // Background Field (Optional)
                      _buildTextField(
                        controller: _backgroundController,
                        label: 'Background Information',
                        icon: Icons.info_outline,
                        maxLines: 3,
                        hint:
                            'Additional background information about the patient',
                      ),
                      const SizedBox(height: 24),

                      // Medical Information Section
                      _buildSectionHeader('Medical Information'),
                      const SizedBox(height: 12),

                      // Medical History Field (Optional)
                      _buildTextField(
                        controller: _medicalHistoryController,
                        label: 'Medical History',
                        icon: Icons.medical_information_outlined,
                        maxLines: 3,
                        hint:
                            'Current medical conditions, diagnoses, treatments',
                      ),
                      const SizedBox(height: 16),

                      // Family History Field (Optional)
                      _buildTextField(
                        controller: _familyHistoryController,
                        label: 'Family History',
                        icon: Icons.family_restroom_outlined,
                        maxLines: 3,
                        hint: 'Relevant family medical history',
                      ),
                      const SizedBox(height: 16),

                      // Social History Field (Optional)
                      _buildTextField(
                        controller: _socialHistoryController,
                        label: 'Social History',
                        icon: Icons.people_outline,
                        maxLines: 3,
                        hint: 'Lifestyle, habits, social factors',
                      ),
                      const SizedBox(height: 16),

                      // Previous Treatment Field (Optional)
                      _buildTextField(
                        controller: _previousTreatmentController,
                        label: 'Previous Treatment',
                        icon: Icons.history_outlined,
                        maxLines: 3,
                        hint: 'Previous treatments, surgeries, medications',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _savePatient,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.add_circle_outline, size: 24),
                  label: Text(
                    _isLoading ? 'Saving Patient...' : 'Save Patient',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade700,
                    foregroundColor: Colors.white,
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    bool isRequired = false,
    int maxLines = 1,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          labelStyle: TextStyle(
            color: isRequired ? Colors.red.shade600 : Colors.blueGrey.shade600,
            fontSize: 16,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Padding(
            padding: EdgeInsets.only(
              bottom: maxLines > 1 ? (maxLines * 20.0) : 0,
            ),
            child: Icon(icon, color: Colors.grey.shade600, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 16),
        validator: validator,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
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
}
