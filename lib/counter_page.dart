import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/sockets/CounterSocketClient.dart';

// final counterProvider = StateProvider((ref) => 0);

final websocketClientProvider = Provider<CounterSocketClient>(
  (ref) {
    return FakeCounterSocketClient();
  },
);

// final counterProvider = StreamProvider<int>((ref) {
//   final wsClient = ref.watch(websocketClientProvider);
//   return wsClient.getCounterStream();
// });

// The "family" modifier's first type argument is the type of the provider
// and the second type argument is the type that's passed in.
final counterProvider = StreamProvider.family<int, int>((ref, start) {
  final wsClient = ref.watch(websocketClientProvider);

  return wsClient.getCounterStream(start);
});

class CounterPage extends ConsumerWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final int counter = ref.watch(counterProvider);
    // final AsyncValue<int> counter = ref.watch(counterProvider);
    final AsyncValue<int> counter = ref.watch(counterProvider(1));

    ref.listen<AsyncValue<int>>(counterProvider(1), (previous, next) {
      if (next.when(
              data: (value) => value,
              error: (error, stackTrace) {},
              loading: () => 0)! ==
          7) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Warning'),
                content:
                    Text('Counter dangerously high. Consider resetting it.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  )
                ],
              );
            });
      }
    });

    // ref.listen<int>(
    //   counterProvider,
    //   // "next" is referring to the new state.
    //   // The "previous" state is sometimes useful for logic in the callback.
    //       (previous, next) {
    //     if (next >= 7) {
    //       showDialog(
    //         context: context,
    //         builder: (context) {
    //           return AlertDialog(
    //             title: Text('Warning'),
    //             content:
    //             Text('Counter dangerously high. Consider resetting it.'),
    //             actions: [
    //               TextButton(
    //                 onPressed: () {
    //                   Navigator.of(context).pop();
    //                 },
    //                 child: Text('OK'),
    //               )
    //             ],
    //           );
    //         },
    //       );
    //     }
    //   },
    // );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(counterProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Text(
          counter
              .when(
                data: (int value) => value,
                error: (Object e, _) => e,
                // While we're waiting for the first counter value to arrive
                // we want the text to display zero.
                loading: () => 0,
              )
              .toString(),
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Using the WidgetRef to read() the counterProvider just one time.
          //   - unlike watch(), this will never rebuild the widget automatically
          // We don't want to get the int but the actual StateNotifier, hence we access it.
          // StateNotifier exposes the int which we can then mutate (in our case increment).
          // ref.read(counterProvider.notifier).state++;
        },
      ),
    );
  }
}
