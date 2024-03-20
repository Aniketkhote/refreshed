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
