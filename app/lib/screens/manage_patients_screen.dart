// lib/screens/manage_patients_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_icon_button.dart';
import 'manage_patients_profile_screen.dart';

class ManagePatientsScreen extends StatefulWidget {
  const ManagePatientsScreen({super.key});

  @override
  State<ManagePatientsScreen> createState() => _ManagePatientsScreenState();
}

class _ManagePatientsScreenState extends State<ManagePatientsScreen> {
  void _showAddDialog() {
    final colors = context.appColors;
    final nameController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.background,
        title: const Text('Add care recipient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: _inputDecoration('Name', colors),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: _inputDecoration('Notes (optional)', colors),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: colors.teal)),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              AppState.addPatient(
                name: name,
                notes: notesController.text.trim(),
              );
              Navigator.pop(ctx);
              setState(() {});
            },
            style: FilledButton.styleFrom(
              backgroundColor: colors.teal,
              foregroundColor: colors.surface,
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, AppColors colors) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: colors.surfaceAlt.withValues(alpha: 0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.teal, width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final patients = AppState.patients;

    return Scaffold(
      backgroundColor: colors.tealLight,
      appBar: AppBar(
        backgroundColor: colors.tealLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: AppBackButton(
          color: colors.teal,
          onTap: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'My Care Recipients',
          style: TextStyle(
            color: colors.textHigh,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              patients.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          'No care recipients yet.\nTap below to add one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: colors.textMed,
                              fontSize: 15,
                              height: 1.5),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: patients.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final p = patients[i];
                        return _PatientCard(
                          patient: p,
                          colors: colors,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ManagePatientsProfileScreen(patient: p),
                              ),
                            );
                            if (mounted) setState(() {});
                          },
                        );
                      },
                    ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    boxShadow: [colors.shadow],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      filledButtonTheme: FilledButtonThemeData(
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.teal,
                          foregroundColor: colors.surface,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: Colors.transparent,
                          elevation: 0,
                        ),
                      ),
                    ),
                    child: FilledButton.icon(
                      onPressed: _showAddDialog,
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text(
                        'Add care recipient',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Patient card ──────────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  final PatientProfile patient;
  final AppColors colors;
  final VoidCallback onTap;

  const _PatientCard({
    required this.patient,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [colors.shadow],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: colors.sageLight,
              backgroundImage: patient.imagePath != null
                  ? FileImage(File(patient.imagePath!))
                  : null,
              child: patient.imagePath == null
                  ? Text(
                      patient.name.isNotEmpty
                          ? patient.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Name + hint
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textHigh,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 12, color: colors.textLow),
                      const SizedBox(width: 4),
                      Text(
                        'Profile & activity',
                        style:
                            TextStyle(fontSize: 12, color: colors.textLow),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(Icons.chevron_right_rounded,
                color: colors.textLow, size: 22),
          ],
        ),
      ),
    );
  }
}
