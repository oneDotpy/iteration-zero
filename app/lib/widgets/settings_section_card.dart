// lib/widgets/settings_section_card.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.textLow,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [colors.shadow],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: _buildChildren(context, colors),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildren(BuildContext context, AppColors colors) {
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(Divider(
          height: 1,
          thickness: 1,
          color: colors.border,
          indent: 16,
          endIndent: 16,
        ));
      }
    }
    return result;
  }
}
