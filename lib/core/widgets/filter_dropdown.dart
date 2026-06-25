import 'package:flutter/material.dart';

/// One option in a [FilterDropdown] — its [value] and the label shown for it.
///
/// [swatch] optionally tints a small leading dot before the label (e.g. a status
/// filter colour-coding each state); options without one render as plain text.
class FilterOption<T> {
  const FilterOption(this.value, this.label, {this.swatch});
  final T value;
  final String label;
  final Color? swatch;
}

/// A compact bordered dropdown for list filters (status / project / work order …).
///
/// Disabled dropdowns still show their current value but can't be opened (e.g. a
/// work-order filter before a project is chosen).
class FilterDropdown<T> extends StatelessWidget {
  const FilterDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  final T value;
  final List<FilterOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Compact label voice (Inter), NOT the dropdown's heavy Sora `titleMedium`
    // default. Muted when disabled.
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: enabled ? scheme.onSurface : scheme.onSurfaceVariant,
    );
    // Calm hairline on every state — a filter chip shouldn't flash the form
    // field's crimson focus ring (overrides the global inputDecorationTheme).
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );
    // IntrinsicWidth: a form field expands to its parent's max width by default,
    // which inside a Wrap stretches the chip full-width — this hugs the content.
    return IntrinsicWidth(
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isDense: true,
        // Fill the IntrinsicWidth box exactly (ellipsize if needed) rather than
        // letting the label+chevron row overflow it by a few px.
        isExpanded: true,
        style: labelStyle,
        borderRadius: BorderRadius.circular(10),
        dropdownColor: scheme.surfaceContainerHigh,
        iconSize: 20,
        icon: Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Icon(Icons.expand_more, color: scheme.onSurfaceVariant),
        ),
        decoration: InputDecoration(
          // Subtle filled chip so it reads as a tappable control on dark cards.
          filled: true,
          fillColor: scheme.surfaceContainerHigh,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          border: border,
          enabledBorder: border,
          disabledBorder: border,
          focusedBorder: border,
        ),
        items: [
          for (final option in options)
            DropdownMenuItem(value: option.value, child: _OptionLabel(option)),
        ],
        onChanged: enabled ? (v) => onChanged(v as T) : null,
      ),
    );
  }
}

/// An option's label, prefixed with a small colour dot when it carries a
/// [FilterOption.swatch]. Shared by the menu items and the collapsed field.
class _OptionLabel<T> extends StatelessWidget {
  const _OptionLabel(this.option);

  final FilterOption<T> option;

  @override
  Widget build(BuildContext context) {
    final text = Text(option.label, overflow: TextOverflow.ellipsis);
    final swatch = option.swatch;
    if (swatch == null) return text;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(color: swatch, shape: BoxShape.circle),
        ),
        Flexible(child: text),
      ],
    );
  }
}
