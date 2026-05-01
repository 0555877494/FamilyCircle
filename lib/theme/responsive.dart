import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  static const double mobile = 400;
  static const double tablet = 700;
  static const double desktop = 1000;
  static const double largeDesktop = 1200;
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, WidgetSize) mobile;
  final Widget Function(BuildContext, WidgetSize)? tablet;
  final Widget Function(BuildContext, WidgetSize)? desktop;
  final Widget Function(BuildContext, WidgetSize)? largeDesktop;
  final Widget? child;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final size = WidgetSize(width: width, height: height);
        final isTablet = width >= ResponsiveBreakpoints.tablet;
        final isDesktop = width >= ResponsiveBreakpoints.desktop;
        final isLarge = width >= ResponsiveBreakpoints.largeDesktop;

        if (isLarge && largeDesktop != null) {
          return largeDesktop!(context, size);
        }
        if (isDesktop && desktop != null) {
          return desktop!(context, size);
        }
        if (isTablet && tablet != null) {
          return tablet!(context, size);
        }
        return mobile(context, size);
      },
    );
  }
}

class WidgetSize {
  final double width;
  final double height;

  const WidgetSize({required this.width, required this.height});

  bool get isMobile => width < ResponsiveBreakpoints.tablet;
  bool get isTablet => width >= ResponsiveBreakpoints.tablet && width < ResponsiveBreakpoints.desktop;
  bool get isDesktop => width >= ResponsiveBreakpoints.desktop && width < ResponsiveBreakpoints.largeDesktop;
  bool get isLargeDesktop => width >= ResponsiveBreakpoints.largeDesktop;
  bool get isLandscape => width > height;
  bool get isPortrait => height > width;
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double mobileColumns;
  final double tabletColumns;
  final double desktopColumns;
  final double spacing;
  final double padding;
  final EdgeInsets? customPadding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.padding = 16,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context, size) {
        return _buildGrid(size.isMobile ? mobileColumns : tabletColumns);
      },
      tablet: (context, size) {
        return _buildGrid(size.isTablet ? tabletColumns : desktopColumns);
      },
      desktop: (context, size) {
        return _buildGrid(desktopColumns);
      },
    );
  }

  Widget _buildGrid(double columns) {
    return Padding(
      padding: customPadding ?? EdgeInsets.all(padding),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: children.map((child) {
          final itemWidth = (columns > 0 ? (columns > 1 ? (columns > 2 ? columns : 3) : 2) : 1);
          return SizedBox(
            width: (100 / itemWidth - (spacing * (itemWidth - 1) / itemWidth)) * 0.01 * 300,
            child: child,
          );
        }).toList(),
      ),
    );
  }
}

class AutoScrollContainer extends StatelessWidget {
  final Widget child;
  final Axis direction;
  final bool alwaysScroll;

  const AutoScrollContainer({
    super.key,
    required this.child,
    this.direction = Axis.vertical,
    this.alwaysScroll = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!alwaysScroll) return child;

    // Check if child already has constraints - if Expanded is used, use what we have
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: direction,
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double mobile;
  final double tablet;
  final double desktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile = 16,
    this.tablet = 24,
    this.desktop = 32,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context, size) {
        return Padding(
          padding: EdgeInsets.all(
            size.isMobile ? mobile : (size.isTablet ? tablet : desktop),
          ),
          child: child,
        );
      },
    );
  }
}

class ResponsiveFontSize extends StatelessWidget {
  final String text;
  final double mobile;
  final double tablet;
  final double desktop;
  final TextStyle? style;
  final TextAlign? textAlign;

  const ResponsiveFontSize({
    super.key,
    required this.text,
    required this.mobile,
    this.tablet = 16,
    this.desktop = 18,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context, size) {
        final fontSize = size.isMobile ? mobile : (size.isTablet ? tablet : desktop);
        return Text(
          text,
          style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
          textAlign: textAlign,
        );
      },
    );
  }
}

class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool useDrawer;
  final bool useBottomNav;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.useDrawer = false,
    this.useBottomNav = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context, size) {
        if (size.isMobile || size.isTablet) {
          return Scaffold(
            appBar: appBar,
            drawer: useDrawer ? drawer : null,
            body: body,
            bottomNavigationBar: useBottomNav ? bottomNavigationBar : null,
            floatingActionButton: floatingActionButton,
          );
        }
        return Scaffold(
          appBar: appBar,
          body: Row(
            children: [
              if (drawer != null)
                SizedBox(
                  width: 250,
                  child: drawer,
                ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          ),
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}

class OrientationBuilder extends StatelessWidget {
  final Widget Function(BuildContext, Orientation)? portrait;
  final Widget Function(BuildContext, Orientation)? landscape;

  const OrientationBuilder({
    super.key,
    this.portrait,
    this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.portrait) {
      return portrait?.call(context, orientation) ?? const SizedBox();
    }
    return landscape?.call(context, orientation) ?? const SizedBox();
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context, size) {
        return Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

class ScreenResponsiveness extends InheritedWidget {
  final WidgetSize size;

  const ScreenResponsiveness({
    super.key,
    required this.size,
    required super.child,
  });

  static WidgetSize of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ScreenResponsiveness>();
    return provider?.size ?? const WidgetSize(width: 400, height: 800);
  }

  @override
  bool updateShouldNotify(ScreenResponsiveness oldWidget) {
    return size.width != oldWidget.size.width ||
        size.height != oldWidget.size.height;
  }
}

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ScreenResponsiveness(
          size: WidgetSize(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
          ),
          child: child,
        );
      },
    );
  }
}