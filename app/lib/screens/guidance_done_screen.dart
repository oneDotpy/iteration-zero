import 'package:flutter/material.dart';
import 'guidance_topic_screen.dart';

class GuidanceDoneScreen extends StatelessWidget {
  const GuidanceDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton.filled(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFABEB96),
                  foregroundColor: Colors.black,
                ),
              ),
              const Spacer(flex: 2),
              const Text(
                'Happy to help.',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const Spacer(flex: 2),
              Center(
                child: SizedBox(
                width: 200,
                child: FilledButton(
                  onPressed: () {
                    // Pop back to caregiver home, then push fresh guidance
                    Navigator.of(context).popUntil((r) => r.isFirst);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const GuidanceTopicScreen()),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFFE8FFD9),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Get more guidance',
                      style: TextStyle(fontSize: 16)),
                ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                width: 200,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFFABEB96),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Home', style: TextStyle(fontSize: 16)),
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
