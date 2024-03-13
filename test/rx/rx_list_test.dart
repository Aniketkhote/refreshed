// ignore_for_file: cascade_invocations, unreachable_from_main

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

    test("RxList adds items", () {
      final RxList<Todo> rxList = RxList<Todo>();
      final Todo todo1 = Todo(id: 1, title: "Task 1", completed: false);
      final Todo todo2 = Todo(id: 2, title: "Task 2", completed: true);

      rxList.add(todo1);
      rxList.addAll(<Todo>[todo2]);

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
