import 'package:flutter/material.dart';
import 'package:refreshed/route_manager.dart';
import 'package:refreshed/utils.dart';

extension BottomSheetExtension on GetInterface {
  Future<T?> bottomSheet<T>(
    Widget bottomsheet, {
    Color? backgroundColor,
    double? elevation,
    bool isPersistent = false,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
    bool? ignoreSafeArea,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    RouteSettings? settings,
    Duration? enterBottomSheetDuration,
    Duration? exitBottomSheetDuration,
    Curve? curve,
  }) {
    return Navigator.of(overlayContext!, rootNavigator: useRootNavigator)
        .push(GetModalBottomSheetRoute<T>(
      builder: (_) => bottomsheet,
      isPersistent: isPersistent,
      theme: Theme.of(key.currentContext!),
      isScrollControlled: isScrollControlled,
      barrierLabel: MaterialLocalizations.of(key.currentContext!)
          .modalBarrierDismissLabel,
      backgroundColor:
          backgroundColor ?? context!.theme.bottomSheetTheme.backgroundColor,
      elevation: elevation,
      shape: shape,
      removeTop: ignoreSafeArea ?? true,
      clipBehavior: clipBehavior,
      isDismissible: isDismissible,
      modalBarrierColor: barrierColor,
      settings: settings,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      enterBottomSheetDuration:
          enterBottomSheetDuration ?? const Duration(milliseconds: 250),
      exitBottomSheetDuration:
          exitBottomSheetDuration ?? const Duration(milliseconds: 200),
      curve: curve,
    ));
  }

  /// check if dialog is open
  bool? get isDialogOpen => routing.isDialog;

  /// check if bottomsheet is open
  bool? get isBottomSheetOpen => routing.isBottomSheet;

  /// Closes all bottom sheets that are currently open.
  ///
  /// [id] is for when using nested navigation.
  void closeAllBottomSheets({
    String? id,
  }) {
    while ((isBottomSheetOpen!)) {
      searchDelegate(id).navigatorKey.currentState?.pop();
    }
  }
}
