// lib/screens/guidance_topic_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';
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
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [colors.shadow],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: colors.textHigh,
              size: 18,
            ),
          ),
        ),
        title: Text(
          'Get Guidance',
          style: TextStyle(
            color: colors.textHigh,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              SoftCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: colors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'What would you like guidance on?',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: colors.textHigh,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
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
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GuidanceResultScreen(topic: topic),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [colors.shadow],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                topic.icon,
                                color: colors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                topic.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textHigh,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: colors.textLow,
                              size: 22,
                            ),
                          ],
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
