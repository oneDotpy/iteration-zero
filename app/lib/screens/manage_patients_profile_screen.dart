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
					ElevatedButton(
						onPressed: () {
							final name = nameController.text.trim();
							if (name.isEmpty) return;
							patient.name = name;
							patient.notes = notesController.text.trim();
							Navigator.pop(ctx);
							setState(() {});
						},
						style: ElevatedButton.styleFrom(
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
				child: Padding(
					padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									IconButton(
										icon: const Icon(Icons.arrow_back),
										onPressed: () => Navigator.pop(context),
										padding: EdgeInsets.zero,
									),
									TextButton.icon(
										onPressed: _showEditDialog,
										icon: const Icon(Icons.edit_outlined, size: 18),
										label: const Text('Edit'),
										style: TextButton.styleFrom(
											foregroundColor: Colors.black54,
										),
									),
								],
							),
							const SizedBox(height: 56),
							CircleAvatar(
								radius: 60,
								backgroundColor: Colors.grey[200],
								child: Text(
									patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
									style: const TextStyle(
										fontSize: 44,
										fontWeight: FontWeight.bold,
										color: Colors.black,
									),
								),
							),
							const SizedBox(height: 20),
							Text(
								patient.name,
								textAlign: TextAlign.center,
								style: const TextStyle(
									fontSize: 34,
									fontWeight: FontWeight.bold,
								),
							),
							const SizedBox(height: 20),
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
							SizedBox(
								width: double.infinity,
								child: FilledButton(
									onPressed: () => Navigator.pop(context),
									style: FilledButton.styleFrom(
										padding: const EdgeInsets.symmetric(vertical: 16),
										backgroundColor: Colors.grey[200],
										foregroundColor: Colors.black,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(12),
										),
									),
									child: const Text('Done', style: TextStyle(fontSize: 18)),
								),
							),
							const SizedBox(height: 8),
						],
					),
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
