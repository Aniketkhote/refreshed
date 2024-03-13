import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

import "../../navigation/utils/wrapper.dart";

void main() {
  testWidgets("Get.defaultDialog smoke test", (WidgetTester tester) async {
    await tester.pumpWidget(Wrapper<dynamic>(child: Container()));
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(Container));

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    expect(mediaQuery, context.mediaQuery);
    final Size mediaQuerySize = mediaQuery.size;
    expect(mediaQuerySize, context.mediaQuerySize);
    final ThemeData theme = Theme.of(context);
    expect(theme, context.theme);
    final TextTheme textTheme = theme.textTheme;
    expect(textTheme, context.textTheme);
    final double devicePixelRatio = mediaQuery.devicePixelRatio;
    expect(devicePixelRatio, context.devicePixelRatio);
    final double height = mediaQuerySize.height;
    expect(height, context.height);
    final double heightTransformer =
        (mediaQuerySize.height - ((mediaQuerySize.height / 100) * 0)) / 1;
    expect(heightTransformer, context.heightTransformer());
    final Color? iconColor = theme.iconTheme.color;
    expect(iconColor, context.iconColor);
    final bool isDarkMode = (theme.brightness == Brightness.dark);
    expect(isDarkMode, context.isDarkMode);
    final Orientation orientation = mediaQuery.orientation;
    expect(orientation, context.orientation);
    final bool isLandscape = orientation == Orientation.landscape;
    expect(isLandscape, context.isLandscape);
    final double mediaQueryShortestSide = mediaQuerySize.shortestSide;
    expect(mediaQueryShortestSide, context.mediaQueryShortestSide);
    final double width = mediaQuerySize.width;
    expect(width, context.width);

    final bool isLargeTabletOrWider = width >= 720;
    expect(isLargeTabletOrWider, context.isLargeTabletOrWider);
    final bool isPhoneOrLess = width < 600;
    expect(isPhoneOrLess, context.isPhoneOrLess);
    final bool isPortrait = orientation == Orientation.portrait;
    expect(isPortrait, context.isPortrait);
    final bool isSmallTabletOrWider = width >= 600;
    expect(isSmallTabletOrWider, context.isSmallTabletOrWider);
    final bool isTablet = isSmallTabletOrWider || isLargeTabletOrWider;
    expect(isTablet, context.isSmallTabletOrWider);
    final EdgeInsets mediaQueryPadding = mediaQuery.padding;
    expect(mediaQueryPadding, context.mediaQueryPadding);
    final EdgeInsets mediaQueryViewInsets = mediaQuery.viewInsets;
    expect(mediaQueryViewInsets, context.mediaQueryViewInsets);
    final EdgeInsets mediaQueryViewPadding = mediaQuery.viewPadding;
    expect(mediaQueryViewPadding, context.mediaQueryViewPadding);
    final double widthTransformer =
        (mediaQuerySize.width - ((mediaQuerySize.width / 100) * 0)) / 1;
    expect(widthTransformer, context.widthTransformer());
    final double ratio = heightTransformer / widthTransformer;
    expect(ratio, context.ratio());

    final bool showNavbar = width > 800;
    expect(showNavbar, context.showNavbar);
    final TextScaler textScaleFactor = mediaQuery.textScaler;
    expect(textScaleFactor, context.textScaleFactor);
  });
}
