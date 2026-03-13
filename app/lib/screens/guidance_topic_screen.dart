import 'package:flutter/material.dart';
import 'guidance_result_screen.dart';

class GuidanceTopicScreen extends StatelessWidget {
  const GuidanceTopicScreen({super.key});

  static const _topics = [
    GuidanceTopic(
      label: 'Misremembered events',
      title: 'Misremembered Events',
      body:
          "When details don't line up, gently redirecting the conversation can help move things forward without conflict.",
    ),
    GuidanceTopic(
      label: 'Time/place confusion',
      title: 'Time / Place Confusion',
      body:
          'Grounding someone gently in the present — with familiar objects, gentle reminders, or a calm voice — can ease their confusion without escalating anxiety.',
    ),
    GuidanceTopic(
      label: 'Repeated questions',
      title: 'Repeated Questions',
      body:
          'Repeated questions often come from anxiety rather than memory. Answering calmly and patiently each time helps them feel safe and heard.',
    ),
    GuidanceTopic(
      label: 'Not recognizing people',
      title: 'Not Recognizing People',
      body:
          "If they don't recognize you, reintroduce yourself gently and focus on building comfort in the moment rather than correcting them.",
    ),
    GuidanceTopic(
      label: 'Something else...',
      title: 'General Guidance',
      body:
          'Every situation is different. Focus on staying calm, validating their feelings, and redirecting gently when needed.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8FFD9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
              const SizedBox(height: 8),
              const Text(
                'What would you like guidance on?',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ..._topics.map(
                (topic) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GuidanceResultScreen(topic: topic),
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFFABEB96),
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        topic.label,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(filled: true),
                  const SizedBox(width: 8),
                  _dot(filled: true),
                  const SizedBox(width: 8),
                  _dot(filled: true),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot({bool filled = false}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? const Color(0xFFABEB96) : Colors.black26,
      ),
    );
  }
}

class GuidanceTopic {
  final String label;
  final String title;
  final String body;
  const GuidanceTopic({
    required this.label,
    required this.title,
    required this.body,
  });
}
