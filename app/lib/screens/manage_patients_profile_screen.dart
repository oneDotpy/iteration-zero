import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/primary_cta_button.dart';
import '../widgets/primary_icon_button.dart';
import '../theme/app_colors.dart';
import '../app_state.dart';
import 'patient_activity_screen.dart';

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

	final _picker = ImagePicker();

	Future<void> _pickPhoto() async {
		final source = await showModalBottomSheet<ImageSource>(
			context: context,
			shape: const RoundedRectangleBorder(
				borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
			),
			builder: (ctx) => SafeArea(
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						const SizedBox(height: 8),
						ListTile(
							leading: const Icon(Icons.camera_alt_outlined),
							title: const Text('Take a photo'),
							onTap: () => Navigator.pop(ctx, ImageSource.camera),
						),
						ListTile(
							leading: const Icon(Icons.photo_library_outlined),
							title: const Text('Choose from library'),
							onTap: () => Navigator.pop(ctx, ImageSource.gallery),
						),
						if (widget.patient.imagePath != null)
							ListTile(
								leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
								title: const Text('Remove photo', style: TextStyle(color: Colors.redAccent)),
								onTap: () => Navigator.pop(ctx, null),
							),
						const SizedBox(height: 8),
					],
				),
			),
		);
		if (!mounted) return;
		if (source == null && widget.patient.imagePath != null) {
			setState(() => widget.patient.imagePath = null);
			return;
		}
		if (source == null) return;
		final file = await _picker.pickImage(source: source, imageQuality: 85);
		if (file != null && mounted) {
			setState(() => widget.patient.imagePath = file.path);
		}
	}

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

	void _openActivity() {
		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (_) => PatientActivityScreen(patient: widget.patient),
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
						// ── Header ────────────────────────────────────────────────
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
									GestureDetector(
										onTap: _pickPhoto,
										child: Stack(
											alignment: Alignment.bottomRight,
											children: [
												CircleAvatar(
													radius: 60,
													backgroundColor: colors.surface,
													backgroundImage: patient.imagePath != null
														? FileImage(File(patient.imagePath!))
														: null,
													child: patient.imagePath == null
														? Text(
																patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
																style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: colors.teal),
															)
														: null,
												),
												Container(
													decoration: BoxDecoration(
														color: colors.teal,
														shape: BoxShape.circle,
														border: Border.all(color: colors.tealLight, width: 2),
													),
													padding: const EdgeInsets.all(6),
													child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
												),
											],
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
									const SizedBox(height: 4),
								],
							),
						),

						// ── Scrollable body ───────────────────────────────────────
						Expanded(
							child: SingleChildScrollView(
								padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.stretch,
									children: [

										// ── Activity card ─────────────────────────────────
										GestureDetector(
											onTap: _openActivity,
											child: Container(
												padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
												decoration: BoxDecoration(
													color: colors.teal,
													borderRadius: BorderRadius.circular(16),
													boxShadow: [
														BoxShadow(
															color: colors.teal.withOpacity(0.25),
															blurRadius: 12,
															offset: const Offset(0, 4),
														),
													],
												),
												child: Row(
													children: [
														Container(
															width: 42,
															height: 42,
															decoration: BoxDecoration(
																color: Colors.white.withOpacity(0.20),
																shape: BoxShape.circle,
															),
															child: const Icon(
																Icons.bar_chart_rounded,
																color: Colors.white,
																size: 22,
															),
														),
														const SizedBox(width: 14),
														Expanded(
															child: Column(
																crossAxisAlignment: CrossAxisAlignment.start,
																children: [
																	const Text(
																		'View Activity',
																		style: TextStyle(
																			fontSize: 16,
																			fontWeight: FontWeight.w700,
																			color: Colors.white,
																		),
																	),
																	Text(
																		'Today\'s usage & weekly trends',
																		style: TextStyle(
																			fontSize: 13,
																			color: Colors.white.withOpacity(0.75),
																		),
																	),
																],
															),
														),
														Icon(
															Icons.chevron_right_rounded,
															color: Colors.white.withOpacity(0.75),
															size: 22,
														),
													],
												),
											),
										),

										const SizedBox(height: 24),

										// ── Notes ─────────────────────────────────────────
										if (patient.notes.isNotEmpty) ...[
											Text(
												'Notes',
												style: TextStyle(
													fontSize: 12,
													fontWeight: FontWeight.w700,
													color: colors.textLow,
													letterSpacing: 1.2,
												),
											),
											const SizedBox(height: 8),
											Text(
												patient.notes,
												textAlign: TextAlign.left,
												style: TextStyle(
													fontSize: 16,
													color: colors.textMed,
													height: 1.5,
												),
											),
										] else
											Text(
												'No notes yet. Tap the edit button to add notes.',
												textAlign: TextAlign.center,
												style: TextStyle(
													fontSize: 15,
													color: colors.textLow,
													height: 1.4,
												),
											),
									],
								),
							),
						),

						// ── Done button ───────────────────────────────────────────
						Container(
							padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
							child: PrimaryCtaButton(
								label: 'Done',
								onTap: () => Navigator.pop(context),
								color: colors.teal,
							),
						),
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
