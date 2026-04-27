import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class PetRefreshIndicator extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final double displacement;

  const PetRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.displacement = 56,
  });

  @override
  State<PetRefreshIndicator> createState() => _PetRefreshIndicatorState();
}

class _PetRefreshIndicatorState extends State<PetRefreshIndicator> {
  static const double _triggerExtent = 90;

  double _pullExtent = 0;
  bool _isRefreshing = false;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) {
      return false;
    }

    if (notification.metrics.extentBefore > 0) {
      if (_pullExtent != 0) {
        setState(() => _pullExtent = 0);
      }
      return false;
    }

    double nextPullExtent = _pullExtent;

    if (notification is ScrollUpdateNotification) {
      final delta = notification.dragDetails?.delta.dy ?? 0;
      if (delta > 0) {
        nextPullExtent += delta;
      } else if (delta < 0) {
        nextPullExtent = math.max(0, nextPullExtent + delta);
      }
    } else if (notification is OverscrollNotification) {
      final delta = notification.dragDetails?.delta.dy ?? 0;
      if (delta > 0) {
        nextPullExtent += delta;
      }
    } else if (notification is ScrollEndNotification) {
      nextPullExtent = 0;
    }

    nextPullExtent = nextPullExtent.clamp(0, _triggerExtent);
    if (nextPullExtent != _pullExtent) {
      setState(() => _pullExtent = nextPullExtent);
    }

    return false;
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
      _pullExtent = _triggerExtent;
    });

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _pullExtent = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.primaryPurple;
    final progress = (_pullExtent / _triggerExtent).clamp(0.0, 1.0);
    final isVisible = _isRefreshing || progress > 0.02;
    final iconScale = _isRefreshing ? 1.0 : 0.78 + (progress * 0.32);

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: RefreshIndicator(
            color: Colors.transparent,
            backgroundColor: Colors.transparent,
            strokeWidth: 0.01,
            displacement: widget.displacement,
            onRefresh: _handleRefresh,
            child: widget.child,
          ),
        ),
        Positioned(
          top: AppTheme.spacingMedium,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 140),
              opacity: isVisible ? 1 : 0,
              child: Center(
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 140),
                  scale: iconScale,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackgroundOf(context),
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isRefreshing)
                          SizedBox(
                            width: 34,
                            height: 34,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        Icon(
                          Icons.pets_rounded,
                          color: color,
                          size: 22 + (progress * 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
