/// The `rx_types` library provides a collection of reactive programming utilities
/// for managing state and building reactive components in Flutter applications.
///
/// This library includes classes and utilities for creating and managing reactive
/// objects such as Rx (reactive) variables, RxLists, RxMaps, and RxSets.
///
/// - [Rx]: The base class for reactive objects that enables listening to changes
///   and updating state reactively.
///
/// - [RxList]: A reactive list that allows listening to changes in the list
///   and automatically updating UI components when the list changes.
///
/// - [RxMap]: A reactive map that enables listening to changes in the map
///   and automatically updating UI components when the map changes.
///
/// - [RxSet]: A reactive set that provides the ability to listen to changes
///   in the set and update UI components reactively.
///
/// This library is part of the GetX state management solution for Flutter,
/// providing a simple and efficient way to manage application state and build
/// reactive user interfaces.
library;

import "dart:async";
import "dart:collection";

import "package:flutter/foundation.dart";
import "package:refreshed/get_state_manager/src/rx_flutter/rx_notifier.dart";

part "rx_core/rx_impl.dart";
part "rx_core/rx_interface.dart";
part "rx_core/rx_num.dart";
part "rx_core/rx_string.dart";
part "rx_iterables/rx_list.dart";
part "rx_iterables/rx_map.dart";
part "rx_iterables/rx_set.dart";
