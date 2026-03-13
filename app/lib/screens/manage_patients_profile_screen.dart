import 'package:flutter/material.dart';
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
	static const _lightPink = Color(0xFFFDEAEC);
	static const _darkPink = Color(0xFFFFC5CA);

	void _showEditDialog() {
		final patient = widget.patient;
		final nameController = TextEditingController(text: patient.name);
		final notesController = TextEditingController(text: patient.notes);

		showDialog(
			context: context,
			builder: (ctx) => AlertDialog(
				title: const Text('Edit patient'),
				content: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
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
							child: const Text('Remove', style: TextStyle(color: Colors.red)),
						),
					TextButton(
						onPressed: () => Navigator.pop(ctx),
						child: const Text('Cancel', style: TextStyle(color: Colors.black45)),
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
							backgroundColor: Colors.black,
							foregroundColor: Colors.white,
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

		return Scaffold(
			body: SafeArea(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Container(
							width: double.infinity,
							decoration: const BoxDecoration(
								color: _lightPink,
								borderRadius: BorderRadius.only(
									bottomLeft: Radius.circular(20),
									bottomRight: Radius.circular(20),
								),
							),
							padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
							child: Column(
								children: [
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [
											IconButton.filled(
												icon: const Icon(Icons.arrow_back),
												onPressed: () => Navigator.pop(context),
												padding: EdgeInsets.zero,
												style: IconButton.styleFrom(
													backgroundColor: _darkPink,
													foregroundColor: Colors.black,
												),
											),
											IconButton.filled(
												onPressed: _showEditDialog,
												icon: const Icon(Icons.edit_outlined, size: 18),
												style: IconButton.styleFrom(
													backgroundColor: _darkPink,
													foregroundColor: Colors.black,
												),
											),
										],
									),
									const SizedBox(height: 24),
									CircleAvatar(
										radius: 60,
										backgroundColor: Colors.white,
										child: Text(
											patient.name.isNotEmpty
													? patient.name[0].toUpperCase()
													: '?',
											style: const TextStyle(
												fontSize: 44,
												fontWeight: FontWeight.bold,
												color: Colors.black,
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
							child: Padding(
								padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.stretch,
									children: [
										Text(
											patient.notes.isEmpty ? 'No notes yet.' : patient.notes,
											textAlign: TextAlign.center,
											style: const TextStyle(
												fontSize: 18,
												color: Colors.black54,
												height: 1.4,
											),
										),
										const Spacer(),
										Center(
											child: SizedBox(
												width: 200,
												child: FilledButton(
												onPressed: () => Navigator.pop(context),
												style: FilledButton.styleFrom(
													padding: const EdgeInsets.symmetric(vertical: 18),
													backgroundColor: _darkPink,
													foregroundColor: Colors.black,
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(12),
													),
												),
												child: const Text('Done', style: TextStyle(fontSize: 16)),
												),
											),
										),
										const SizedBox(height: 16),
									],
								),
							),
						),
					],
				),
			),
		);
	}

	InputDecoration _inputDecoration(String hint) => InputDecoration(
				hintText: hint,
				hintStyle: const TextStyle(color: Colors.black26),
				filled: true,
				fillColor: Colors.grey[100],
				contentPadding:
						const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(10),
					borderSide: const BorderSide(color: Colors.black26),
				),
				enabledBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(10),
					borderSide: const BorderSide(color: Colors.black26),
				),
				focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(10),
					borderSide: const BorderSide(color: Colors.black, width: 1.5),
				),
			);
}
