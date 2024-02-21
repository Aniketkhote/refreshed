import 'src/sockets_stub.dart'
    if (dart.library.html) 'src/sockets_html.dart'
    if (dart.library.io) 'src/sockets_io.dart';

/// A class for managing WebSocket connections with additional features provided by GetX.
class GetSocket extends BaseWebSocket {
  /// Constructs a GetSocket instance with the given WebSocket [url].
  /// Optionally, you can specify [ping] duration for sending ping messages,
  /// and [allowSelfSigned] to allow self-signed certificates.
  GetSocket(super.url, {super.ping, super.allowSelfSigned});
}
