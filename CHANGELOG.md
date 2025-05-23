## 3.0.3

- I'm back! I'm continuing to maintain and improve Refreshed. I'll do my best to keep up with issues and pull requests. Thanks for your support!

## 3.0.2

- Fixed defaultPopGesture

## 3.0.1

- Minor fixes for BottomSheet, Dialog, and Navigation.

## 3.0.0

### Performance Improvements

- **Improved Middleware Implementation**:

  - Optimized for better performance and maintainability.
  - Enhanced handling of route parameters for smoother navigation.

- **Optimized Route Parsing**:
  - Streamlined route matching to improve efficiency in path resolution.
  - Enhanced route tree management for better handling of route additions and deletions.
  - Optimized handling of parameters and child routes for cleaner, more efficient code.
- **GetSingleTickerProviderStateMixin & GetTickerProviderStateMixin Refactor**:
  - Refactored for better performance and memory management.
  - Improved assertion handling with clearer error messages and prevention of unintended ticker leaks.
  - Enhanced `didChangeDependencies` to mute tickers properly based on `TickerMode` changes.
  - Optimized `_WidgetTicker` lifecycle management to prevent redundant operations.

### UI/UX Enhancements

- **Material 3 Snackbar UI**:
  - Updated Snackbar background to match Material 3 UI design for better consistency.

### Breaking Changes

- **Flutter 3.27+ and Dart 3.6+ Support Only**:
  - This release only supports Flutter versions greater than or equal to 3.27 and Dart versions greater than or equal to 3.6, due to breaking changes introduced in Flutter 3.27.

### Bug Fixes

- **Route Management Fixes**:
  - Fixed the issue where unknown routes would not properly navigate to the 404 route. Now, invalid routes are handled correctly.

### Removed Features

- **Deprecated Methods Removed**:
  - Methods that were not relevant to the core functionality have been removed from the package:
    - From `RxDouble` and `RxnDouble`: `abs()`, `sign()`, `round()`, `floor()`, `ceil()`, `truncate()`, etc.
    - From `IntExt` and `IntnExt`: Shift operations, mathematical operations (`modPow`, `gcd`, etc.), bitwise operations (`bitLength`, `toUnsigned()`, `toSigned()`), negation (`operator -()`), and parity checks (`isEven`, `isOdd`).
    - From `RxString` and `RxnString`: `pad()`, `startsWith()`, `endsWith()`, `contains()`, `toLowerCase()`, `toUpperCase()`, `substring()`, etc.

### API Documentation

- Added detailed doc comments to improved developer experience and clearer API documentation.

---

> **Note**: This release is part of ongoing improvements for performance, memory management, and route handling, with a major update requiring Flutter 3.27 and Dart 3.6 for compatibility.

## 3.0.0-beta.4

- Removed methods from `RxDouble` and `RxnDouble` as they were not relevant to the package functionality:

  - `abs()`, `sign()`, `round()`, `floor()`, `ceil()`, `truncate()`, etc.

- Removed methods from `IntExt` and `IntnExt` that were unnecessary for the intended functionality:

  - Shift operations, mathematical operations (e.g., `modPow`, `gcd`, etc.), bitwise operations (`bitLength`, `toUnsigned()`, `toSigned()`), negation (`operator -()`), and parity checks (`isEven`, `isOdd`).

- Removed methods from `RxString` and `RxnString` as they were not relevant to the package functionality:

  - `pad()`, `startsWith()`, `endsWith()`, `contains()`, `toLowerCase()`, `toUpperCase()`, `substring()`, etc.

## 3.0.0-beta.3

- Refactored `GetSingleTickerProviderStateMixin` and `GetTickerProviderStateMixin` for better performance and memory management.
- Improved assertion handling to provide clearer error messages and prevent unintended ticker leaks.
- Enhanced `didChangeDependencies` to ensure proper ticker muting based on `TickerMode` changes.
- Optimized `_WidgetTicker` lifecycle management to prevent redundant operations and improve efficiency.
- Added detailed doc comments to `GetX` for better API documentation and improved developer experience.

