import 'package:flutter/material.dart';

/// Pre-configured text styles that enforce minimum sizes and
/// honour system font-scale up to 200%. Use these instead of
/// raw Text() with hardcoded sizes throughout elder screens.
class AccessibleText extends StatelessWidget {
  const AccessibleText(this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    this.semanticsLabel,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;
  final String? semanticsLabel;

  // ── Named constructors for common roles ─────────────────────────
  const AccessibleText.heading(this.text, {super.key, this.textAlign, this.semanticsLabel})
      : style = null, maxLines = null, overflow = null, softWrap = true;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? _defaultStyle(context),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      semanticsLabel: semanticsLabel,
      textScaler: _clampedScaler(context),
    );
  }

  TextStyle _defaultStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!;

  /// Clamp text scaling to 200% maximum for layout safety.
  TextScaler _clampedScaler(BuildContext context) {
    final sys = MediaQuery.textScalerOf(context);
    return TextScaler.linear(sys.scale(1.0).clamp(0.8, 2.0));
  }
}

/// Heading: 32sp, bold
class ElderHeading extends StatelessWidget {
  const ElderHeading(this.text, {super.key, this.textAlign, this.color});
  final String text;
  final TextAlign? textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.headlineMedium!;
    return Text(
      text,
      style: base.copyWith(color: color),
      textAlign: textAlign,
      textScaler: TextScaler.linear(
        MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 2.0),
      ),
    );
  }
}

/// Body: 20sp — comfortable reading size for elders
class ElderBody extends StatelessWidget {
  const ElderBody(this.text, {super.key, this.textAlign, this.color, this.maxLines});
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyLarge!;
    return Text(
      text,
      style: base.copyWith(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      textScaler: TextScaler.linear(
        MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 2.0),
      ),
    );
  }
}

/// Caption: 16sp — smallest text used in the app
class ElderCaption extends StatelessWidget {
  const ElderCaption(this.text, {super.key, this.textAlign, this.color});
  final String text;
  final TextAlign? textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium!;
    return Text(
      text,
      style: base.copyWith(color: color ?? Theme.of(context).colorScheme.onSurfaceVariant),
      textAlign: textAlign,
      textScaler: TextScaler.linear(
        MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 2.0),
      ),
    );
  }
}
