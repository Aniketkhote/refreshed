import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:refreshed/get_state_manager/get_state_manager.dart";

/// Mixin to provide a single ticker for GetxControllers.
/// Works like `SingleTickerProviderMixin` but optimized for GetX.
mixin GetSingleTickerProviderStateMixin on GetxController
    implements TickerProvider {
  Ticker? _ticker;

  @override
  Ticker createTicker(TickerCallback onTick) {
    if (_ticker != null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          "$runtimeType is a GetSingleTickerProviderStateMixin but multiple tickers were created.",
        ),
        ErrorDescription(
          "A GetSingleTickerProviderStateMixin can only be used as a TickerProvider once.",
        ),
        ErrorHint(
          "If you need multiple AnimationControllers, use GetTickerProviderStateMixin instead.",
        ),
      ]);
    }
    _ticker =
        Ticker(onTick, debugLabel: kDebugMode ? "created by $this" : null);
    return _ticker!;
  }

  /// Updates the ticker mode based on the widget tree.
  void didChangeDependencies(BuildContext context) {
    _ticker?.muted = !TickerMode.of(context);
  }

  @override
  void onClose() {
    if (_ticker?.isActive ?? false) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary("$this was disposed with an active Ticker."),
        ErrorDescription(
          "$runtimeType created a Ticker via GetSingleTickerProviderStateMixin, but it was still active at dispose().",
        ),
        ErrorHint(
          "Ensure that AnimationControllers using this TickerProvider are properly disposed.",
        ),
        _ticker!.describeForError("The offending ticker was"),
      ]);
    }
    _ticker?.dispose();
    _ticker = null;
    super.onClose();
  }
}

/// Mixin to provide multiple tickers for GetxControllers.
/// Works like `TickerProviderMixin` but optimized for GetX.
mixin GetTickerProviderStateMixin on GetxController implements TickerProvider {
  final Set<Ticker> _tickers = {};

  @override
  Ticker createTicker(TickerCallback onTick) {
    final _WidgetTicker ticker = _WidgetTicker(
      onTick,
      this,
      debugLabel: kDebugMode ? "created by ${describeIdentity(this)}" : null,
    );
    _tickers.add(ticker);
    return ticker;
  }

  void _removeTicker(_WidgetTicker ticker) {
    _tickers.remove(ticker);
  }

  /// Updates ticker states when dependencies change.
  void didChangeDependencies(BuildContext context) {
    final bool muted = !TickerMode.of(context);
    for (final Ticker ticker in _tickers) {
      ticker.muted = muted;
    }
  }

  @override
  void onClose() {
    for (final Ticker ticker in _tickers) {
      if (ticker.isActive) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary("$this was disposed with an active Ticker."),
          ErrorDescription(
            "$runtimeType created a Ticker via GetTickerProviderStateMixin, but it was still active at dispose().",
          ),
          ErrorHint(
            "Ensure that AnimationControllers using this TickerProvider are properly disposed.",
          ),
          ticker.describeForError("The offending ticker was"),
        ]);
      }
      ticker.dispose();
    }
    _tickers.clear();
    super.onClose();
  }
}

/// Custom Ticker for GetTickerProviderStateMixin.
class _WidgetTicker extends Ticker {
  _WidgetTicker(super.onTick, this._creator, {super.debugLabel});

  final GetTickerProviderStateMixin _creator;

  @override
  void dispose() {
    _creator._removeTicker(this);
    super.dispose();
  }
}
