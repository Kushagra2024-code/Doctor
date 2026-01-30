import 'package:flutter/material.dart';

/// Microphone button with animated listening indicator
class MicButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const MicButton({
    super.key,
    required this.isListening,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isListening
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: isListening
                  ? theme.colorScheme.error.withOpacity(0.3)
                  : theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: isListening ? 20 : 10,
              spreadRadius: isListening ? 5 : 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing ring animation when listening
            if (isListening)
              AnimatedPulsingRing(
                color: theme.colorScheme.error,
              ),

            // Microphone icon
            Icon(
              isListening ? Icons.mic : Icons.mic_none,
              size: 40,
              color: isListening
                  ? theme.colorScheme.onError
                  : theme.colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated pulsing ring for listening state
class AnimatedPulsingRing extends StatefulWidget {
  final Color color;

  const AnimatedPulsingRing({
    super.key,
    required this.color,
  });

  @override
  State<AnimatedPulsingRing> createState() => _AnimatedPulsingRingState();
}

class _AnimatedPulsingRingState extends State<AnimatedPulsingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 80 + (_animation.value * 40),
          height: 80 + (_animation.value * 40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withOpacity(1.0 - _animation.value),
              width: 3,
            ),
          ),
        );
      },
    );
  }
}
