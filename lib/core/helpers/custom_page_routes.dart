import 'package:flutter/material.dart';

/// A collection of reusable custom page route transitions.
///
/// Each route accepts an optional [duration] to customize the animation speed.
/// The default duration for all transitions is 500 milliseconds.

// Default transition duration used across all custom routes.
const Duration _kDefaultTransitionDuration = Duration(milliseconds: 500);

//==============================================================================
// 1. FADE TRANSITION
//==============================================================================

/// A page route that fades the new page in.
class FadeRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  FadeRoute({required this.page, this.duration = _kDefaultTransitionDuration})
    : super(
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
}

//==============================================================================
// 2. SLIDE TRANSITION
//==============================================================================

/// A page route that slides the new page in from the right.
class SlideRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  SlideRoute({required this.page, this.duration = _kDefaultTransitionDuration})
    : super(
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final curve = Curves.ease;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
}

//==============================================================================
// 3. SCALE (ZOOM) TRANSITION
//==============================================================================

/// A page route that scales the new page in from the center.
class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  ScaleRoute({required this.page, this.duration = _kDefaultTransitionDuration})
    : super(
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
            ),
            child: child,
          );
        },
      );
}

//==============================================================================
// 4. ROTATION & SCALE TRANSITION
//==============================================================================

/// A page route that rotates and scales the new page in.
class RotationScaleRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  RotationScaleRoute({
    required this.page,
    this.duration = _kDefaultTransitionDuration,
  }) : super(
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return ScaleTransition(
             scale: Tween<double>(begin: 0.0, end: 1.0).animate(
               CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
             ),
             child: RotationTransition(
               turns: Tween<double>(begin: 0.5, end: 1.0).animate(
                 CurvedAnimation(
                   parent: animation,
                   curve: Curves.fastOutSlowIn,
                 ),
               ),
               child: child,
             ),
           );
         },
       );
}

//==============================================================================
// 5. SIZE (REVEAL) TRANSITION
//==============================================================================

/// A page route that reveals the new page by growing its size from the center.
class SizeRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  SizeRoute({required this.page, this.duration = _kDefaultTransitionDuration})
    : super(
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Align(
            alignment: Alignment.center,
            child: SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              ),
              child: child,
            ),
          );
        },
      );
}

//==============================================================================
// 6. SLIDE & FADE TRANSITION
//==============================================================================

/// A page route that slides the new page in from the bottom while fading it in.
class SlideFadeRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  SlideFadeRoute({
    required this.page,
    this.duration = _kDefaultTransitionDuration,
  }) : super(
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return SlideTransition(
             position:
                 Tween<Offset>(
                   begin: const Offset(0, 0.1), // Start slightly below
                   end: Offset.zero,
                 ).animate(
                   CurvedAnimation(parent: animation, curve: Curves.easeOut),
                 ),
             child: FadeTransition(opacity: animation, child: child),
           );
         },
       );
}
