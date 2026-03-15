// lib/screens/manage_patients_screen.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_icon_button.dart';
import '../widgets/dashboard_action_card.dart';
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
        title: const Text('Add patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: _inputDecoration(
                'Name',
                colors,
                focusedBorderColor: colors.teal,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: _inputDecoration(
                'Notes (optional)',
                colors,
                focusedBorderColor: colors.teal,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.teal),
            ),
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

  void _showEditDialog(dynamic patient) {
    final colors = context.appColors;
    final nameController = TextEditingController(text: patient.name);
    final notesController = TextEditingController(text: patient.notes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.background,
        title: const Text('Edit patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: _inputDecoration(
                'Name',
                colors,
                focusedBorderColor: colors.teal,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: _inputDecoration(
                'Notes (optional)',
                colors,
                focusedBorderColor: colors.teal,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppState.removePatient(patient.id);
              Navigator.pop(ctx);
              if (mounted) Navigator.pop(context, true);
            },
            child: Text('Remove', style: TextStyle(color: colors.rose)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.teal),
            ),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              setState(() {
                patient.name = name;
                patient.notes = notesController.text.trim();
              });

              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: colors.teal,
              foregroundColor: colors.surface,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    AppColors colors, {
    Color? focusedBorderColor,
  }) =>
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
          borderSide: BorderSide(
            color: focusedBorderColor ?? colors.teal,
            width: 2,
          ),
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
          'Manage Patients',
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
                  ? const Center(child: Text('No patients yet.'))
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: patients.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final p = patients[i];

                        return DashboardActionCard(
                          title: p.name,
                          subtitle: (p.notes.toString().trim().isNotEmpty)
                              ? p.notes.toString().trim()
                              : 'View & edit profile',
                          backgroundColor: colors.background,
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
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: colors.sageLight,
                            child: Text(
                              p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: colors.teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          trailing: AppBackButton(
                            onTap: () => _showEditDialog(p),
                            color: colors.teal,
                            size: 24,
                            icon: Icons.edit_outlined,
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 200,
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
                        'Add patient',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
