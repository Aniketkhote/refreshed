import 'package:flutter/widgets.dart';

/// Adds padding properties to a widget.
extension WidgetPaddingX on Widget {
  /// Adds padding to all sides of the widget.
  ///
  /// Example:
  /// ```dart
  /// final paddedWidget = myWidget.paddingAll(16.0);
  /// ```
  Widget paddingAll(double padding) =>
      Padding(padding: EdgeInsets.all(padding), child: this);

  /// Adds symmetric padding to the widget.
  ///
  /// Example:
  /// ```dart
  /// final paddedWidget = myWidget.paddingSymmetric(horizontal: 16.0, vertical: 8.0);
  /// ```
  Widget paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) =>
      Padding(
          padding:
              EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
          child: this);

  /// Adds padding to specific sides of the widget.
  ///
  /// Example:
  /// ```dart
  /// final paddedWidget = myWidget.paddingOnly(left: 8.0, right: 8.0);
  /// ```
  Widget paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) =>
      Padding(
          padding: EdgeInsets.only(
              top: top, left: left, right: right, bottom: bottom),
          child: this);

  /// Adds zero padding to the widget.
  ///
  /// Example:
  /// ```dart
  /// final zeroPaddedWidget = myWidget.paddingZero;
  /// ```
  Widget get paddingZero => Padding(padding: EdgeInsets.zero, child: this);
}

/// Adds margin properties to a widget.
extension WidgetMarginX on Widget {
  /// Adds margin to all sides of the widget.
  ///
  /// Example:
  /// ```dart
  /// final marginWidget = myWidget.marginAll(16.0);
  /// ```
  Widget marginAll(double margin) =>
      Container(margin: EdgeInsets.all(margin), child: this);

  /// Adds symmetric margin to the widget.
  ///
  /// Example:
  /// ```dart
  /// final marginWidget = myWidget.marginSymmetric(horizontal: 16.0, vertical: 8.0);
  /// ```
  Widget marginSymmetric({double horizontal = 0.0, double vertical = 0.0}) =>
      Container(
          margin:
              EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
          child: this);

  /// Adds margin to specific sides of the widget.
  ///
  /// Example:
  /// ```dart
  /// final marginWidget = myWidget.marginOnly(left: 8.0, right: 8.0);
  /// ```
  Widget marginOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) =>
      Container(
          margin: EdgeInsets.only(
              top: top, left: left, right: right, bottom: bottom),
          child: this);

  /// Adds zero margin to the widget.
  ///
  /// Example:
  /// ```dart
  /// final zeroMarginWidget = myWidget.marginZero;
  /// ```
  Widget get marginZero => Container(margin: EdgeInsets.zero, child: this);
}

/// Allows you to insert widgets inside a CustomScrollView.
extension WidgetSliverBoxX on Widget {
  /// Converts the widget into a sliver that can be inserted into a CustomScrollView.
  ///
  /// Example:
  /// ```dart
  /// final sliverWidget = myWidget.sliverBox;
  /// ```
  Widget get sliverBox => SliverToBoxAdapter(child: this);
}
