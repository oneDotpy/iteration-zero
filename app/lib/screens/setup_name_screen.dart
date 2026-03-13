import 'package:flutter/material.dart';
import '../app_state.dart';
import 'setup_done_screen.dart';

enum _SelectedRole { caregiver, patient }

class SetupNameScreen extends StatefulWidget {
	const SetupNameScreen({super.key});

	@override
	State<SetupNameScreen> createState() => _SetupNameScreenState();
}

class _SetupNameScreenState extends State<SetupNameScreen> {
	final _nameController = TextEditingController();
	_SelectedRole? _selectedRole;

	@override
	void dispose() {
		_nameController.dispose();
		super.dispose();
	}

	bool get _isNextEnabled =>
			_nameController.text.trim().isNotEmpty && _selectedRole != null;

	void _next() {
		AppState.completeSignup(
			name: _nameController.text,
			isCaregiver: _selectedRole == _SelectedRole.caregiver,
		);

		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (_) => SetupDoneScreen(
					isCaregiver: _selectedRole == _SelectedRole.caregiver,
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							IconButton(
								icon: const Icon(Icons.arrow_back),
								onPressed: () => Navigator.pop(context),
								padding: EdgeInsets.zero,
							),
							const Spacer(flex: 1),
							const Center(
								child: Text(
									'What should we call you?',
									textAlign: TextAlign.center,
									style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
								),
							),
							const SizedBox(height: 8),
							const Center(
								child: Text(
									'This helps personalize guidance.',
									textAlign: TextAlign.center,
									style: TextStyle(fontSize: 15, color: Colors.black45),
								),
							),
							const SizedBox(height: 40),
							const Text(
								'Your name',
								style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
							),
							const SizedBox(height: 6),
							TextField(
								controller: _nameController,
								autocorrect: false,
								onChanged: (_) => setState(() {}),
								onSubmitted: (_) {
									if (_isNextEnabled) {
										_next();
									}
								},
								decoration: InputDecoration(
									hintText: 'Your name',
									hintStyle: const TextStyle(color: Colors.black26),
									filled: true,
									fillColor: Colors.grey[100],
									contentPadding:
											const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(12),
										borderSide: const BorderSide(color: Colors.black26),
									),
									enabledBorder: OutlineInputBorder(
										borderRadius: BorderRadius.circular(12),
										borderSide: const BorderSide(color: Colors.black26),
									),
									focusedBorder: OutlineInputBorder(
										borderRadius: BorderRadius.circular(12),
										borderSide: const BorderSide(color: Colors.black, width: 1.5),
									),
								),
							),
							const SizedBox(height: 20),
							const Text(
								'I am a',
								style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
							),
							const SizedBox(height: 8),
							Row(
								children: [
									Expanded(
										child: FilledButton(
											onPressed: () => setState(
													() => _selectedRole = _SelectedRole.caregiver,
											),
											style: FilledButton.styleFrom(
												padding: const EdgeInsets.symmetric(vertical: 18),
												backgroundColor: _selectedRole == _SelectedRole.caregiver
														? Colors.black
														: Colors.grey[200],
												foregroundColor: _selectedRole == _SelectedRole.caregiver
														? Colors.white
														: Colors.black,
												shape: RoundedRectangleBorder(
													borderRadius: BorderRadius.circular(12),
												),
											),
											child: const Text('Caregiver', style: TextStyle(fontSize: 16)),
										),
									),
									const SizedBox(width: 10),
									Expanded(
										child: FilledButton(
											onPressed: () => setState(
													() => _selectedRole = _SelectedRole.patient,
											),
											style: FilledButton.styleFrom(
												padding: const EdgeInsets.symmetric(vertical: 18),
												backgroundColor: _selectedRole == _SelectedRole.patient
														? Colors.black
														: Colors.grey[200],
												foregroundColor: _selectedRole == _SelectedRole.patient
														? Colors.white
														: Colors.black,
												shape: RoundedRectangleBorder(
													borderRadius: BorderRadius.circular(12),
												),
											),
											child: const Text('Patient', style: TextStyle(fontSize: 16)),
										),
									),
								],
							),
							const Spacer(flex: 2),
							SizedBox(
								width: double.infinity,
								child: FilledButton(
									onPressed: _isNextEnabled ? _next : null,
									style: FilledButton.styleFrom(
										padding: const EdgeInsets.symmetric(vertical: 18),
										backgroundColor: Colors.black,
										foregroundColor: Colors.white,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(12),
										),
									),
									child: const Text('Next', style: TextStyle(fontSize: 16)),
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
