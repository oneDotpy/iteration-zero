import 'package:flutter/material.dart';
import '../widgets/primary_cta_button.dart';
import '../widgets/primary_icon_button.dart';
import '../theme/app_colors.dart';
import '../app_state.dart';

class ManagePatientsProfileScreen extends StatefulWidget {
	final PatientProfile patient;

	const ManagePatientsProfileScreen({
		super.key,
		required this.patient,
	});

	@override
	State<ManagePatientsProfileScreen> createState() =>
			_ManagePatientsProfileScreenState();
}

class _ManagePatientsProfileScreenState extends State<ManagePatientsProfileScreen> {

	void _showEditDialog() {
		final patient = widget.patient;
		final colors = context.appColors;
		final nameController = TextEditingController(text: patient.name);
		final notesController = TextEditingController(text: patient.notes);

		showDialog(
			context: context,
			builder: (ctx) => AlertDialog(
				backgroundColor: colors.background,
				title: const Text('Edit care recipient'),
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
					if (patient.id != AppState.defaultPatientId)
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
							patient.name = name;
							patient.notes = notesController.text.trim();
							Navigator.pop(ctx);
							setState(() {});
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

	@override
	Widget build(BuildContext context) {
		final patient = widget.patient;
		final colors = context.appColors;


		return Scaffold(
			body: SafeArea(
				top: true,
				bottom: false,
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						// Fill the top SafeArea (dynamic island) with tealLight
						Container(
							color: colors.tealLight,
							height: MediaQuery.of(context).padding.top,
						),
						Container(
							width: double.infinity,
							decoration: BoxDecoration(
								color: colors.tealLight,
								borderRadius: const BorderRadius.only(
									bottomLeft: Radius.circular(20),
									bottomRight: Radius.circular(20),
								),
								boxShadow: [
									BoxShadow(
										color: Colors.black.withOpacity(0.10),
										blurRadius: 18,
										offset: const Offset(0, 8),
									),
								],
							),
							padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
							child: Column(
								children: [
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [
											
											AppBackButton(
												onTap: () => Navigator.pop(context),
												color: colors.teal,
												size: 32,
												icon: Icons.arrow_back_rounded,
											),
											AppBackButton(
												onTap: _showEditDialog,
												color: colors.teal,
												size: 32,
												icon: Icons.edit_outlined,
											),
										],
									),
									const SizedBox(height: 24),
									CircleAvatar(
										radius: 60,
										backgroundColor: colors.surface,
										child: Text(
											patient.name.isNotEmpty
													? patient.name[0].toUpperCase()
													: '?',
											style: TextStyle(
												fontSize: 44,
												fontWeight: FontWeight.bold,
												color: colors.teal,
											),
										),
									),
									const SizedBox(height: 16),
									Text(
										patient.name,
										textAlign: TextAlign.center,
										style: const TextStyle(
											fontSize: 34,
											fontWeight: FontWeight.bold,
										),
									),
								],
							),
						),
						Expanded(
              
							child: SingleChildScrollView(
								padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.stretch,
									children: [
										Text(
											patient.notes.isEmpty ? 'No notes yet.' : patient.notes,
											textAlign: TextAlign.center,
											style: TextStyle(
												fontSize: 18,
												color: colors.textMed,
												height: 1.4,
											),
										),
									],
								),
							),
							
						),
						Container(
							padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
							child: PrimaryCtaButton(
								label: 'Done',
								onTap: () => Navigator.pop(context),
								color: colors.teal,
							),
						)
					],
				),
			),
		);
	}

	InputDecoration _inputDecoration(String hint, AppColors colors) => InputDecoration(
				hintText: hint,
				hintStyle: TextStyle(color: colors.textLow),
				filled: true,
				fillColor: colors.surfaceAlt.withValues(alpha: 0.4),
				contentPadding:
						const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(10),
					borderSide: BorderSide(color: colors.border),
				),
				enabledBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(10),
					borderSide: BorderSide(color: colors.border),
				),
				focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(10),
					borderSide: BorderSide(color: colors.teal, width: 2),
				),
			);
}
