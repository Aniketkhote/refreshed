import 'package:flutter_test/flutter_test.dart';
import 'package:refreshed/refreshed.dart';

void main() {
  group('RxList Tests', () {
    test('RxList initializes with empty list', () {
      final rxList = RxList<int>();
      expect(rxList, isEmpty);
    });

    test('RxList adds items', () {
      final rxList = RxList<int>();
      rxList.add(1);
      rxList.addAll([2, 3]);
      expect(rxList, [1, 2, 3]);
    });

    test('RxList updates items', () {
      final rxList = RxList<int>();
      rxList.addAll([1, 2, 3]);
      rxList[0] = 4;
      expect(rxList, [4, 2, 3]);
    });

    test('RxList removes items', () {
      final rxList = RxList<int>();
      rxList.addAll([1, 2, 3]);
      rxList.removeAt(1);
      expect(rxList, [1, 3]);
    });

    test('RxList clears all items', () {
      final rxList = RxList<int>();
      rxList.addAll([1, 2, 3]);
      rxList.clear();
      expect(rxList, isEmpty);
    });

    test('RxList listens to changes', () {
      final rxList = RxList<int>();
      var changesCount = 0;
      rxList.listen((_) {
        changesCount++;
      });
      rxList.add(1);
      rxList.addAll([2, 3]);
      expect(changesCount, 2);
    });
  });

  group('RxList with model Tests', () {
    test('RxList initializes with empty list', () {
      final rxList = RxList<Todo>();
      expect(rxList, isEmpty);
    });

    test('RxList adds items', () {
      final rxList = RxList<Todo>();
      final todo1 = Todo(id: 1, title: 'Task 1', completed: false);
      final todo2 = Todo(id: 2, title: 'Task 2', completed: true);

      rxList.add(todo1);
      rxList.addAll([todo2]);

      expect(rxList.length, 2);
      expect(rxList, contains(todo1));
      expect(rxList, contains(todo2));
    });

    test('RxList updates items', () {
      final rxList = RxList<Todo>();
      final todo = Todo(id: 1, title: 'Task 1', completed: false);

      rxList.add(todo);
      expect(rxList[0].completed, false);

      rxList[0] = Todo(id: 1, title: 'Task 1', completed: true);
      expect(rxList[0].completed, true);
    });

    test('RxList removes items', () {
      final rxList = RxList<Todo>();
      final todo1 = Todo(id: 1, title: 'Task 1', completed: false);
      final todo2 = Todo(id: 2, title: 'Task 2', completed: true);

      rxList.addAll([todo1, todo2]);
      expect(rxList.length, 2);

      rxList.removeAt(0);
      expect(rxList.length, 1);
      expect(rxList, isNot(contains(todo1)));
      expect(rxList, contains(todo2));
    });

    test('RxList clears all items', () {
      final rxList = RxList<Todo>();
      final todo1 = Todo(id: 1, title: 'Task 1', completed: false);
      final todo2 = Todo(id: 2, title: 'Task 2', completed: true);

      rxList.addAll([todo1, todo2]);
      expect(rxList, isNotEmpty);

      rxList.clear();
      expect(rxList, isEmpty);
    });

    test('RxList listens to changes', () {
      final rxList = RxList<Todo>();
      final todo1 = Todo(id: 1, title: 'Task 1', completed: false);

      var changesCount = 0;
      rxList.listen((_) {
        changesCount++;
      });

      rxList.add(todo1);
      expect(changesCount, 1);

      rxList[0] = Todo(id: 1, title: 'Task 1', completed: true);
      expect(changesCount, 2);

      rxList.removeAt(0);
      expect(changesCount, 3);

      rxList.clear();
      expect(changesCount, 4);
    });
  });
}

class Todo {
  final int id;
  final String title;
  final bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.completed,
  });
}
