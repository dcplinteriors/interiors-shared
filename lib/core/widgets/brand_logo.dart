import 'package:flutter/material.dart';

/// Asset paths for the official DCPL logo artwork (gradient wordmark on a
/// transparent background — drops straight onto the dark theme).
class BrandAssets {
  BrandAssets._();

  /// Wordmark only ("DCPL").
  static const logo = 'packages/dcpl_shared/assets/branding/dcpl_logo.png';

  /// Wordmark + "Diverse Creation Private Limited" tagline — the full lock-up.
  static const brand = 'packages/dcpl_shared/assets/branding/dcpl_brand.png';
}

/// The DCPL brand logo — renders the official gradient artwork (PNG), never
/// text. [tagline] = false → the wordmark ([BrandAssets.logo]); true → the full
/// lock-up with the company name ([BrandAssets.brand]).
///
/// Sized by [height]; width scales to the asset's aspect ratio. Use the lock-up
/// (tagline) on the login & splash hero; the plain wordmark in compact spots
/// such as the nav header.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.height = 40, this.tagline = false});

  final double height;
  final bool tagline;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      tagline ? BrandAssets.brand : BrandAssets.logo,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'DCPL',
    );
  }
}

/// A compact brand mark for tight, width-constrained spots (e.g. an app-bar
/// leading): the DCPL wordmark scaled to fit within a [size]-tall box, never
/// overflowing. Prefer [BrandWordmark] where horizontal room allows.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: Image.asset(
        BrandAssets.logo,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'DCPL',
      ),
    );
  }
}
