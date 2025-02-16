import 'package:flutter/material.dart';
import 'package:refreshed/route_manager.dart';
import 'package:refreshed/utils.dart';

import '../dialog/dialog_route.dart';

extension DialogExtension on GetInterface {
  /// Show a dialog.
  /// You can pass a [transitionDuration] and/or [transitionCurve],
  /// overriding the defaults when the dialog shows up and closes.
  /// When the dialog closes, uses those animations in reverse.
  Future<T?> dialog<T>(
    Widget widget, {
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    GlobalKey<NavigatorState>? navigatorKey,
    Object? arguments,
    Duration? transitionDuration,
    Curve? transitionCurve,
    String? name,
    RouteSettings? routeSettings,
    String? id,
  }) {
    assert(debugCheckHasMaterialLocalizations(context!));

    final theme = Theme.of(context!);
    return generalDialog<T>(
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        final pageChild = widget;
        Widget dialog = Builder(builder: (context) {
          return Theme(data: theme, child: pageChild);
        });
        if (useSafeArea) {
          dialog = SafeArea(child: dialog);
        }
        return dialog;
      },
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context!).modalBarrierDismissLabel,
      barrierColor: barrierColor ?? Colors.black54,
      transitionDuration: transitionDuration ?? defaultDialogTransitionDuration,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: transitionCurve ?? defaultDialogTransitionCurve,
          ),
          child: child,
        );
      },
      navigatorKey: navigatorKey,
      routeSettings:
          routeSettings ?? RouteSettings(arguments: arguments, name: name),
      id: id,
    );
  }

  /// Api from showGeneralDialog with no context
  Future<T?> generalDialog<T>(
      {required RoutePageBuilder pageBuilder,
      bool barrierDismissible = false,
      String? barrierLabel,
      Color barrierColor = const Color(0x80000000),
      Duration transitionDuration = const Duration(milliseconds: 200),
      RouteTransitionsBuilder? transitionBuilder,
      GlobalKey<NavigatorState>? navigatorKey,
      RouteSettings? routeSettings,
      String? id}) {
    assert(!barrierDismissible || barrierLabel != null);
    final key = navigatorKey ?? Get.nestedKey(id)?.navigatorKey;
    final nav = key?.currentState ??
        Navigator.of(overlayContext!,
            rootNavigator:
                true); //overlay context will always return the root navigator
    return nav.push<T>(
      GetDialogRoute<T>(
        pageBuilder: pageBuilder,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        barrierColor: barrierColor,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder,
        settings: routeSettings,
      ),
    );
  }

  /// Custom UI Dialog.
  Future<T?> defaultDialog<T>({
    String title = "Alert",
    EdgeInsetsGeometry? titlePadding,
    TextStyle? titleStyle,
    Widget? content,
    String? id,
    EdgeInsetsGeometry? contentPadding,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    VoidCallback? onCustom,
    Color? cancelTextColor,
    Color? confirmTextColor,
    String? textConfirm,
    String? textCancel,
    String? textCustom,
    Widget? confirm,
    Widget? cancel,
    Widget? custom,
    Color? backgroundColor,
    bool barrierDismissible = true,
    Color? buttonColor,
    String middleText = "\n",
    TextStyle? middleTextStyle,
    double radius = 20.0,
    List<Widget>? actions,
    PopInvokedWithResultCallback<T>? onWillPop,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    // Helper function to create buttons
    Widget buildButton({
      required String text,
      required VoidCallback? onPressed,
      Color? textColor,
      Color? backgroundColor,
      bool isOutlined = false,
    }) {
      return TextButton(
        style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          backgroundColor: isOutlined ? null : backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: isOutlined
                ? BorderSide(color: backgroundColor ?? Colors.grey, width: 2)
                : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: textColor)),
      );
    }

    // Initialize actions
    actions ??= [];
    if (cancel != null) {
      actions.add(cancel);
    } else if (onCancel != null || textCancel != null) {
      actions.add(buildButton(
        text: textCancel ?? "Cancel",
        onPressed: onCancel ?? closeAllDialogs,
        textColor: cancelTextColor ?? buttonColor ?? Colors.grey,
        isOutlined: true,
      ));
    }

    if (confirm != null) {
      actions.add(confirm);
    } else if (onConfirm != null || textConfirm != null) {
      actions.add(buildButton(
        text: textConfirm ?? "Ok",
        onPressed: onConfirm,
        textColor: confirmTextColor ?? Colors.white,
        backgroundColor: buttonColor ?? context!.theme.primaryColor,
      ));
    }

    // Build the dialog
    Widget baseAlertDialog = Builder(builder: (context) {
      return AlertDialog(
        titlePadding: custom != null
            ? EdgeInsets.zero
            : titlePadding ?? const EdgeInsets.all(8),
        contentPadding: contentPadding ?? const EdgeInsets.all(8),
        backgroundColor:
            backgroundColor ?? DialogTheme.of(context).backgroundColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        title: custom != null
            ? const SizedBox.shrink()
            : Text(title, textAlign: TextAlign.center, style: titleStyle),
        content: custom ??
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                content ??
                    Text(
                      middleText,
                      textAlign: TextAlign.center,
                      style: middleTextStyle,
                    ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: actions ?? [],
                ),
              ],
            ),
        buttonPadding: EdgeInsets.zero,
      );
    });

    // Return the dialog
    return dialog<T>(
      onWillPop != null
          ? PopScope<T>(
              onPopInvokedWithResult: (didPop, result) =>
                  onWillPop(didPop, result),
              child: baseAlertDialog,
            )
          : baseAlertDialog,
      barrierDismissible: barrierDismissible,
      navigatorKey: navigatorKey,
      id: id,
    );
  }

  /// Closes all dialogs and bottom sheets that are currently open.
  ///
  /// [id] is for when using nested navigation.
  void closeAllDialogsAndBottomSheets(String? id) {
    // Close both dialogs and bottom sheets concurrently
    while ((isDialogOpen! || isBottomSheetOpen!)) {
      closeOverlay(id: id);
    }
  }

  /// Close the currently open dialog, returning a [result], if provided
  void closeDialog<T>({String? id, T? result}) {
    // Stop if there is no dialog open
    if (isDialogOpen == null || !isDialogOpen!) return;

    closeOverlay(id: id, result: result);
  }

  /// Closes all dialogs that are currently open.
  ///
  /// [id] is for when using nested navigation.
  void closeAllDialogs({
    String? id,
  }) {
    while ((isDialogOpen!)) {
      closeOverlay(id: id);
    }
  }
}
