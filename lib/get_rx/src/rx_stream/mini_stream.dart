// ignore_for_file: avoid_dynamic_calls

part of "rx_stream.dart";

/// Represents a node in a linked list.
class Node<T> {
  /// Constructs a Node with optional [data] and [next] node.
  Node({this.data, this.next});

  /// The data stored in the node.
  T? data;

  /// Reference to the next node.
  Node<T>? next;
}

/// Represents a mini subscription for a stream.
class MiniSubscription<T> {
  /// Constructs a MiniSubscription with required [data] handler, optional
  /// [onError] handler, optional [onDone] callback, [cancelOnError] flag, and
  /// [listener] to attach.
  const MiniSubscription(
    this.data,
    this.onError,
    this.onDone,
    this.cancelOnError,
    this.listener,
  );

  /// Callback function to handle incoming data events.
  final OnData<T> data;

  /// Error handler function.
  final Function? onError;

  /// Callback function to be executed when the stream is done.
  final Callback? onDone;

  /// Flag indicating whether to cancel the subscription on error.
  final bool cancelOnError;

  /// Cancels the subscription.
  Future<void> cancel() async => listener.removeListener(this);

  /// The listener to which this subscription is attached.
  final FastList<T> listener;
}

/// A mini stream implementation.
class MiniStream<T> {
  /// The list of listeners.
  FastList<T> listenable = FastList<T>();

  late T _value;

  /// Getter for the current value of the stream.
  T get value => _value;

  /// Setter for the current value of the stream.
  set value(T val) {
    add(val);
  }

  /// Adds an event to the stream.
  void add(T event) {
    _value = event;
    listenable._notifyData(event);
  }

  /// Adds an error to the stream.
  void addError(Object error, [StackTrace? stackTrace]) {
    listenable._notifyError(error, stackTrace);
  }

  /// Retrieves the length of the stream.
  int get length => listenable.length;

  /// Checks if there are any active listeners for the stream.
  bool get hasListeners => listenable.isNotEmpty;

  /// check stream is close or not
  bool get isClosed => _isClosed;

  /// Listens for events on the stream.
  MiniSubscription<T> listen(
    void Function(T event) onData, {
    Function? onError,
    void Function()? onDone,
    bool cancelOnError = false,
  }) {
    final MiniSubscription<T> subs = MiniSubscription<T>(
      onData,
      onError,
      onDone,
      cancelOnError,
      listenable,
    );
    listenable.addListener(subs);
    return subs;
  }

  bool _isClosed = false;

  /// Closes the stream.
  void close() {
    if (_isClosed) {
      throw Exception("You cannot close a closed Stream");
    }
    listenable._notifyDone();
    listenable.clear();
    _isClosed = true;
  }
}

/// A linked list implementation optimized for fast notifications.
class FastList<T> {
  Node<MiniSubscription<T>>? _head;

  /// Notifies all listeners with the provided [data].
  void _notifyData(T data) {
    Node<MiniSubscription<T>>? currentNode = _head;
    do {
      currentNode?.data?.data(data);
      currentNode = currentNode?.next;
    } while (currentNode != null);
  }

  /// Notifies all listeners that the stream is done.
  void _notifyDone() {
    Node<MiniSubscription<T>>? currentNode = _head;
    do {
      currentNode?.data?.onDone?.call();
      currentNode = currentNode?.next;
    } while (currentNode != null);
  }

  /// Notifies all listeners with the provided [error].
  void _notifyError(Object error, [StackTrace? stackTrace]) {
    Node<MiniSubscription<T>>? currentNode = _head;
    while (currentNode != null) {
      currentNode.data!.onError?.call(error, stackTrace);
      currentNode = currentNode.next;
    }
  }

  /// Checks if this list is empty.
  bool get isEmpty => _head == null;

  /// Checks if this list is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Returns the length of this list.
  int get length {
    int length = 0;
    Node<MiniSubscription<T>>? currentNode = _head;

    while (currentNode != null) {
      currentNode = currentNode.next;
      length++;
    }
    return length;
  }

  /// Inserts a [MiniSubscription] at the end of the list.
  void addListener(MiniSubscription<T> data) {
    final Node<MiniSubscription<T>> newNode =
        Node<MiniSubscription<T>>(data: data);

    if (isEmpty) {
      _head = newNode;
    } else {
      Node<MiniSubscription<T>> currentNode = _head!;
      while (currentNode.next != null) {
        currentNode = currentNode.next!;
      }
      currentNode.next = newNode;
    }
  }

  /// Checks if this list contains the specified [element].
  bool contains(T element) {
    final int length = this.length;
    for (int i = 0; i < length; i++) {
      if (_elementAt(i) == element) {
        return true;
      }
      if (length != this.length) {
        throw ConcurrentModificationError(this);
      }
    }
    return false;
  }

  /// Removes the specified [element] from the list.
  void removeListener(MiniSubscription<T> element) {
    final int length = this.length;
    for (int i = 0; i < length; i++) {
      if (_elementAt(i) == element) {
        _removeAt(i);
        break;
      }
    }
  }

  /// Clears the list of all elements.
  void clear() {
    final int length = this.length;
    for (int i = 0; i < length; i++) {
      _removeAt(i);
    }
  }

  /// Removes the element at the specified [position] from the list.
  MiniSubscription<T>? _removeAt(int position) {
    int index = 0;
    Node<MiniSubscription<T>>? currentNode = _head;
    Node<MiniSubscription<T>>? previousNode;

    if (isEmpty || length < position || position < 0) {
      throw Exception("Invalid position");
    } else if (position == 0) {
      _head = _head!.next;
    } else {
      while (index != position) {
        previousNode = currentNode;
        currentNode = currentNode!.next;
        index++;
      }

      if (previousNode == null) {
        _head = null;
      } else {
        previousNode.next = currentNode!.next;
      }

      currentNode!.next = null;
    }

    return currentNode!.data;
  }

  /// Returns the [MiniSubscription] at the specified [position].
  MiniSubscription<T>? _elementAt(int position) {
    if (isEmpty || length < position || position < 0) {
      return null;
    }

    Node<MiniSubscription<T>>? node = _head;
    int current = 0;

    while (current != position) {
      node = node!.next;
      current++;
    }
    return node!.data;
  }
}
