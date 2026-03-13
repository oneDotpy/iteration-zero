// lib/screens/manage_patients_screen.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_card.dart';

class ManagePatientsScreen extends StatefulWidget {
  const ManagePatientsScreen({super.key});

  @override
  State<ManagePatientsScreen> createState() => _ManagePatientsScreenState();
}

class _ManagePatientsScreenState extends State<ManagePatientsScreen> {
  void _showAddSheet() {
    final nameController = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PatientSheet(
        title: 'Add patient',
        nameController: nameController,
        notesController: notesController,
        onSave: () {
          final name = nameController.text.trim();
          if (name.isEmpty) return;
          AppState.addPatient(name: name, notes: notesController.text.trim());
          Navigator.pop(ctx);
          setState(() {});
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showEditSheet(PatientProfile patient) {
    final nameController = TextEditingController(text: patient.name);
    final notesController = TextEditingController(text: patient.notes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PatientSheet(
        title: 'Edit patient',
        nameController: nameController,
        notesController: notesController,
        onSave: () {
          final name = nameController.text.trim();
          if (name.isEmpty) return;
          patient.name = name;
          patient.notes = notesController.text.trim();
          Navigator.pop(ctx);
          setState(() {});
        },
        onCancel: () => Navigator.pop(ctx),
        onDelete: patient.id != AppState.defaultPatientId
            ? () {
                AppState.removePatient(patient.id);
                Navigator.pop(ctx);
                setState(() {});
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patients = AppState.patients;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [AppColors.cardShadow],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textDark,
              size: 18,
            ),
          ),
        ),
        title: const Text(
          'Patients',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _showAddSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.caregiverPrimary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [AppColors.cardShadow],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: patients.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 56,
                    color: AppColors.textMedium.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No patients yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textMedium.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap "Add" to create a patient profile.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMedium.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: patients.length,
              separatorBuilder: (_, sep) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final p = patients[i];
                return SoftCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.caregiverLightBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: AppColors.caregiverPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            if (p.notes.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                p.notes,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMedium,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showEditSheet(p),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4F8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.textMedium,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _PatientSheet extends StatelessWidget {
  final String title;
  final TextEditingController nameController;
  final TextEditingController notesController;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback? onDelete;

  const _PatientSheet({
    required this.title,
    required this.nameController,
    required this.notesController,
    required this.onSave,
    required this.onCancel,
    this.onDelete,
  });

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textMedium.withValues(alpha: 0.5)),
        filled: true,
        fillColor: const Color(0xFFF7F9FB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E7EE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E7EE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.caregiverPrimary,
            width: 1.5,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7EE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: _inputDecoration('Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: _inputDecoration('Notes (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (onDelete != null) ...[
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF0F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'Remove',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E7EE)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.textMedium,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onSave,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.caregiverPrimary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [AppColors.cardShadow],
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
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
}
