import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final List<BoxShadow>? boxShadow;
  final double? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.gradient,
    this.boxShadow,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: AppTheme.spacingXSmall, vertical: AppTheme.spacingXSmall),
      width: double.infinity,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? AppTheme.cardBackgroundOf(context)) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusLarge),
        boxShadow: boxShadow ?? AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusLarge),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacingMedium),
            child: child,
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppTheme.primaryPurple;
    final bgColor = backgroundColor ?? color.withValues(alpha: 0.1);

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(icon, color: color, size: AppTheme.iconSizeLarge),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            value,
            style: AppTheme.statValue.copyWith(
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: AppTheme.spacingXSmall),
          Text(
            title,
            style: AppTheme.statLabel.copyWith(
              color: AppTheme.textSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? tag;
  final Color? tagColor;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final Widget? trailing;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.tag,
    this.tagColor,
    this.isCompleted = false,
    this.onTap,
    this.onComplete,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          if (onComplete != null)
            GestureDetector(
              onTap: onComplete,
              child: Container(
                width: AppTheme.iconSizeLarge,
                height: AppTheme.iconSizeLarge,
                margin: const EdgeInsets.only(right: AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: isCompleted ? AppTheme.successGreen : Colors.transparent,
                  border: Border.all(
                    color: isCompleted ? AppTheme.successGreen : AppTheme.textLightOf(context),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: isCompleted
                    ? Icon(Icons.check, size: AppTheme.iconSizeSmall, color: Colors.white)
                    : null,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tag != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingXSmall),
                    decoration: BoxDecoration(
                      color: (tagColor ?? AppTheme.primaryPurple).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Text(
                      tag!,
                      style: AppTheme.tagText.copyWith(
                        color: tagColor ?? AppTheme.primaryPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                ],
                Text(
                  title,
                  style: AppTheme.cardTitle.copyWith(
                    color: AppTheme.textPrimaryOf(context),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXSmall),
                Text(
                  subtitle,
                  style: AppTheme.cardSubtitle.copyWith(
                    color: AppTheme.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Color? progressColor;
  final VoidCallback? onTap;

  const ProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.progressColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = progressColor ?? AppTheme.primaryPurple;

    return CustomCard(
      onTap: onTap,
      gradient: AppTheme.cardGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.cardTitle.copyWith(
                        color: AppTheme.textPrimaryOf(context),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXSmall),
                    Text(
                      subtitle,
                      style: AppTheme.cardSubtitle.copyWith(
                        color: AppTheme.textSecondaryOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.cardBackgroundOf(context),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      strokeWidth: 5,
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: AppTheme.bodyTextLight.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}