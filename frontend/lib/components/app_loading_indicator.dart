import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Simple centered loading indicator.
class AppLoadingIndicator extends StatelessWidget {
  final String? message;

  const AppLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: c.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(message!, style: TextStyle(fontSize: 13, color: c.textSecondary)),
          ],
        ],
      ),
    );
  }
}
