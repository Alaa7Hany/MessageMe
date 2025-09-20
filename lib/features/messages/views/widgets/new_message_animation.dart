// Add this class at the bottom of lib/features/messages/views/pages/messages_page.dart

import 'package:flutter/widgets.dart';

class NewMessageAnimation extends StatefulWidget {
  final Widget child;
  const NewMessageAnimation({super.key, required this.child});

  @override
  State<NewMessageAnimation> createState() => _NewMessageAnimationState();
}

class _NewMessageAnimationState extends State<NewMessageAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // This creates a nice "bouncy" effect
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
