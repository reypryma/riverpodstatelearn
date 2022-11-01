abstract class CounterSocketClient {
  Stream<int> getCounterStream([int start]);}

class FakeCounterSocketClient implements CounterSocketClient {
  @override
  Stream<int> getCounterStream([int start = 0]) async* {
    int i = start;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield i++;
    }
  }
}