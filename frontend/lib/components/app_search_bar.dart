import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Search bar with clear button.
class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.hintText = '',
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return TextField(
      controller: controller,
      onChanged: (v) {
        if (onChanged != null) onChanged!(v);
      },
      onSubmitted: (v) {
        if (onSubmitted != null) onSubmitted!();
      },
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.search_rounded, color: c.textMuted, size: IconSize.medium),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(Icons.close_rounded, color: c.textMuted, size: IconSize.small),
              onPressed: () {
                controller.clear();
                if (onChanged != null) onChanged!('');
              },
            );
          },
        ),
        filled: true,
        fillColor: c.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
        border: OutlineInputBorder(
          borderRadius: Radii.rMedium,
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.rMedium,
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.rMedium,
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
      ),
    );
  }
}
