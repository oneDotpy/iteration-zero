import 'package:flutter/material.dart';
import 'caregiver_home_screen.dart';
import 'patient_home_screen.dart';

class SetupDoneScreen extends StatelessWidget {
	static const _lightYellow = Color(0xFFFFF8D9);
	static const _darkYellow = Color(0xFFFFDD8F);

	final bool isCaregiver;

	const SetupDoneScreen({super.key, required this.isCaregiver});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: _lightYellow,
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.center,
						children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
							const Spacer(flex: 2),
							const Center(
								child: Text(
									'Account set up.',
									textAlign: TextAlign.center,
									style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
								),
							),
							const SizedBox(height: 8),
							const Center(
								child: Text(
									'You are ready to continue.',
									textAlign: TextAlign.center,
									style: TextStyle(fontSize: 15, color: Colors.black45),
								),
							),
							const Spacer(flex: 2),
							Center(
								child: SizedBox(
									width: 200,
									child: FilledButton(
										onPressed: () => Navigator.pushAndRemoveUntil(
											context,
											MaterialPageRoute(
												builder: (_) => isCaregiver
														? const CaregiverHomeScreen()
														: const PatientHomeScreen(),
											),
											(route) => false,
										),
										style: FilledButton.styleFrom(
											padding: const EdgeInsets.symmetric(vertical: 18),
											backgroundColor: _darkYellow,
											foregroundColor: Colors.black,
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(12),
											),
										),
										child: const Text('Continue', style: TextStyle(fontSize: 16)),
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
