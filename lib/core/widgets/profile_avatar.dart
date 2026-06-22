import 'package:flutter/material.dart';

import '../../theme/brand_gradient.dart';

/// A circular profile avatar — the [image] if given, else [initials] on a soft
/// surface. When [onEdit] is provided, a molten-gradient camera badge overlays the
/// bottom-right (the supervisor account screen). Sized by [size]; reused small in
/// the rail account row / app-bar avatar (no [onEdit]) and large on the profile.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.initials,
    this.size = 88,
    this.image,
    this.onEdit,
  });

  final String initials;
  final double size;
  final ImageProvider? image;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final editSize = (size * 0.34).clamp(22.0, 32.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surfaceContainerHighest,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              image: image != null
                  ? DecorationImage(image: image!, fit: BoxFit.cover)
                  : null,
            ),
            alignment: Alignment.center,
            child: image == null
                ? Text(
                    initials,
                    style:
                        (Theme.of(context).textTheme.titleLarge ??
                                const TextStyle())
                            .copyWith(
                              fontSize: size * 0.32,
                              fontWeight: FontWeight.w800,
                              height: 1,
                              color: scheme.onSurface,
                            ),
                  )
                : null,
          ),
          if (onEdit != null)
            Positioned(
              right: -2,
              bottom: -2,
              child: GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: editSize,
                  height: editSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: BrandGradient.diagonal,
                    border: Border.all(color: scheme.surface, width: 3),
                  ),
                  child: Icon(
                    Icons.photo_camera_rounded,
                    size: editSize * 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
