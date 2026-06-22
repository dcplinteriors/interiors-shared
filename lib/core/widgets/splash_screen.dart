import 'package:flutter/material.dart';

import 'brand_logo.dart';

/// The launch splash — the DCPL brand lock-up centred on the dark surface while
/// the app initializes (Firebase + auth check) before routing to login or home.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.height = 88});

  /// Height of the brand lock-up.
  final double height;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    body: Center(child: BrandWordmark(height: height, tagline: true)),
  );
}
