import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';

/// Animated typing indicator with three bouncing dots
class TypingIndicator extends StatelessWidget {
  final String name;
  final String photoUrl;

  const TypingIndicator({
    super.key,
    required this.name,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Row(
        children: [
          UserAvatarWidget(
            photoUrl: photoUrl,
            name: name,
            radius: 14,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBubbleReceive
                  : AppColors.lightBubbleReceive,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: AppColors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .moveY(
                      begin: 0,
                      end: -5,
                      curve: Curves.easeInOut,
                      duration: 500.ms,
                      delay: (i * 150).ms,
                    )
                    .then()
                    .moveY(begin: -5, end: 0, duration: 500.ms);
              }),
            ),
          ),
        ],
      ),
    );
  }
}