## 3.0.0-beta.2

- Optimized Middleware implementation for improved performance and maintainability.
- Streamlined route matching to enhance efficiency in path resolution.
- Improved route tree management for better handling of route additions and deletions.
- Enhanced handling of parameters and child routes for cleaner, more efficient code.

## 3.0.0-beta.1

- Removed `mini_stream` dependency as it was not widely used or relevant to the package functionality.
- Updated Snackbar background to match the Material 3 UI for better design consistency.
- Fixed the `unknownRoute` issue: if the route is invalid, it now properly navigates to the 404 route.

## 2.10.4

- Resolved an issue where the `SnackBar` widget's background color was not being applied correctly.

## 2.10.3

- Fixed custom widget not working in `defaultDialog`
- Set the default button background color to `context.theme.primaryColor`

## 2.10.2

- Improved RxIterable methods
- `addIf()` and `addAllIf()` methods now conditionally add elements based on simple bool checks
- Methods like add(), remove(), and clear() now consistently call refresh() to notify listeners of changes

## 2.10.1

- Improved log and exception messages for easier troubleshooting and better understanding of issues.
- Set the default background color of the bottom sheet to `bottomSheetTheme.backgroundColor`.
- Renamed `persistent` to `isPersistent` for clearer and more intuitive naming.

## 2.10.0

- Removed `Get.backLegacy()` method
- Updated package compatibility to support Flutter version `3.27.0`

## 2.9.0

- Up to date with Getx package.

## 2.8.1

- Fixed futurize empty state handling by correctly triggering `onEmpty` when the result is neither `null` nor has data.

## 2.8.0

- Reintroduced Rxn<Model>

## 2.7.2

- Fixed padding issue in dialog.

## 2.7.1

- Fixed issue where the dialog displayed the default title instead of custom title.

## 2.7.0

- Upgraded flutter to version `3.22.0`
- Resolved asynchronous issues in replace and lazyReplace Dependency Injection (DI) methods.
- Improved overall performance.

## 2.6.3

- Fixed `CupertinoRouteTransitionMixin.isPopGestureInProgress` member not found issue.

## 2.6.2

- Made explicit Bind type declaration optional to maintain compatibility with older projects.

## 2.6.1

- Resolved linting issues.
- Added Binding Example Demo

## 2.6.0

- Added explicit type declaration to `Bind.lazyPut()` method, replacing `Bind.lazyPut(() => CountController())` with `Bind.lazyPut<CountController>(() => CountController())`.

## 2.5.8

- Removed unused params from `GetCupertinoApp` .

## 2.5.7

- Resolved linting issues.
- Resolved the issue related to generic types.

## 2.5.6

- Updated route parsing for better compatibility with HTTP app links.

## 2.5.5

- Resolved linting issues.

## 2.5.4

- Resolved nullable instance dependency issues where Null type was not compatible with Instance.

## 2.5.3

- Resolved the issue related to generic types.

## 2.5.2

- Altered logger's initial print message from `GetX` to `Refreshed`.
- Resolved linting issues.

## 2.5.1

- Resolved scrolling issue by setting the default value of the persistent parameter to false during bottom sheet dragdown.
- Enhanced clarity by renaming persistent to isPersistent to denote a boolean value for the parameter.

## 2.5.0

- Reintroduced `putAsync` function

## 2.4.1

- Fixed pub points

## 2.4.0

- Implemented test cases for Rx extension methods.
- Eliminated `responsiveValue` from context extension.
- Removed Responsiveness-related classes.
- Fixed missing imports
- Fixed datatypes in rx values.

## 2.3.1

- Removed `round()`, `floor()`, `ceil()`, and `truncate()` extension methods from the int extension as they are not applicable to integers.

