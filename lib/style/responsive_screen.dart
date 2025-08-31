// File: lib/src/style/responsive_screen.dart
import 'package:flutter/material.dart';

/// A responsive screen layout that adapts to different screen sizes
class ResponsiveScreen extends StatelessWidget {
  const ResponsiveScreen({
    super.key,
    required this.squarishMainArea,
    this.rectangularMenuArea,
  });

  final Widget squarishMainArea;
  final Widget? rectangularMenuArea;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // On wide screens, put content side by side
        if (constraints.maxWidth > constraints.maxHeight) {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: squarishMainArea,
              ),
              if (rectangularMenuArea != null)
                Expanded(
                  child: rectangularMenuArea!,
                ),
            ],
          );
        }

        // On tall screens, stack vertically
        return Column(
          children: [
            Expanded(
              child: squarishMainArea,
            ),
            if (rectangularMenuArea != null)
              SafeArea(
                top: false,
                child: rectangularMenuArea!,
              ),
          ],
        );
      },
    );
  }
}