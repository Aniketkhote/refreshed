/// An enumeration representing different styles for rows.
enum RowStyle {
  /// Row with icon style.
  icon,

  /// Row with action style.
  action,

  /// Row with all available styles.
  all,

  /// Row with no specific style.
  none
}

/// Indicates the status of a snackbar.
enum SnackbarStatus {
  /// Snackbar is fully open.
  open,

  /// Snackbar has closed.
  closed,

  /// Snackbar is in the process of opening.
  opening,

  /// Snackbar is in the process of closing.
  closing
}

/// Indicates the position where a snack is displayed.
enum SnackPosition {
  /// Snack is displayed at the top of the screen.
  top,

  /// Snack is displayed at the bottom of the screen.
  bottom
}

/// Indicates the style of a snack.
enum SnackStyle {
  /// Snack is displayed as floating.
  floating,

  /// Snack is displayed as grounded.
  grounded
}

/// Indicates the state when the mouse enters or exits.
enum SnackHoverState {
  /// Mouse entered the area.
  entered,

  /// Mouse exited the area.
  exited
}
