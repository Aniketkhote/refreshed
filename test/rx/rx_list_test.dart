import "package:flutter_test/flutter_test.dart";
import "package:refreshed/refreshed.dart";

void main() {
  group("RxList Tests", () {
    test("RxList initializes with empty list", () {
      final RxList<int> rxList = RxList<int>();
      expect(rxList, isEmpty);
    });

    test("RxList adds default items", () {
      final RxList<int> rxList = RxList<int>(<int>[1, 2]);
      rxList.add(3);
      expect(rxList, <int>[1, 2, 3]);
    });

    test("RxList adds items", () {
      final RxList<int> rxList = RxList<int>();
      rxList.add(1);
      rxList.addAll(<int>[2, 3]);
      expect(rxList, <int>[1, 2, 3]);
    });

    test("RxList updates items", () {
      final RxList<int> rxList = RxList<int>();
      rxList.addAll(<int>[1, 2, 3]);
      rxList[0] = 4;
      expect(rxList, <int>[4, 2, 3]);
    });

    test("RxList removes items", () {
      final RxList<int> rxList = RxList<int>();
      rxList.addAll(<int>[1, 2, 3]);
      rxList.removeAt(1);
      expect(rxList, <int>[1, 3]);
    });

    test("RxList clears all items", () {
      final RxList<int> rxList = RxList<int>();
      rxList.addAll(<int>[1, 2, 3]);
      rxList.clear();
      expect(rxList, isEmpty);
    });
  });

  group("RxList with model Tests", () {
    test("RxList initializes with empty list", () {
      final RxList<Todo> rxList = RxList<Todo>();
      expect(rxList, isEmpty);
    });

    test("RxList adds custom model items", () {
      final RxList<Todo> rxList = RxList<Todo>();
      final Todo todo1 = Todo(id: 1, title: "Task 1", completed: false);
      final Todo todo2 = Todo(id: 2, title: "Task 2", completed: true);

      // Adding individual and multiple items
      rxList.add(todo1);
      rxList.addAll([todo2]);

      expect(rxList.length, 2);
      expect(rxList, contains(todo1));
      expect(rxList, contains(todo2));
    });

    test("RxList updates items", () {
      final RxList<Todo> rxList = RxList<Todo>();
      final Todo todo = Todo(id: 1, title: "Task 1", completed: false);

      rxList.add(todo);
      expect(rxList[0].completed, false);

      rxList[0] = Todo(id: 1, title: "Task 1", completed: true);
      expect(rxList[0].completed, true);
    });

    test("RxList removes items", () {
      final RxList<Todo> rxList = RxList<Todo>();
      final Todo todo1 = Todo(id: 1, title: "Task 1", completed: false);
      final Todo todo2 = Todo(id: 2, title: "Task 2", completed: true);

      rxList.addAll(<Todo>[todo1, todo2]);
      expect(rxList.length, 2);

      rxList.removeAt(0);
      expect(rxList.length, 1);
      expect(rxList, isNot(contains(todo1)));
      expect(rxList, contains(todo2));
    });

    test("RxList clears all items", () {
      final RxList<Todo> rxList = RxList<Todo>();
      final Todo todo1 = Todo(id: 1, title: "Task 1", completed: false);
      final Todo todo2 = Todo(id: 2, title: "Task 2", completed: true);

      rxList.addAll(<Todo>[todo1, todo2]);
      expect(rxList, isNotEmpty);

      rxList.clear();
      expect(rxList, isEmpty);
    });
  });

  test("RxList batchUpdate adds and removes items in a batch", () {
    final RxList<int> rxList = RxList<int>([1, 2, 3]);

    // Using batchUpdate to add and remove items
    rxList.batchUpdate(() {
      rxList.add(4);
      rxList.add(5);
      rxList.remove(2);
    });

    expect(rxList, <int>[1, 3, 4, 5]);
  });

  test("RxList assign replaces the list with a single item", () {
    final RxList<int> rxList = RxList<int>([1, 2, 3]);

    // Replacing the list with a single item
    rxList.assign(4);

    expect(rxList, <int>[4]);
  });

  test("RxList assignAll replaces the list with multiple items", () {
    final RxList<int> rxList = RxList<int>([1, 2, 3]);

    // Replacing the list with multiple items
    rxList.assignAll([4, 5, 6]);

    expect(rxList, <int>[4, 5, 6]);
  });

  test("RxList addIf adds item when condition is true", () {
    final RxList<int> rxList = RxList<int>([1, 2, 3]);

    // Adding item if the condition is true
    rxList.addIf(true, 4);

    expect(rxList, <int>[1, 2, 3, 4]);
  });

  test("RxList addAllIf adds multiple items when condition is true", () {
    final RxList<int> rxList = RxList<int>([1, 2, 3]);

    // Adding multiple items if the condition is true
    rxList.addAllIf(true, [4, 5]);

    expect(rxList, <int>[1, 2, 3, 4, 5]);
  });

  test("RxList addIf does not add item when condition is false", () {
    final RxList<int> rxList = RxList<int>([1, 2, 3]);

    // Condition is false, so no item is added
    rxList.addIf(false, 4);

    expect(rxList, <int>[1, 2, 3]);
  });

  test("RxList toString returns a readable format", () {
    final RxList<int> rxList = RxList<int>([1, 2, 3]);

    // Checking the string representation
    expect(rxList.toString(), "RxList(1, 2, 3)");
  });
}

class Todo {
  Todo({
    required this.id,
    required this.title,
    required this.completed,
  });
  final int id;
  final String title;
  final bool completed;
}
