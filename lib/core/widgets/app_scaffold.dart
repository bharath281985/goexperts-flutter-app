import 'package:flutter/material.dart';
import 'responsive_wrapper.dart';
import 'safe_bottom.dart';

/// App-wide scaffold that centers content on large screens and offers a
/// consistent surface for pages.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.drawer,
    this.constrainWidth = true,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.floatingActionButtonLocation,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final bool constrainWidth;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  @override
  Widget build(BuildContext context) {
    Widget content = constrainWidth ? ResponsiveWrapper(child: body) : body;

    // When there is no bottom nav, clear the system navigation bar inset.
    // Pages with [bottomNavigationBar] already wrap that bar in SafeArea.
    if (bottomNavigationBar == null) {
      content = SafeBottom(child: content);
    }

    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: content,
    );
  }
}
