import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Flowbite-style card with optional header, badge and icon.
class FbCard extends StatelessWidget {
  const FbCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.icon,
    this.iconColor,
    this.padding = const EdgeInsets.all(16),
    this.accentBorder,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;
  final Color? iconColor;
  final EdgeInsets padding;
  final Color? accentBorder;

  @override
  Widget build(BuildContext context) {
    final hasHeader = title != null || icon != null;

    return Container(
      decoration: AppDecorations.card(context, accent: accentBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasHeader) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: AppDecorations.badge(
                        iconColor ?? AppColors.primary,
                        dark: AppDecorations.isDark(context),
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: iconColor ?? AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class FbBadge extends StatelessWidget {
  const FbBadge({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.small = false,
  });

  final String label;
  final Color color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: AppDecorations.badge(
        color,
        dark: AppDecorations.isDark(context),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class FbSectionTitle extends StatelessWidget {
  const FbSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class FbSegmentedControl<T> extends StatelessWidget {
  const FbSegmentedControl({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    required this.labelBuilder,
  });

  final List<T> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final String Function(T) labelBuilder;

  @override
  Widget build(BuildContext context) {
    final dark = AppDecorations.isDark(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCardElevated : AppColors.lightInputBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: dark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: items.map((item) {
          final isSelected = item == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (dark ? AppColors.darkCard : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected && !dark
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labelBuilder(item),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : (dark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FbAlert extends StatelessWidget {
  const FbAlert({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.color = AppColors.primary,
  });

  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppDecorations.isDark(context)
                        ? AppColors.darkText
                        : AppColors.lightText,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class FbAppHeader extends StatelessWidget {
  const FbAppHeader({
    super.key,
    required this.pageTitle,
    required this.isDark,
    required this.onToggleTheme,
    this.badge,
  });

  final String pageTitle;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.mint],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'plime',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            pageTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 24,
                ),
          ),
        ),
        if (badge != null) ...[
          FbBadge(label: badge!, color: AppColors.mint, small: true),
          const SizedBox(width: 8),
        ],
        IconButton(
          onPressed: onToggleTheme,
          style: IconButton.styleFrom(
            backgroundColor: isDark
                ? AppColors.darkCardElevated
                : AppColors.lightInputBg,
          ),
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: 20,
          ),
        ),
      ],
    );
  }
}
