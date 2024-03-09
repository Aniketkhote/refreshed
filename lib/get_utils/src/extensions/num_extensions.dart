import 'package:refreshed/utils.dart';

/// Extension providing utility functions for numerical values.
extension GetNumUtils on num {
  /// Checks if this number is lower than the given [b].
  bool isLowerThan(num b) => GetUtils.isLowerThan(this, b);

  /// Checks if this number is greater than the given [b].
  bool isGreaterThan(num b) => GetUtils.isGreaterThan(this, b);

  /// Checks if this number is equal to the given [b].
  bool isEqual(num b) => GetUtils.isEqual(this, b);
}
