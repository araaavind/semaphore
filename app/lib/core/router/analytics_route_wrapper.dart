import 'package:flutter/material.dart';
import 'package:app/core/services/analytics_service.dart';

class AnalyticsRouteWrapper extends StatefulWidget {
  final Widget child;
  final String routeName;
  final String? routeClass;

  const AnalyticsRouteWrapper({
    super.key,
    required this.child,
    required this.routeName,
    this.routeClass,
  });

  @override
  State<AnalyticsRouteWrapper> createState() => _AnalyticsRouteWrapperState();
}

class _AnalyticsRouteWrapperState extends State<AnalyticsRouteWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.logScreenView(
        widget.routeName,
        widget.routeClass ?? widget.routeName,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
