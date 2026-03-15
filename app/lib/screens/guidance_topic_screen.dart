// lib/screens/guidance_topic_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/dashboard_action_card.dart';
import '../widgets/primary_icon_button.dart';
import 'guidance_result_screen.dart';

class GuidanceTopicScreen extends StatelessWidget {
  const GuidanceTopicScreen({super.key});

  static const _topics = [
    GuidanceTopic(
      label: 'Misremembered events',
      title: 'Misremembered Events',
      icon: Icons.history_edu_outlined,
      body:
          "When details don't line up, gently redirecting the conversation can help move things forward without conflict.",
      phrases: [
        '"Let\'s focus on what we know for sure right now."',
        '"That sounds like it was really important to you."',
        '"I\'m here with you — we can figure this out together."',
      ],
    ),
    GuidanceTopic(
      label: 'Time/place confusion',
      title: 'Time / Place Confusion',
      icon: Icons.place_outlined,
      body:
          'Grounding someone gently in the present — with familiar objects, gentle reminders, or a calm voice — can ease their confusion without escalating anxiety.',
      phrases: [
        '"You\'re at home — this is your living room."',
        '"It\'s a beautiful afternoon. Let\'s sit together for a bit."',
        '"Look, here\'s your favourite chair. You\'re safe."',
      ],
    ),
    GuidanceTopic(
      label: 'Repeated questions',
      title: 'Repeated Questions',
      icon: Icons.loop_outlined,
      body:
          'Repeated questions often come from anxiety rather than memory. Answering calmly and patiently each time helps them feel safe and heard.',
      phrases: [
        '"That\'s a great question. Let me tell you again."',
        '"Yes, dinner is at six — we have plenty of time."',
        '"I\'m happy to go over that with you whenever you need."',
      ],
    ),
    GuidanceTopic(
      label: 'Not recognizing people',
      title: 'Not Recognizing People',
      icon: Icons.person_search_outlined,
      body:
          "If they don't recognize you, reintroduce yourself gently and focus on building comfort in the moment rather than correcting them.",
      phrases: [
        '"Hi, I\'m [name]. I\'m here to help you today."',
        '"You don\'t have to remember me — I\'m just happy to be here with you."',
        '"Let\'s just sit together for a little while."',
      ],
    ),
    GuidanceTopic(
      label: 'Something else...',
      title: 'General Guidance',
      icon: Icons.lightbulb_outline,
      body:
          'Every situation is different. Focus on staying calm, validating their feelings, and redirecting gently when needed.',
      phrases: [
        '"I hear you. That sounds really hard."',
        '"You\'re not alone in this — I\'m right here."',
        '"Let\'s take it one step at a time."',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.sageLight,
      appBar: AppBar(
        backgroundColor: colors.sageLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: AppBackButton(
          color: colors.sage,
          onTap: () => Navigator.pop(context),
        ),
        title: Text(
          'Get Guidance',
          style: TextStyle(
            color: colors.textHigh,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header prompt
              Text(
                'What would you like guidance on?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: colors.textHigh,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 16),

              // Topic list
              Expanded(
                child: ListView.separated(
                  itemCount: _topics.length,
                  separatorBuilder: (_, sep) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final topic = _topics[i];
                      return DashboardActionCard(
                        title: topic.label,
                        icon: topic.icon,
                        color: colors.sage,
                        backgroundColor: colors.background,
                        isLarge: false,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GuidanceResultScreen(topic: topic),
                          ),
                        ),
                      );
                  },
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

class GuidanceTopic {
  final String label;
  final String title;
  final String body;
  final List<String> phrases;
  final IconData icon;

  const GuidanceTopic({
    required this.label,
    required this.title,
    required this.body,
    this.phrases = const [],
    this.icon = Icons.lightbulb_outline,
  });
}