## 2.3.0

- Rolled back web version to 0.4.0 to resolve package conflicts, ensuring compatibility and stability.
- Resolved Snackbar margin issue, ensuring consistent and visually appealing UI presentation.

## 2.2.0

- Implemented drag handle customization, including visibility, color, and size, along with drag start/end callbacks and shadow color support in the bottom sheet.

## 2.1.0

- Refactored codebase by eliminating String extensions and methods, Instead, use`Quickly` package for similar functionalities.
- Resolved asynchronous issue in Queue by introducing proper await usage.

## 2.0.3

- Fixed the asynchronous issue in `goToUnknownPage` function within the route, resolving the need for `await`.
- Removed unnecessary `await` statements in the route delegate for improved efficiency.
- Enhanced safety in the route delegate by adding required return types.

## 2.0.2

- Resolved await issue in the closeAllSnackbars and closeAllOverlays methods.

## 2.0.1

- Fixed dart formatting issues.

## 2.0.0

- Removed the `int`, `double`, `num` and `duration` extensions, as they are no longer necessary. Instead, use`Quickly` package for similar functionalities.
- Resolved the memory leak issue associated with the snackbar component.
- Addressed and fixed the failing tests related to the snackbar component.
- Added `BoxConstraints` to the `Get.bottomSheet` method to ensure more precise control and layout constraints.
- Enhance Dart code to align with linting conventions.
- Implemented data types to enhance code safety.
- Added API documentation.

## 1.5.4

- Resolved issue with Snackbar not using full width, causing buttons on that height to be unclickable.

## 1.5.3

- Removed redundant code.
- Added API documentation.

## 1.5.2

- Fixed an issue with the default dialog where custom widgets were not being overridden properly.

## 1.5.1

- Fixed pub points

## 1.5.0

**Major Update**

- Removed the animation module as it is no longer relevant to the project's scope and requirements.
- Removed the WidgetPaddingX, WidgetMarginX, and WidgetSliverBoxX extensions from the codebase as they were irrelevant.
- Introduced the quickly package to facilitate the use of similar extensions for padding, margin, and lot more.

## 1.4.0

**Major Update**

- Extracted the get_connect module from the package and published it as vaultify.
- Removed infrequently used string extension methods

## 1.3.0

- Removed unused methods and extensions to enhance code cleanliness.

## 1.2.0

- Removed duplicate methods and extensions to improve code cleanliness and reduce redundancy.
- Implemented stop behavior in the delay extension, allowing users to cancel the delay before it completes.

## 1.1.3

- Fixed an issue in RxList where a type error occurred when initializing with an empty list.

## 1.1.2

- Updated the readme file and addressed various minor issues.

## 1.1.1

- Fixed issues related to pub points and package metadata.

## 1.1.0

- Added documentation comments for improved code documentation.
- Corrected typos in code and documentation.

## 1.0.3

- Addressed minor issues and optimizations.

## 1.0.2

- Resolved data type inconsistencies for better compatibility.

## 1.0.1

- Fixed issues related to pub points and package metadata.

## 1.0.0

## Initial Release Changelog

### Features:

- **Enhanced Stability:** Improved overall stability with bug fixes and optimizations.
- **Performance Boost:** Optimized performance for smoother app experiences.
- **Beginner-Friendly:** Designed with newcomers in mind, making it easier to get started with GetX.
- **Latest Compatibility:** Fully compatible with the latest Flutter and Dart packages.
- **Simplified Routing:** Streamlined routing mechanism for easier navigation between screens.
- **Updated Documentation:** Comprehensive documentation with clear instructions and examples.
- **Community-Driven:** Built based on feedback from the Flutter community to meet their evolving needs.

We're excited to introduce this initial release of the refreshed GetX package, offering a robust and user-friendly experience for Flutter developers of all levels. Enjoy coding with GetX and stay tuned for future updates!
