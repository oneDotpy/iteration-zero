// lib/screens/guidance_result_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';
import '../widgets/primary_cta_button.dart';
import 'guidance_topic_screen.dart';
import 'guidance_done_screen.dart';

class GuidanceResultScreen extends StatelessWidget {
  final GuidanceTopic topic;
  const GuidanceResultScreen({super.key, required this.topic});

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
          topic.title,
          style: TextStyle(
            color: colors.textHigh,
            fontSize: 18,
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
              // Main guidance card
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.menu_book_outlined,
                            color: colors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Guidance',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      topic.body,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.6,
                        color: colors.textHigh,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Suggested phrases section
              if (topic.phrases.isNotEmpty) ...[
                Text(
                  'Suggested phrases',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textHigh,
                  ),
                ),
                const SizedBox(height: 12),
                ...topic.phrases.map(
                  (phrase) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [colors.shadow],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left sage accent bar
                            Container(
                              width: 4,
                              color: colors.sage,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                child: Text(
                                  phrase,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    color: colors.textHigh,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const Spacer(),

              PrimaryCtaButton(
                label: 'Done',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GuidanceDoneScreen(),
                  ),
                ),
                color: colors.primary,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
